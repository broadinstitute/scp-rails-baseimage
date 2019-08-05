This code is used to build and publish a docker image that the Single Cell Portal team uses as a basis for Rails servers.

# What is this this? Why does it exists? #

This provides a base image with ruby on rails ready to go with phusion passenger. The single cell portal has a docker image that was formerly built on `phusion/passenger-docker`, but this ensures that it's built on a base image provided by Google, which is good because they keep those images up-to-date with security fixes and it apparently makes our auditors happy. So here, we rebuild a couple images from phusion with tweaks to make that happen.

# using the image #

This image is available as [`singlecellportal/rails-baseimage` on Dockerhub](https://hub.docker.com/r/singlecellportal/rails-baseimage), so specify that in your docker commands or Dockerfile.

# To make changes and publish a new image... #

## making changes ##

`./Dockerfile` is the main docker file as you would expect, so that's the file to modify to change what's in the image.

To update the versions of the underlying images, modify requirements.bash (and the Dockerfile). We are specifying a docker image version for the underlying base image, but the version numbers for the phusion images actually correspond to github release tags, since we are rebuilding them from (slightly altered) source.

To make changes to how the various layers get downloaded, changed and rebuilt, look in `./lib/` and `./ci/` .

## testing changes ##

Once you have made changes that you are ready to test, you'll want to build the image. Running `./ci/local_build` is recommended way to do this on a workstation. All of the high-level scripts that would normally be called directly are in `./ci/` , including `build` and `local_build`. If you have the right prerequisites installed, you could run `build` directly on a workstation, but `local_build` will take care of running it in a container that has the necessary things installed already. If the image builds successfully, you can use it to do further testing.

## publishing changes ##

To publish your changes, you'll need to increment the version number in `./version.txt` (in accordance with semver, please), and get your changes committed, pushed, and merged into the `master` branch. At that point, [this jenkins job](https://scp-jenkins.dsp-techops.broadinstitute.org/job/scp-rails-baseimage-publish/) will attempt to build and publish your changes to docker hub. It is possible, but not recommended, to publish from your workstation by running `./ci/publish`

# potential improvments #

* automatically keep track of new releases to underlying layers to help us keep this image up to date.
* automatically test the image by making sure it can serve a page.
    * add a jenkins job to run the build/test on all branches (except master)
