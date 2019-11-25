FROM ubuntu:18.04
RUN apt-get -y install /usr/bin/ps nfs-utils && apt-get clean
RUN mkdir -p /exports
ADD setup.sh /usr/local/bin/run_nfs.sh
RUN chmod +x /usr/local/bin/run_nfs.sh
ADD gcsfuse.repo /etc/yum.repos.d/gcsfuse.repo
RUN apt-get update -y
RUN apt-get install gcsfuse -y

# Expose volume
VOLUME /exports

# expose mountd 20048/tcp and nfsd 2049/tcp and rpcbind 111/tcp
#EXPOSE 2049/tcp 20048/tcp 111/tcp 111/udp
EXPOSE 2049/tcp 20048/tcp 111/tcp

ENTRYPOINT ["/usr/local/bin/run_nfs.sh"]

CMD ["/exports"]
