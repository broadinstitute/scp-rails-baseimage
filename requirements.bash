BASE_IMAGE="marketplace.gcr.io/google/ubuntu2004:latest" #aggressively keep up with security updates

# pin to versioned releases of phusion images to avoid breakages
PHUSION_BASE_IMAGE_REPO="phusion/baseimage-docker"
PHUSION_BASE_IMAGE_VERSION="focal-1.2.0"

PHUSION_PASSENGER_IMAGE_REPO="phusion/passenger-docker"
PHUSION_PASSENGER_IMAGE_VERSION="2.4.1" #if you change this, you'll have to change the "FROM" line in ./Dockerfile also.
