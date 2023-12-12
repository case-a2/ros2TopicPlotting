## This package assumes that you captured the ROS 2 data using the following command:

# ros2 topic echo --csv /topic_name > topic_name.csv
# Replacing topic_name with the name of the topic you are trying to record.

# Select a playback .csv file to playback the data for a variety of plots

csv_msg_format <- function(bag_name, topic_name, topic_type) {

  # Convert the topic name to the csv file format ignoring the leading slash
  topic_name <- gsub("^/", "", topic_name)
  topic_name <- gsub("/", "_", topic_name)

  # Read the .csv file
  csv_file <- file.path("vignettes", bag_name, paste0(topic_name, ".csv"))
  csv_data <- read.csv(csv_file, header = FALSE, stringsAsFactors = FALSE)


  data_fields <- csv_data

  # Create a list to store the processed data
  result <- list(
    data_fields = data_fields
  )

  # Send the data to the corresponding function to deal with the type of message

  if (topic_name == "joint_states") {
    joint_states_df <- read_joint_state_msg(bag_name, topic_name)
  }
  if (topic_name == "ur_controller_state") {
    joint_traj_cont_df <- read_joint_traj_cont_state(bag_name, topic_name)
  } else {
    print("Error: Message type not found")
  }


}

# Example usage:

csv_file <- "vignettes/ur3_move/joint_states.csv"
processed_data <- csv_msg_format(csv_file)
print(processed_data)

#############################################################################################################
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

#############################################################################################################
## Function for parsing the message file that is being used
# To add message libraries, copy the specific <name_of_message>/msg directory from /opt/ros/$ROS-DISTRO/share

# Included in this package are sensor_msgs/msg, std_msgs/msg, geometry_msgs/msg, and control_msgs/msg

read_joint_state_msg <- function(bag_name, msg_type) {
  # If using the function, the package name and msg type can be extracted from the file
  file_path <- file.path("src/sensor_msgs/msg/JointState.msg")

  # check if the file exists
  if (!file.exists(file_path)) {
    stop(paste("Error: Message file not found at", file_path))
  }

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
    joint_col_names <- name[[i]][1]

    colnames(joint_states$position)[i] <- joint_col_names
    colnames(joint_states$velocity)[i] <- joint_col_names
    colnames(joint_states$effort)[i] <- joint_col_names
  }

  # Combine the data into a single data frame
  joint_data_frame <- data.frame(
    timestamp = csv_data$V1,
    sequence_num = csv_data$V2,
    joint_states
  )

  return(joint_data_frame)
}

# Example usage:
data_frame_JS <- read_joint_state_msg("ur3_move", "joint_states")

