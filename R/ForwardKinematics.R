## Function to perform forward kinematics on the UR3 robot arm, with the values obtained from the CSV file in the ros2 bag recording

source("R/format_msg_csv.R")
# Update the joint values and calculate the end-effector position

#' Forward Kinematics for UR3 Robot Arm
#'
#' @param selected_data - The data frame of joint values returned from a topic
#' @param time_interval
#'
#' @return A 3D plot of the end effector trajectory
#' @export
#'
#' @examples
#' selected_data <- format_msg_csv("ur3_move", "joint_states")
#' update_plot(selected_data)
#'
update_plot <- function(selected_data, time_interval = 500) {
  num_samples <- nrow(selected_data)

  # Create an empty plot
  plot3d(NULL, xlim = c(0, 7), ylim = c(0, 7), zlim = c(0, 7), main = "End Effector Trajectory")


  for (i in seq(1, num_samples)) {
    # Extract joint values for the current sample
    joint_values <- selected_data[i, c("position.shoulder_pan_joint", "position.shoulder_lift_joint", "position.elbow_joint", "position.wrist_1_joint", "position.wrist_2_joint", "position.wrist_3_joint")]

    joint_values <- as.numeric(joint_values)
    # Perform forward kinematics
    end_effector_position <- ur3_forward_kinematics(joint_values)

    # Update X, y, z
    x <- end_effector_position[[1]][1]
    y <- end_effector_position[[1]][2]
    z <- end_effector_position[[1]][3]

    # Check if the data is numeric
    if (!all(sapply(list(x, y, z), is.numeric))) {
      stop("Coordinates must be numeric.")
    }
    plot3d(NULL, xlim = c(-3, 3), ylim = c(-3, 3), zlim = c(0,5), main = "End Effector Trajectory", type = "n")
    cat("Iteration:", i, "\n")


    xlim <- c(min(c(0, x), na.rm = TRUE),
              max(c(0, x), na.rm = TRUE))
    ylim <- c(min(c(0, y), na.rm = TRUE),
              max(c(0, y), na.rm = TRUE))
    zlim <- c(min(c(0, z), na.rm = TRUE),
              max(c(0, z), na.rm = TRUE))

    # Update the plot with the end-effector position
    # Update the 3D plot

    plot3d(x, y, z, col = "blue", size = 3, type = "p", xlim = xlim, ylim = ylim, zlim = zlim, xlab = "X", ylab = "Y", zlab = "Z", add = TRUE)

    lines3d(c(0, x), c(0, y), c(0, z), col = "blue", lwd = 2)

  }
}

#' Perform and plot iterations of forward kinematics
#'
#' @param joint_values
#'
#' @return A list containing the end-effector position and orientation  position -
#' 1x3 end_effector_position vector, orientation = 1x3 end_effector_orientation vector
#' @export
#'
#' @examples
#' joint_values <- c(0, 0, 0, 0, 0, 0)
#' ur3_forward_kinematics(joint_values)
.ur3_forward_kinematics <- function(joint_angles) {

  # UR3 kinematic parameters
  d1 <- 0.1519
  a2 <- -0.24365
  a3 <- -0.21325
  d4 <- 0.11235
  d5 <- 0.08535
  d6 <- 0.0819

  # Initialize transformation matrix
  transformation_matrix <- diag(4)

  # Define the DH parameters
  dh_params <- matrix(c(0, pi/2, d1, joint_angles[1],
                        a2, 0, 0, joint_angles[2],
                        a3, 0, 0, joint_angles[3],
                        0, pi/2, d4, joint_angles[4],
                        0, -pi/2, d5, joint_angles[5],
                        0, 0, d6, joint_angles[6]), ncol = 4, byrow = TRUE)

  # Perform forward kinematics by successively applying transformations for each joint
  for (i in seq_len(nrow(dh_params))) {
    alpha_i_minus_1 <- dh_params[i, 2]
    a_i_minus_1 <- dh_params[i, 1]
    d_i <- dh_params[i, 3]
    theta_i <- dh_params[i, 4]
    # Compute transformation matrix for the current joint
    transformation_matrix_i <- matrix(c(cos(theta_i), -sin(theta_i), 0, a_i_minus_1,
                                        sin(theta_i) * cos(alpha_i_minus_1), cos(theta_i) * cos(alpha_i_minus_1), -sin(alpha_i_minus_1), -sin(alpha_i_minus_1) * d_i,
                                        sin(theta_i) * sin(alpha_i_minus_1), cos(theta_i) * sin(alpha_i_minus_1), cos(alpha_i_minus_1), cos(alpha_i_minus_1) * d_i,
                                        0, 0, 0, 1), nrow = 4, byrow = TRUE)

    # Update the transformation matrix
    transformation_matrix <- transformation_matrix %*% transformation_matrix_i
  }

  # Extract the end-effector position and orientation from the final transformation matrix
  end_effector_position <- transformation_matrix[1:3, 4]
  end_effector_orientation <- rotationMatrixToQuaternion(transformation_matrix[1:3, 1:3])

  result <- list(position = end_effector_position, orientation = end_effector_orientation)

  return(result)
}




# Function to convert rotation matrix to quaternion
#'
#'
#' @param R Rotation matrix of the form 3x3
#'
#' @return Vector of the form (qw, qx, qy, qz)
#' @export
#'
#' @examples
#' R <- matrix(c(0.999999999999999, 0, 0, 0, 0.999999999999999, 0, 0, 0, 1), nrow = 3, byrow = TRUE)
#' rotationMatrixToQuaternion(R)
#'
.rotationMatrixToQuaternion <- function(R) {
  qw <- sqrt(1 + R[1, 1] + R[2, 2] + R[3, 3]) / 2
  qx <- (R[3, 2] - R[2, 3]) / (4 * qw)
  qy <- (R[1, 3] - R[3, 1]) / (4 * qw)
  qz <- (R[2, 1] - R[1, 2]) / (4 * qw)

  return(c(qw, qx, qy, qz))
}


# Call the function to update the plot
# update_plot(selected_data)

