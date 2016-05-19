FROM centos:latest

MAINTAINER Fábio Luciano <fabio.goisl@ctis.com.br>

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
ADD http://pkg.jenkins-ci.org/redhat/jenkins.repo /etc/yum.repos.d/jenkins.repo
RUN rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

RUN yum install -y java jenkins dejavu-fonts-common && yum groupinstall 'Development Tools' -y && yum install -y php56w-common php56w-opcache php56w-mbstring php56w-opcache php56w-mcrypt php56w-intl php56w-devel php56w-gd php56w-ldap php56w-mysqlphp56w-pdo php56w-pgsql php56w-xml &&  yum clean all
RUN yum install initscripts php56w-pear -y && yum clean all

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

COPY packages/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /tmp/
COPY packages/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm /tmp/
COPY packages/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /tmp/
RUN yum install -y /tmp/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
RUN yum install -y /tmp/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
RUN yum install -y /tmp/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm

RUN printf "\n" | pecl install oci8-2.0.11
RUN echo "extension=oci8.so" > /etc/php.d/oci8.ini

RUN chkconfig jenkins on

VOLUME ["/var/lib/jenkins", "/var/log/jenkins"]

EXPOSE 8080
