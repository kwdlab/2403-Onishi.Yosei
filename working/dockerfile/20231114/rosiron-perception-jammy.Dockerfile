# This is an auto generated Dockerfile for ros:perception
# generated from docker_images_ros2/create_ros_image.Dockerfile.em
FROM ros:iron-ros-base-jammy

# install ros2 packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-iron-perception=0.10.0-3* \
    && rm -rf /var/lib/apt/lists/*

