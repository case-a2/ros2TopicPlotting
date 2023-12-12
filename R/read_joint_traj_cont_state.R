## Function for parsing the message file that is being used
# To add message libraries, copy the specific <name_of_message>/msg directory from /opt/ros/$ROS-DISTRO/share

# Included in this package are sensor_msgs/msg, std_msgs/msg, geometry_msgs/msg, and control_msgs/msg


read_joint_traj_cont_state <- function(bag_name, msg_type) {
  # If using the function, the package name and msg type can be extracted from the file
  file_path <- file.path("src/control_msgs/msg/JointTrajectoryControllerState.msg")

  # check if the file exists
  if (!file.exists(file_path)) {
    stop(paste("Error: Message file not found at", file_path))
  }
  # Pull out the joint names
  name = csv_data[4:9]

  # Manually assign columns to match the JointTrajectoryControllerState message declaration
  # (see src/control_msgs/msg/JointTrajectoryControllerState)

  # Isolated error[], actual[], & desired[] positions

  ur_controller_state <- list(
    error = csv_data[14:19],
    desired = csv_data[32:37],
    actual = csv_data[53:58]
  )

  # Add joint names to the column titles
  for (i in seq_along(name)) {
    joint_col_names <- name[[i]][1]

    colnames(ur_controller_state$error)[i] <- joint_col_names
    colnames(ur_controller_state$desired)[i] <- joint_col_names
    colnames(ur_controller_state$actual)[i] <- joint_col_names
  }

  # Combine the data into a single data frame
  cont_state_data_frame <- data.frame(
    timestamp = csv_data$V1,
    sequence_num = csv_data$V2,
    ur_controller_state
  )

  return(cont_state_data_frame)
}


