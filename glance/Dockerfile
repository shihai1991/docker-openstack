FROM centos:7
MAINTAINER Hai Shi "shihai1992@gmail.com"

# The version of openstack
# Glance 12.0.0 is belong to mitaka
ENV VERSION=12.0.0

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
    && yum install -y libffi-devel python-devel openssl-dev mariadb MySQL-python vim-enhanced gcc wget

# Install pip by script
COPY get-pip.py /root/get-pip.py 
COPY upper-constraints.txt /root/upper-constraints.txt
RUN set -x \
    && python /root/get-pip.py 

RUN curl -fSL https://github.com/openstack/glance/archive/refs/tags/${VERSION}.tar.gz -o glance-${VERSION}.tar.gz --insecure \
    && tar xvf glance-${VERSION}.tar.gz \
    && cd glance-${VERSION} \
    && pip install -r requirements.txt \
    && pip install -r /root/upper-constraints.txt \
    && PBR_VERSION=${VERSION}  pip install . \
    && pip install MySQL-python \
    && cd - \
    && rm -f /var/lib/glance/glance.sqlite \
    && rm -rf glance-${VERSION}*

# Unset the proxy that you configured
ENV http_proxy=
ENV https_proxy=

# Copy sql script
COPY glance.sql /root/glance.sql
# Copy configures
COPY glance-api.conf /etc/glance/glance-api.conf
COPY glance-registry.conf /etc/glance/glance-registry.conf
COPY glance-api-paste.ini /etc/glance/glance-api-paste.ini
COPY glance-registry-paste.ini /etc/glance/glance-registry-paste.ini
COPY schema-image.json /etc/glance/schema-image.json
# Add bootstrap script and make it executable
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && chmod a+x /etc/bootstrap.sh

EXPOSE 9191 9292

ENTRYPOINT ["/etc/bootstrap.sh"]
