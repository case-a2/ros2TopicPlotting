## Function for parsing the message file that is being used
# To add message libraries, copy the specific <name_of_message>/msg directory from /opt/ros/$ROS-DISTRO/share

# Included in this package are sensor_msgs/msg, std_msgs/msg, and geometry_msgs/msg
# install.packages(c("dbplyr", "RSQlite", "yaml"))

#### TESTS ####
library(RSQLite)
sqlite <- dbDriver("SQLite")


bag_name <- "subset"
file_path_bag <- file.path("vignettes", bag_name, paste0(bag_name, "_0.db3"))

db_info <- dbGetInfo(dbConnect(sqlite, file_path_bag))
sql_conn <- dbConnect(RSQLite::SQLite(), db_info[["dbname"]])

query <- dbGetQuery(sql_conn, "SELECT * FROM topics")
print(query)

query_pose <- dbGetQuery(sql_conn, "SELECT * FROM messages WHERE topic_id = 1")
query_cmd_vel <- dbGetQuery(sql_conn, "SELECT * FROM messages WHERE topic_id = 2")

dbDisconnect(sql_conn)

####

read_msg <- function(package_name, msg_type) {
  # read content from file path


  ## If using the read_metadata_yaml function, the package name and msg type can be extracted from the metadata.yaml file
  file_path <- file.path("src", package_name, "msg", paste0(msg_type, ".msg"))

  # check if the file exists
  if (!file.exists(file_path)) {
    stop(paste("Error: Message file not found at", file_path))
  }

  # read the content of the msg file
  msg_content <- readLines(file_path)

  # Initialize variables for data storage
  header = list()
  data_fields = list()


  # Variable to indicate if we are inside the header section
  inside_header <- FALSE
  current_header <- NULL

  # Parse each line of the .msg file
  for (line in msg_content) {
    # Remove comments from the line
    line <- gsub("#.*", "", line)

    # Remove leading and trailing whitespaces
    line <- trimws(line)

    if (length(line) > 0) {
      tokens <- strsplit(line, "\\s+")[[1]]

      if (length(tokens) >= 2) {
        field <- tokens[1]
        values <- tokens[-1]

        # Extract field name without array specifier and package path
        field_name <- gsub("\\[.*\\]", "", field)
        field_name <- gsub(".*/", "", field_name)

        if (field == "std_msgs/Header") {
          # Handle header separately
          inside_header <- TRUE
          current_header <- header
        } else if (inside_header) {
          # Process nested structures within the header
          current_header[[field_name]] <- as.list((values))
        } else if (startsWith(field, "geometry_msgs/") || startsWith(field, "std_msgs/")) {
          # Process fields from geometry_msgs and std_msgs
          data_fields[[field_name]] <- as.list((values))
        } else {
          # Process other field types
          if (length(values) > 1) {
            data_fields[[field_name]] <- as.list((values))
          } else {
            data_fields[[field_name]] <- values
          }
        }
      }
    }
  }

  # Create a list to store the processed data
  result <- list(
    header = header,
    data_fields = data_fields
  )

  return(result)
}



# Example usage:
package_name <- "sensor_msgs"
msg_type <- "Imu"
processed_data <- read_msg(package_name, msg_type)
print(processed_data)


