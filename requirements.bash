BASE_IMAGE="marketplace.gcr.io/google/ubuntu1804:latest" #aggressively keep up with security updates

# pin to versioned releases of phusion images to avoid breakages
PHUSION_BASE_IMAGE_REPO="phusion/baseimage-docker"
PHUSION_BASE_IMAGE_VERSION="0.11"

PHUSION_PASSENGER_IMAGE_REPO="phusion/passenger-docker"
PHUSION_PASSENGER_IMAGE_VERSION="1.0.8"
