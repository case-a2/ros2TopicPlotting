## Function to extract the topic information from the bag file to be used in the read_msg function

# Input: .db3 file generated from a ROS 2 bag function

# Cycles through list of topics and provides the data frame format for relavant data


#' Extract the topic information from the bag file and parse all the topics through the format_msg_csv function, generating a list of usable data frames
#'
#' @param bag_name - The name of the bag file recorded by ROS2, defaults to ur3_move, which is included in the vignettes folder
#'
#' @return A list with data frames of recorded topic information
#' \item{output_data_frame[joint_states]}
#' \item{joint_states topic}{Position, velocity, and effort values for 6-DOF robotic manipulator.}
#' \item{output_data_frame[ur_controller_state]}{Error, desired, and actual position values for 6-DOF robotic manipulator.}
#' \item{ur_controller_state topic}{Error, desired, and actual position values for 6-DOF robotic manipulator.}
#'
#' @export
#'
#' @examples
#' extract_topic_info("ur3_move")
#' extract_topic_info("ur3_move_two")
#'
extract_topic_info <- function(bag_name = NULL) {
  sqlite <- dbDriver("SQLite")

  if (is.null(bag_name)) {
    print("No bag provided, proceeding with Joint States message")
    bag_name <- "ur3_move"
  }

  ## Connect to bag file to retrieve topic information
  file_path_bag <- file.path("vignettes", bag_name, paste0(bag_name, "_0.db3"))

  # Open db connection to read the bag file
  db_info <- dbGetInfo(dbConnect(sqlite, file_path_bag))
  sql_conn <- dbConnect(RSQLite::SQLite(), db_info[["dbname"]])

  name = dbGetQuery(sql_conn, "SELECT name FROM topics")
  type = dbGetQuery(sql_conn, "SELECT type FROM topics")
  dbDisconnect(sql_conn)

  # Pull the topic name and message type into a list
  topic_information <- list(
    name = name,
    type = type
  )


  # Find the number of topics in the bag file
  num_topics <- length(topic_information$name)

  output_data_frame <- list()

  # Loops through the CSV files associated with the bag file
  for (i in num_topics) {
    # Pick a topic
    topic_name <- topic_information$name[[1]][i]
    print(paste0("Printing: ", topic_name))

    # Send topic to csv_msg_format function
    output_data_frame[[i]] <- format_msg_csv(bag_name, topic_name)

    # Write the output to a  file

  }

  # Close the db connection

  return(output_data_frame)
}

# Example usage:
bag_name <- "ur3_move_two"
extract_topic_info(bag_name)

## This package assumes that you captured the ROS 2 data using the following command:

# ros2 topic echo --csv /topic_name > topic_name.csv
# Replacing topic_name with the name of the topic you are trying to record.


#############################################################################################################
## Function for parsing the message file that is being used
# To add message libraries, copy the specific <name_of_message>/msg directory from /opt/ros/$ROS-DISTRO/share

# Included in this package are the definition files (located in src) for sensor_msgs/msg, std_msgs/msg, geometry_msgs/msg, and control_msgs/msg

#' Format the echoed message data to a data frame to be used for plotting
#'
#' @param bag_name - The name of the bag file recorded by ROS2, defaults to ur3_move, which is included in the vignettes folder
#' @param topic_name - The name of the topic that was recorded, defaults to joint_states. Messages used for the topics are included in the src folder
#'
#' @return joint_data_frame - Data frame for a single topic ( 2 available topics )
#' \item{[joint_states]} - {Position, velocity, and effort values for 6-DOF robotic manipulator.}
#' \item{[ur_controller_state]} - {Error, desired, and actual position values for 6-DOF robotic manipulator.}
#'
#' @export
#'
#' @examples
#' data_frame_JS <- format_msg_csv("ur3_move", "joint_states")
#' data_frame_JTCS <- format_msg_csv("ur3_move_two", "ur_controller_state")


.format_msg_csv <- function(bag_name = NULL, topic_name = NULL) {
  # If using the function, the package name and msg type can be extracted from the file
  if (is.null(topic_name) | is.null(bag_name)) {
    print("No topic or bag provided, proceeding with Joint States message")
    topic_name <- "/joint_states"
    bag_name <- "ur3_move"
  }

  # Convert the topic name to the csv file format ignoring the leading slash
  topic_name <- gsub("^/", "", topic_name)
  topic_name <- gsub("/", "_", topic_name)

  # Read the .csv file
  csv_file <- file.path("vignettes", bag_name, paste0(topic_name, ".csv"))
  csv_data <- read.csv(csv_file, header = FALSE, stringsAsFactors = FALSE)

  # Pull out the joint names
  name = csv_data[4:9]

  if (topic_name == "joint_states") {
    # Manually assign columns to match the JointState message declaration (see src/sensor_msgs/msg/JointState.msg)
    csv_target_range <- list(
      position = csv_data[10:15],
      velocity = csv_data[16:21],
      effort = csv_data[22:27]
    )
  }
  if (topic_name == "ur_controller_state") {
    # Manually assign columns to match the JointTrajectoryControllerState message declaration
    # (see src/control_msgs/msg/JointTrajectoryControllerState)

    # Isolated error[], actual[], & desired[] positions
    csv_target_range <- list(
      error = csv_data[14:19],
      desired = csv_data[32:37],
      actual = csv_data[53:58]
    )
  }

  # Add joint names to the column titles
  for (i in seq_along(name)) {
    joint_col_names <- name[[i]][1]

    colnames(csv_target_range$position)[i] <- joint_col_names
    colnames(csv_target_range$velocity)[i] <- joint_col_names
    colnames(csv_target_range$effort)[i] <- joint_col_names
  }

  # Combine the data into a single data frame
  joint_data_frame <- data.frame(
    timestamp = csv_data$V1,
    sequence_num = csv_data$V2,
    csv_target_range
  )

  return(joint_data_frame)
}


