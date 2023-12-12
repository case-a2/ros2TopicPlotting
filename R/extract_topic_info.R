## Function to extract the topic information from the bag file to be used in the read_msg function

# Input: .db3 file generated from a ROS 2 bag function

# Cycles through list of topics and provides the data frame format for relavant data


source("R/format_msg_csv.R")

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


