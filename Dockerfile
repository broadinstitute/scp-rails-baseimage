# Use phusion/passenger-full as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/passenger-full:0.9.33

# Or, instead of the 'full' variant, use one of these:
#FROM phusion/passenger-ruby19:<VERSION>
#FROM phusion/passenger-ruby20:<VERSION>
#FROM phusion/passenger-ruby21:<VERSION>
#FROM phusion/passenger-ruby22:0.9.17
#FROM phusion/passenger-jruby90:<VERSION>
#FROM phusion/passenger-nodejs:<VERSION>
#FROM phusion/passenger-customizable:<VERSION>

# Set correct environment variables.
ENV HOME /root
USER root

# Use baseimage-docker's init process.
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

# Install imagemagick & sphinx + dependencies
RUN apt-get update && apt-get install -y -qq --no-install-recommends apt-utils sudo tzdata
RUN apt-get update && apt-get install -y -qq --no-install-recommends imagemagick ghostscript build-essential unzip net-tools bc curl ssmtp debconf
RUN apt-get install libaio1
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set timezone correctly
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && printf 'America\nNew_York\n' | dpkg-reconfigure tzdata


# Create temporary SSL certificate for local development
RUN mkdir /etc/pki/tls
RUN mkdir /etc/pki/tls/certs
RUN mkdir /etc/pki/tls/private
RUN echo "copy_extensions = copy\n" >> /etc/ssl/openssl.cnf
RUN echo "subjectAltName=email:copy\n" >> /etc/ssl/openssl.cnf
RUN echo "issuerAltName=issuer:copy\n" >> /etc/ssl/openssl.cnf

RUN openssl req -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=Massachusetts/L=Cambridge/O=Broad Institute/OU=BITS DevOps/CN=localhost/emailAddress=bistline@broadinstitute.org" \
    -keyout /etc/pki/tls/private/localhost.key \
    -out /etc/pki/tls/certs/localhost.crt
    
# Add Root CA and DHE key-exchange cert
COPY ./GeoTrust_Universal_CA.pem /usr/local/share/ca-certificates
COPY ./dhparam.pem /usr/local/share/ca-certificates
