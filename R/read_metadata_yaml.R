# Function for reading metadata from a YAML file to pull topic and message information
# This function is used to read the metadata.yaml file that is generated when recording data with ROS 2 bag
# to extract the topic names and message counts for each topic

# file_path: path to the .yaml file
# topic_num: index of the topic to return information for (OPTIONAL)

read_metadata_yaml <- function(file_path, topic_num = NULL) {
  # Read the .yaml file
  yaml_data <- suppressWarnings(yaml::yaml.load_file(file_path, readLines.warn = readLines.warn))

  if (is.null(topic_num)) {
    # If no topic_num is specified, return info on all topics
    return(yaml_data$rosbag2_bagfile_information$topics_with_message_count)
  } else {
    # If a topic_num is specified, return the topic info at that index
    return(yaml_data$rosbag2_bagfile_information$topics_with_message_count[[topic_num]])
  }

}

# Example usage:
recorded_data <- "subset"
file_path <- file.path("vignettes", recorded_data, "metadata.yaml")

test1 <- read_metadata_yaml(file_path)
test2 <- read_metadata_yaml(file_path, topic_num = 1)
