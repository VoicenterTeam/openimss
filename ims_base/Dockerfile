#beta template!
FROM debian:bullseye-slim
ARG mysqlDb
RUN apt update -y
RUN apt install -y gcc make pkg-config flex wget rsyslog
RUN apt install -y libssl1.1 libssl-dev libjansson4 apt-utils
RUN apt install -y git jq jo pv libncurses5-dev libhiredis-dev libpcre3-dev 
RUN apt install -y libjsoncpp-dev libxml2-dev libxml2-doc uuid-dev bison
RUN apt install -y make gcc flex libjson-c-dev libmicrohttpd-dev 
RUN apt install -y librabbitmq4 librabbitmq-dev amqp-tools libssl-dev curl 
RUN apt install -y libcurl4-openssl-dev snmp libsnmp-dev snmpd gpg cmake
RUN apt install -y git autoconf openssl build-essential automake
RUN apt install -y python3 python3-pip python3-dev whiptail redis-server ngrep sngrep nano vim locate net-tools
RUN apt install -y libfreediameter-dev
#
ARG DEBIAN_FRONTEND=noninteractive
ARG osBldUsr
ARG osBldPswd
ARG osBldBrnch
ARG CACHEBUST=1
RUN git clone -b 3.4 https://github.com/OpenSIPS/opensips.git  /opt/opensips
COPY s.cast.int.patch /tmp
#
WORKDIR /opt/opensips
RUN patch -p1 < /tmp/s.cast.int.patch && rm /tmp/s.cast.int.patch
#COPY Makefile.conf starter.sh opensips_configurator.sh ./
COPY  starter.sh  ./
#Add Template dir to /opt/opensips.
COPY templates /opt/opensips/templates
#COPY opensips_configurator.sh mysql_setup /opt/opensips/voicenter_deploy/
#
#RUN chmod +x /opt/opensips/starter.sh && chmod +x /opt/opensips/voicenter_deploy/mysql_setup && chmod +x /opt/opensips/voicenter_deploy/opensips_configurator.sh
#RUN mv /opt/opensips/voicenter_deploy /opt/
#RUN ln -s /opt/voicenter_deploy/opensips_configurator.sh /usr/bin/opensips_configurator && /opt/voicenter_deploy/mysql_setup
#
#RUN apt install -y libjwt-dev libmysqlclient-dev mysql-server
RUN apt install -y libjwt-dev default-libmysqlclient-dev
RUN if [ "$mysqlDb" = "enabled" ] ; then apt install -y mysql-server ; else echo "MYSQL setup skipped!" ; fi
#oSips-console compile:
RUN git clone -b master https://github.com/OpenSIPS/opensips-cli.git /opt/opensips-cli
RUN cd /opt/opensips-cli && pip3 install --upgrade pip 
RUN cd /opt/opensips-cli && pip3 install mysqlclient sqlalchemy sqlalchemy-utils pyOpenSSL 
RUN cd /opt/opensips-cli && python3 setup.py install clean
#oSips compile:
RUN make
RUN make proper
RUN make prefix=/ include_modules="aaa_diameter db_mysql json httpd prometheus tls_mgm tls_openssl" install
RUN mkdir -p /run/opensips/ | true
# RUN cd /opt/opensips/deploy_scripts/opensips/rabbitmq-c-0.9.0 && mkdir -p build
# RUN cd /opt/opensips/deploy_scripts/opensips/rabbitmq-c-0.9.0/build && cmake ..
# RUN cd /opt/opensips/deploy_scripts/opensips/rabbitmq-c-0.9.0/build && cmake --build . --target install
# RUN echo "/usr/local/lib/x86_64-linux-gnu/" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf
# RUN ldconfig
#
#RUN cd /opt/opensips/deploy_scripts/opensips && cp opensips-m4cfg /sbin/ && cp -rf tls /etc/opensips/
#COPY mo /usr/bin/
#RUN chmod +x /usr/bin/mo
#COPY dkrCfgs/extension_proxy.mustache mysql_preinstall.mustache /opt/voicenter_deploy/extension_proxy/
#COPY dkrCfgs /opt/voicenter_deploy/dkrCfgs/
#must have for a start:
ENTRYPOINT ["/bin/bash", "-c", "./starter.sh"]
