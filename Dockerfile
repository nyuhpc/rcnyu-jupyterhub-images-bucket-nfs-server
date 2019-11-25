FROM ubuntu:18.04
RUN apt-get -y install /usr/bin/ps nfs-utils && apt-get clean
RUN mkdir -p /exports
ADD setup.sh /usr/local/bin/run_nfs.sh
RUN chmod +x /usr/local/bin/run_nfs.sh

#############################################################################
#### Setup gsfuse
## https://github.com/GoogleCloudPlatform/gcsfuse/blob/master/docs/installing.md

ENV GCSFUSE_REPO=gcsfuse-bionic
RUN echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN apt-get update
RUN apt-get install -y gcsfuse

#Add yourself to the fuse group, then log out and back in:
RUN usermod -a -G fuse $USER
#############################################################################

# Expose volume
VOLUME /exports

# expose mountd 20048/tcp and nfsd 2049/tcp and rpcbind 111/tcp
#EXPOSE 2049/tcp 20048/tcp 111/tcp 111/udp
EXPOSE 2049/tcp 20048/tcp 111/tcp

ENTRYPOINT ["/usr/local/bin/run_nfs.sh"]

CMD ["/exports"]
