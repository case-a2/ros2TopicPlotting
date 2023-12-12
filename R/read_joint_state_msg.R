## Function for parsing the message file that is being used
# To add message libraries, copy the specific <name_of_message>/msg directory from /opt/ros/$ROS-DISTRO/share

# Included in this package are sensor_msgs/msg, std_msgs/msg, and geometry_msgs/msg
# install.packages(c("dbplyr", "RSQlite", "yaml"))

package_name = "sensor_msgs"
msg_type = "JointState"


read_joint_state_msg <- function(package_name, msg_type) {
  ## If using the function, the package name and msg type can be extracted from the file
  file_path <- "src/sensor_msgs/msg/JointState"

  # check if the file exists
  if (!file.exists(file_path)) {
    stop(paste("Error: Message file not found at", file_path))
  }

  # read the content of the msg file
  msg_content <- readLines(file_path)

  # remove the lines starting with #
  msg_content <- msg_content[!grepl("^#", msg_content)]

  # Pull out the joint names
  name = csv_data[4:9]

  # Manually assign columns to match the JointState message declaration (see src/sensor_msgs/msg/JointState.msg)
  joint_states <- list(
    position = csv_data[10:15],
    velocity = csv_data[16:21],
    effort = csv_data[22:27]
  )

  # Add joint names to the column titles
  for (i in seq_along(name)) {
    position_col_names <- name[[i]]
    velocity_col_names <- name[[i]]
    effort_col_names <- name[[i]]

    colnames(joint_states$position)[i] <- position_col_names
    colnames(joint_states$velocity)[i] <- velocity_col_names
    colnames(joint_states$effort)[i] <- effort_col_names
  }

  # Combine the data into a single data frame
  joint_data_frame <- data.frame(
    timestamp = csv_data$V1,
    sequence_num = csv_data$V2,
    joint_states
    )


}

# Example usage:
package_name <- "sensor_msgs"
msg_type <- "Imu"
processed_data <- read_msg(package_name, msg_type)
print(joint_states)


