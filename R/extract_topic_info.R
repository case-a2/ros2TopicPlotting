## Function to extract the topic information from the bag file to be used in the read_msg function

# Input: .db3 file generated from a ROS 2 bag function

# Output: A list of the topic names and message types
library(RSQLite)
source()

extract_topic_info <- function(bag_name) {
  sqlite <- dbDriver("SQLite")

  ## Connect to bag file to retrieve topic information
  file_path_bag <- file.path("vignettes", bag_name, paste0(bag_name, "_0.db3"))

  # Open db connection to read the bag file
  db_info <- dbGetInfo(dbConnect(sqlite, file_path_bag))
  sql_conn <- dbConnect(RSQLite::SQLite(), db_info[["dbname"]])

  name = dbGetQuery(sql_conn, "SELECT name FROM topics")
  type = dbGetQuery(sql_conn, "SELECT type FROM topics")

  # Pull the topic name and message type into a list
  topic_information <- list(
    name = name,
    type = type
  )

  # Find the number of topics in the bag file
  num_topics <- length(topic_information$name)

  # Loops through the CSV files associated with the bag file
  for (i in num_topics) {
    # send to csv function
    topic_name <- topic_information$name[[1]][i]
    topic_type <- topic_information$type[[1]][i]

    csv_msg_format(bag_name, topic_name, topic_type)
  }


  dbDisconnect(sql_conn)

  # maybe export the new table you made?
  return(topic_information)
}

# Example usage:
bag_name <- "ur3_move_two"
extract_topic_info(bag_name)


