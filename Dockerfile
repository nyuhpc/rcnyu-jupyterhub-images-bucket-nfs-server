FROM ubuntu:18.04

RUN apt-get -y update
RUN apt-get install -y gnupg curl nfs-common nfs-kernel-server

#############################################################################
############################################################################
RUN apt-get install -y git
#### Setup gcloud
# https://cloud.google.com/sdk/docs/downloads-apt-get
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN apt-get install -y apt-transport-https ca-certificates
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install -y google-cloud-sdk
RUN apt-get install -y kubectl

############################################################################
## Install and Init HELM client 
## (version shall match that on helm tiller)
RUN curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash -s -- --version v2.16.1
RUN helm init --client-only
## add helm chart repo
RUN helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
RUN helm repo update
#############################################################################
#############################################################################

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
#EXPOSE 2049/tcp 20048/tcp 111/tcp 111/udp
EXPOSE 2049/tcp 20048/tcp 111/tcp

ENTRYPOINT ["/usr/local/bin/run_nfs.sh"]

CMD ["/exports"]
