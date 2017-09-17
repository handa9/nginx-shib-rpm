FROM centos:7
MAINTAINER "Mitsuru Nakakawaji" <mitsuru@procube.jp>
RUN groupadd -g 111 builder
RUN useradd -g builder -u 111 builder
ENV HOME /home/builder
WORKDIR ${HOME}
ENV NGINX_VERSION "1.12.1-1"
RUN yum -y update \
    && yum -y install unzip wget sudo lsof openssh-clients telnet bind-utils tar tcpdump vim initscripts \
        gcc openssl-devel zlib-devel pcre-devel lua lua-devel rpmdevtools make deltarpm \
        perl-devel perl-ExtUtils-Embed GeoIP-devel libxslt-devel gd-devel which
RUN mkdir -p /tmp/buffer
COPY core.patch shibboleth.patch nginx.spec.patch nginx.conf.patch /tmp/buffer/
USER builder
RUN mkdir -p ${HOME}/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo "%_topdir %(echo ${HOME})/rpmbuild" > ${HOME}/.rpmmacros
RUN cp /tmp/buffer/* ${HOME}/rpmbuild/SOURCES/
RUN wget -O rpmbuild/SOURCES/ngx_devel_kit-0.2.19.tar.gz https://github.com/simpl/ngx_devel_kit/archive/v0.2.19.tar.gz
RUN wget -O rpmbuild/SOURCES/lua-nginx-module-0.10.9rc5.tar.gz https://github.com/openresty/lua-nginx-module/archive/v0.10.9rc5.tar.gz
RUN wget -O rpmbuild/SOURCES/nginx-goodies-nginx-sticky-module-ng-08a395c66e42.tar.gz https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/08a395c66e42.tar.gz
RUN wget -O rpmbuild/SOURCES/nginx-http-shibboleth-2.0.0.tar.gz https://github.com/nginx-shib/nginx-http-shibboleth/archive/v2.0.0.tar.gz
RUN wget -O rpmbuild/SOURCES/headers-more-nginx-module-0.32.tar.gz https://github.com/openresty/headers-more-nginx-module/archive/v0.32.tar.gz
RUN mkdir ${HOME}/srpms \
    && cd srpms \
    && wget https://nginx.org/packages/centos/7/SRPMS/nginx-${NGINX_VERSION}.el7.ngx.src.rpm \
    && rpm -ivh ${HOME}/srpms/nginx-${NGINX_VERSION}.el7.ngx.src.rpm
RUN cd rpmbuild/SPECS \
    && patch -p 1 nginx.spec < ../SOURCES/nginx.spec.patch
RUN cd rpmbuild/SOURCES \
    && patch < nginx.conf.patch
CMD ["/usr/bin/rpmbuild","-bb","rpmbuild/SPECS/nginx.spec"]
