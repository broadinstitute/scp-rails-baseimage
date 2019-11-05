This code is used to build and publish a Docker image that the Single Cell Portal team uses as a basis for Rails servers.

Jobs for this repo are at: https://scp-jenkins.dsp-techops.broadinstitute.org/view/scp-rails-baseimage/

# What is this? Why does it exists? #

This provides a base image with Ruby on Rails ready to go with Phusion Passenger. The Single Cell Portal has a Docker image that was formerly built on `phusion/passenger-docker`, but this ensures that it's built on a [managed base image](https://cloud.google.com/container-registry/docs/managed-base-images) provided by Google, which is good because they keep those images up-to-date with security fixes and it apparently makes our auditors happy. So here, we rebuild a couple images from Phusion with tweaks to make that happen.

# Using the image #

This image is available as [`singlecellportal/rails-baseimage` on Dockerhub](https://hub.docker.com/r/singlecellportal/rails-baseimage), so specify that in your Docker commands or Dockerfile.

# To make changes and publish a new image... #

## Making changes ##

`./Dockerfile` is the main Docker file as you would expect, so that's the file to modify to change what's in the image.

To update the versions of the underlying images, modify requirements.bash (and the Dockerfile). We are specifying a Docker image version for the underlying base image, but the version numbers for the Phusion images actually correspond to GitHub release tags, since we are rebuilding them from (slightly altered) source.

To make changes to how the various layers get downloaded, changed and rebuilt, look in `./lib/` and `./ci/` .

run `git grep DEBUG_HACK` to find a couple places in the code that might be worth editing to develop faster.

## Testing changes ##

Once you have made changes that you are ready to test,
you'll want to:
*  build the image. Running `./ci/local_build` is recommended way to do this on a workstation. All of the high-level scripts that would normally be called directly are in `./ci/` , including `build` and `local_build`. If you have the right prerequisites installed, you could run `build` directly on a workstation, but `local_build` will take care of running it in a container that has the necessary things installed already. If the image builds successfully, you can use it to do further testing.
* run ./ci/test and make sure it exits with 0

## Publishing changes ##

To publish your changes, you'll need to increment the version number in `./version.txt` (in accordance with [SemVer](https://semver.org/), please), and get your changes committed, pushed, and merged into the `master` branch. At that point, [this Jenkins job](https://scp-jenkins.dsp-techops.broadinstitute.org/job/scp-rails-baseimage-publish/) will attempt to build and publish your changes to Docker Hub. It is possible, but not recommended, to publish from your workstation by running `./ci/publish`

# Potential improvements #

* ( done ) automatically smoke test changes to the image on any branch to gate pull requests:
    * (done) add a jenkins job to run the build/test on all branches (except master), and corresponding script, which:
    * (done) builds the image (and verifies that it built it)
    * (done) tests the image by making sure it can serve a page (nginx welcome page), probably mapping in a generic webapp.conf file to have it start up nginx and expose port 80 or 443 and make a GET on localhost. (don't worry about ssl)
    * (done) verifies that version.txt contains a version number that hasn't been used yet (or if it has been used, it's for an identical image)
    * ( done ) consider a mutex for the two jenkins scripts, since they both run $THIS_DIR/clean, and they both use a bunch of resources.
    * ( done ) configure jenkins jobs with final email addresses and branches
* ( TODO ) automatically publish git tags for published versions
* ( TODO ) publish version 1.0.
* ( TODO ) jenkins/github integration
* ( TODO ) document or add optional flags to do local testing faster (I have a hack or two that's not comitted yet)
* ( TODO ) does/can/should ci/test work when not run in the image builder container?
* ( done ) automatically keep track of new releases to underlying layers to help us keep this image up to date.
    * ( done ) a test job should watch for changes and "fail" if there are new changes that need to be incorporated
        * ( done ) for the google-maintained base image, which is spec'ed to latest:
            * ( done ) force pull the "latest" image, so you can't possibly get confused by something stale?
            * ( done ) complain if there are new changes that need to be published without a new version number
        * ( done ) for the phusion-maintained source code that creates the intermediate images (which are pinned to specific versions):
            * ( done ) check for more recent release tags, and if any are found:
                * ( done ) print a warning
                * ( done ) have the build send an email (set build to unstable)
* ( done ) add a "clean" script that removes tmp, maybe clears out some docker images, too?
