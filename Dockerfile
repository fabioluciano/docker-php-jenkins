FROM centos:latest

MAINTAINER Fábio Luciano <fabio.goisl@ctis.com.br>

ENV JENKINS_HOME /opt/jenkins/

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

RUN yum install -y java-1.8.0-openjdk-headless dejavu-fonts-common && yum groupinstall 'Development Tools' -y && yum install -y php56w-common php56w-opcache php56w-mbstring php56w-opcache php56w-mcrypt php56w-intl php56w-devel php56w-gd php56w-ldap php56w-mysqlphp56w-pdo php56w-pgsql php56w-xml &&  yum clean all
RUN yum install php56w-pear -y && yum clean all

# PHP Related
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer global require phpmetrics/phpmetrics
RUN composer global require squizlabs/php_codesniffer
RUN composer global require phpunit/phpunit
RUN composer global require sebastian/phpcpd
RUN composer global require sebastian/phpdcd
RUN composer global require pdepend/pdepend
RUN composer global require phploc/phploc
RUN composer global require theseer/phpdox
#RUN composer global require phpdocumentor/phpdocumentor

COPY config/definepath.sh /etc/profile.d/definepath.sh

RUN mkdir -p $JENKINS_HOME
RUN adduser -Ms /bin/sh jenkins
RUN chown -R jenkins:jenkins $JENKINS_HOME

ADD http://mirrors.jenkins-ci.org/war/latest/jenkins.war $JENKINS_HOME/jenkins.war
RUN chmod 644 $JENKINS_HOME/jenkins.war

RUN mkdir -p /opt/oracle

COPY packages/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /tmp/
RUN yum install oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm

# WORKDIR /opt/oracle/
# ADD packages/instantclient.tar.gz /opt/oracle
# RUN printf "instantclient,/opt/oracle/instantclient" | pecl install oci8-2.0.11
# RUN echo "extension=oci8.so" > /etc/php.d/oci8.ini

EXPOSE 8080
