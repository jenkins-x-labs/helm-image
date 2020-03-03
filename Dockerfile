
FROM centos:7

RUN mkdir /out

# helm 3
ENV HELM3_VERSION 3.0.3
RUN curl -f -L https://get.helm.sh/helm-v3.0.3-linux-386.tar.gz | tar xzv && \
  mv linux-386/helm /out/

# git
ENV GIT_VERSION 2.21.1
RUN yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel && \
    yum install -y gcc perl-ExtUtils-MakeMaker make
RUN cd /usr/src  && \
    curl -LO https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz  && \
    tar xzf git-${GIT_VERSION}.tar.gz  && \
    cd git-${GIT_VERSION} && \
    make prefix=/usr/local/git all  && \
    make prefix=/usr/local/git install

# use a multi stage image so we don't include all the build tools above
FROM centos:7
# need to copy the whole git source else it doesn't clone the helm plugin repos below
COPY --from=0 /usr/local/git /usr/local/git
COPY --from=0 /usr/bin/make /usr/bin/make
COPY --from=0 /out /usr/local/bin

ENV PATH /usr/local/bin:/usr/local/git/bin:$PATH
ENV HELM_PLUGINS /root/.cache/helm/plugins/

RUN helm plugin install https://github.com/databus23/helm-diff && \
    helm plugin install https://github.com/aslafy-z/helm-git.git && \
    helm plugin install https://github.com/hayorov/helm-gcs