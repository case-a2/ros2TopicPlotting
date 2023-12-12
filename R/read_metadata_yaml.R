# Function for reading metadata from a YAML file to pull topic and message information
# This function is used to read the metadata.yaml file that is generated when recording data with ROS 2 bag
# to extract the topic names and message counts for each topic

# file_path: path to the .yaml file
# topic_num: index of the topic to return information for (OPTIONAL)

read_metadata_yaml <- function(file_path, topic_num = NULL, select_topic = NULL) {
  # Read the .yaml file
  yaml_data <- suppressWarnings(yaml::yaml.load_file(file_path))

  if (is.null(topic_num)) {
    # If no topic_num is specified, return info on all topics

    num_of_topics <- length(yaml_data$rosbag2_bagfile_information$topics_with_message_count)
    for (i in 1:num_of_topics) {
      # Structure a list of # of msgs, topic type, and topic name
      topic_info <- list(
        num_msgs = yaml_data$rosbag2_bagfile_information$topics_with_message_count[[i]]$message_count,
        topic_type = yaml_data$rosbag2_bagfile_information$topics_with_message_count[[i]]$topic_metadata$type,
        topic_name = yaml_data$rosbag2_bagfile_information$topics_with_message_count[[i]]$topic_metadata$name
      )

      # Add the topic info to the list of topics
      if (i == 1) {
        topics <- list(topic_info)
      } else {
        topics <- c(topics, list(topic_info))
      }
    }

    return(topics)

  } else {
    # If a topic_num is specified, return the topic info at that index

    # Structure a list of # of msgs, topic type, and topic name
    topic_info <- list(
      num_msgs = yaml_data$rosbag2_bagfile_information$topics_with_message_count[[topic_num]]$message_count,
      topic_type = yaml_data$rosbag2_bagfile_information$topics_with_message_count[[topic_num]]$topic_metadata$type,
      topic_name = yaml_data$rosbag2_bagfile_information$topics_with_message_count[[topic_num]]$topic_metadata$name
    )

    return(topic_info)
  }

}

# Example usage:
recorded_data <- "subset"
# replace with the path to your ros2 bag's metadata.yaml file

# This example uses the bag files in the vignettes folder in the package
file_path <- file.path("vignettes", recorded_data, "metadata.yaml")

test1 <- read_metadata_yaml(file_path)
test2 <- read_metadata_yaml(file_path, topic_num = 1)

print(test1)
print(test2)
