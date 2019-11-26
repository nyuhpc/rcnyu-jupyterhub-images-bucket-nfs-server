FROM ubuntu:18.04

RUN apt-get -y update
RUN apt-get install -y gnupg curl nfs-common nfs-kernel-server vim

## timeZone setup
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/New_York
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
RUN apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata

#############################################################################
#### Setup gsfuse
## https://github.com/GoogleCloudPlatform/gcsfuse/blob/master/docs/installing.md

## account key path (make sure secreat is created and mounted)
ENV GOOGLE_APPLICATION_CREDENTIALS=/accounts/key.json

ENV GCSFUSE_REPO=gcsfuse-bionic
RUN echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN apt-get update
RUN apt-get install -y gcsfuse
#############################################################################

RUN mkdir -p /exports
ADD setup.sh /usr/local/bin/run_nfs.sh
RUN chmod +x /usr/local/bin/run_nfs.sh

# Expose volume
VOLUME /exports

# expose mountd 20048/tcp and nfsd 2049/tcp and rpcbind 111/tcp
## 111/udp allows for changes in files, made from jupyter notebook, to be propagaged to bucket
EXPOSE 2049/tcp 20048/tcp 111/tcp 111/udp
#EXPOSE 2049/tcp 20048/tcp 111/tcp

ENTRYPOINT ["/usr/local/bin/run_nfs.sh"]

CMD ["/exports"]
