# Use singlecellportal/phusion_passenger-full as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.

FROM singlecellportal/phusion_passenger-full:2.2.0
#FROM singlecellportal/phusion_passenger-full:1.0.8

# Or, instead of the 'full' variant, use one of these:
#FROM singlecellportal/phusion_passenger-ruby19:<VERSION>
#FROM singlecellportal/phusion_passenger-ruby20:<VERSION>
#FROM singlecellportal/phusion_passenger-ruby21:<VERSION>
#FROM singlecellportal/phusion_passenger-ruby22:0.9.17
#FROM singlecellportal/phusion_passenger-jruby90:<VERSION>
#FROM singlecellportal/phusion_passenger-nodejs:<VERSION>
#FROM singlecellportal/phusion_passenger-customizable:<VERSION>

# Labeling the image clearly, following & extending the schema at https://bit.ly/2pJmHyS :
# To see labels later, run: docker inspect singlecellportal/rails-baseimage:<version>
ARG VCS_REF="unspecified"
ARG ORIGIN_STORY="unspecified"
LABEL org.opencontainers.image.vendor="Broad Institute" \
      org.opencontainers.image.vcs-url="https://github.com/broadinstitute/scp-rails-baseimage" \
      org.opencontainers.image.vcs-ref="$VCS_REF" \
      org.opencontainers.image.source="https://github.com/broadinstitute/scp-rails-baseimage/tree/$VCS_REF" \
      org.opencontainers.image.description="An image used for the single cell portal, based on phusion passenger and rails. $ORIGIN_STORY"

# Set correct environment variables.
ENV HOME /root
USER root

# Use baseimage's init process.
CMD ["/sbin/my_init"]

# If you're using the 'customizable' variant, you need to explicitly opt-in
# for features. Uncomment the features you want:
#
#   Build system and git.
#RUN /pd_build/utilities.sh
#   Ruby support.
#RUN /pd_build/ruby1.9.sh
#RUN /pd_build/ruby2.0.sh
#RUN /pd_build/ruby2.1.sh
#RUN /pd_build/ruby2.2.sh
#RUN /pd_build/jruby9.0.sh
#   Python support.
#RUN /pd_build/python.sh
#   Node.js and Meteor support.
#RUN /pd_build/nodejs.sh

# Update bundler
RUN gem install bundler

# Install imagemagick + dependencies
RUN apt-get update && apt-get install -y -qq --no-install-recommends apt-utils sudo tzdata wget
RUN apt-get update && apt-get install -y -qq --no-install-recommends imagemagick ghostscript build-essential unzip net-tools bc curl ssmtp debconf
RUN apt-get update && apt-get install libaio1 shared-mime-info
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install nginx-headers-more package
RUN apt-get update && apt-get install -y -qq --no-install-recommends libnginx-mod-http-headers-more-filter
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install node 16 since we're not using the 'customizable' version
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get update && apt-get install -y nodejs

# add yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb [trusted=yes] https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

# Set timezone correctly
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && printf 'America\nNew_York\n' | dpkg-reconfigure tzdata

# Create temporary SSL certificate for local development
RUN mkdir -p /etc/pki/tls
RUN mkdir -p /etc/pki/tls/certs
RUN mkdir -p /etc/pki/tls/private
RUN echo "copy_extensions = copy\n" >> /etc/ssl/openssl.cnf
RUN echo "subjectAltName=email:copy\n" >> /etc/ssl/openssl.cnf
RUN echo "issuerAltName=issuer:copy\n" >> /etc/ssl/openssl.cnf

RUN openssl req -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=Massachusetts/L=Cambridge/O=Broad Institute/OU=BITS DevOps/CN=localhost/subjectAltName=localhost/emailAddress=bistline@broadinstitute.org" \
    -keyout /etc/pki/tls/private/localhost.key \
    -out /etc/pki/tls/certs/localhost.crt

# Add Root CA and DHE key-exchange cert
COPY ./GeoTrust_Universal_CA.pem /usr/local/share/ca-certificates
COPY ./dhparam.pem /usr/local/share/ca-certificates

RUN mkdir -p /etc/docker_image_creation_info
COPY ./tmp/*state_report.txt /etc/docker_image_creation_info/
RUN cp /etc/docker_image_creation_info/*state_report.txt /tmp/
