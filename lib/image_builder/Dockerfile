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

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y
