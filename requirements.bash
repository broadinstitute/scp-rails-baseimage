BASE_IMAGE="marketplace.gcr.io/google/ubuntu2404:latest" #aggressively keep up with security updates

# pin to versioned releases of phusion images to avoid breakages
PHUSION_BASE_IMAGE_REPO="phusion/baseimage-docker"
PHUSION_BASE_IMAGE_VERSION="noble-1.0.0"

PHUSION_PASSENGER_IMAGE_REPO="phusion/passenger-docker"
PHUSION_PASSENGER_IMAGE_VERSION="3.1.2" #if you change this, you'll have to change the "FROM" line in ./Dockerfile also.
