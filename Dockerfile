FROM centos
RUN yum -y install /usr/bin/ps nfs-utils && yum clean all
RUN mkdir -p /exports
ADD setup.sh /usr/local/bin/run_nfs.sh
RUN chmod +x /usr/local/bin/run_nfs.sh
ADD gcsfuse.repo /etc/yum.repos.d/gcsfuse.repo
RUN yum update -y
RUN yum install gcsfuse -y

# Expose volume
VOLUME /exports

# expose mountd 20048/tcp and nfsd 2049/tcp and rpcbind 111/tcp
#EXPOSE 2049/tcp 20048/tcp 111/tcp 111/udp
EXPOSE 2049/tcp 20048/tcp 111/tcp

ENTRYPOINT ["/usr/local/bin/run_nfs.sh"]

CMD ["/exports"]
