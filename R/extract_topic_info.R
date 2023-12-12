## Function to extract the topic information from the bag file to be used in the read_msg function

# Input: .db3 file generated from a ROS 2 bag function

# Output: A list of the topic names and message types

#### TESTS ####
library(RSQLite)
library(readr)


extract_topic_info <- function(bag_name) {
  sqlite <- dbDriver("SQLite")

  ## Connect to bag file to retrieve topic information

  file_path_bag <- file.path("vignettes", bag_name, paste0(bag_name, "_0.db3"))

  db_info <- dbGetInfo(dbConnect(sqlite, file_path_bag))
  sql_conn <- dbConnect(RSQLite::SQLite(), db_info[["dbname"]])

  name = dbGetQuery(sql_conn, "SELECT name FROM topics")
  type = dbGetQuery(sql_conn, "SELECT type FROM topics")

  topic_information <- list(
    name = name[[1]],
    type = type
  )


  return(topic_information)

  dbDisconnect(sql_conn)
}

# Example usage:
bag_name <- "ur3_move_two"
extract_topic_info(bag_name)


