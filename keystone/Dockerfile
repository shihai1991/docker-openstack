FROM centos:7
MAINTAINER Hai Shi "shihai1992@gmail.com"

# The version of openstack
# Keystone 9.3.0 is belong to mitaka
ENV VERSION=9.3.0

# Config a proxy in China, because we have the Great Wall.
#ENV USERDOMAIN=CHINA
#ENV http_proxy="Pls input your proxy"
#ENV https_proxy="Pls input your proxy"

# Config yum repo
RUN set -x \
    && rm -rf /etc/yum.repos.d/*.repo \
    && curl http://mirrors.163.com/.help/CentOS7-Base-163.repo -o /etc/yum.repos.d/CentOS7-Base-163.repo \
    && yum makecache

RUN set -x \
    && yum install -y libffi-devel python-devel openssl-dev mariadb MySQL-python vim-enhanced gcc

# Install pip by script
COPY get-pip.py /root/get-pip.py 
COPY upper-constraints.txt /root/upper-constraints.txt
RUN set -x \
    && python /root/get-pip.py 

RUN curl -fSL https://github.com/openstack/keystone/archive/refs/tags/${VERSION}.tar.gz -o keystone-${VERSION}.tar.gz --insecure \
    && tar xvf keystone-${VERSION}.tar.gz \
    && cd keystone-${VERSION} \
    && pip install -r requirements.txt \
    && pip install -r /root/upper-constraints.txt \
    && PBR_VERSION=${VERSION}  pip install . \
    && pip install uwsgi MySQL-python \
    && cp -r etc /etc/keystone \
    && cd - \
    && rm -rf keystone-${VERSION}*

# Unset the proxy that you configured
ENV http_proxy=
ENV https_proxy=

COPY keystone.conf /etc/keystone/keystone.conf
COPY keystone.sql /root/keystone.sql

# Add bootstrap script and make it executable
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && chmod a+x /etc/bootstrap.sh

ENTRYPOINT ["/etc/bootstrap.sh"]
EXPOSE 5000 35357

HEALTHCHECK --interval=10s --timeout=5s \
  CMD curl -f http://localhost:5000/v3 2> /dev/null || exit 1; \
  curl -f http://localhost:35357/v3 2> /dev/null || exit 1; \
