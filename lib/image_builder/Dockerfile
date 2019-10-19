FROM marketplace.gcr.io/google/ubuntu1804:latest

# from https://docs.docker.com/install/linux/docker-ce/ubuntu/ : (plus make)
ENV APT_INSTALL_FLAGS "-y -qq --no-install-recommends"
RUN apt-get update && \
apt-get install $APT_INSTALL_FLAGS \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    make \
    jq && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" && \
apt-get update && \
apt-get install $APT_INSTALL_FLAGS docker-ce docker-ce-cli containerd.io || \
{ echo "ERROR: FAILED to install make and/or docker" >&2; exit 1; }

# BELOW here is stuff that's only necessary if you're running the whole build in the image builder container, as opposed to just the passenger phusion images
RUN apt-get install $APT_INSTALL_FLAGS git

