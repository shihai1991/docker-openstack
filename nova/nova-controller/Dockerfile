FROM centos:7
MAINTAINER Hai Shi "shihai1992@gmail.com"

# The version of openstack
# Nova 13.1.4 is belong to mitaka
ENV VERSION=13.1.4

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
    && yum install -y libffi-devel python-devel openssl-dev mariadb MySQL-python vim-enhanced gcc net-tools \
    && yum install -y iptables-services

# Install pip by script
COPY get-pip.py /root/get-pip.py 
COPY upper-constraints.txt /root/upper-constraints.txt
RUN set -x \
    && python /root/get-pip.py 
# Install novnc, this package is downloaded from the yum repo of openstack-mitaka
COPY novnc-0.5.1-2.el7.noarch.rpm /root/novnc-0.5.1-2.el7.noarch.rpm
RUN rpm -ivh /root/novnc-0.5.1-2.el7.noarch.rpm --nodeps

RUN curl -fSL https://github.com/openstack/nova/archive/refs/tags/${VERSION}.tar.gz -o nova-${VERSION}.tar.gz --insecure \
    && tar xvf nova-${VERSION}.tar.gz \
    && cd nova-${VERSION} \
    && echo 'recursive-include nova *.cfg' > MANIFEST.in \
    && pip install -r requirements.txt \
    && pip install -r /root/upper-constraints.txt \
    && PBR_VERSION=${VERSION}  pip install . \
    && pip install MySQL-python \
    && cd - \
    && rm -f /var/lib/nova/nova.sqlite \
    && rm -rf nova-${VERSION}*

# Unset the proxy that you configured
ENV http_proxy=
ENV https_proxy=

# Copy sql script
COPY nova.sql /root/nova.sql
# Copy configures
COPY nova.conf /etc/nova/nova.conf
COPY api-paste.ini /etc/nova/api-paste.ini
COPY policy.json /etc/nova/policy.json
# Add bootstrap script and make it executable
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && chmod a+x /etc/bootstrap.sh

EXPOSE 8773 8774 8775 6080

ENTRYPOINT ["/etc/bootstrap.sh"]
