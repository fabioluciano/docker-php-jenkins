FROM centos:latest

MAINTAINER Fábio Luciano <fabioluciano@php.net>

ENV COMPOSER_HOME /usr/share/composer/

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
ADD http://pkg.jenkins-ci.org/redhat/jenkins.repo /etc/yum.repos.d/jenkins.repo
RUN rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

RUN yum update -y && yum install -y java jenkins dejavu-fonts-common ant wget initscripts openssl-devel && yum groupinstall 'Development Tools' -y && yum install -y php56w-common php56w-opcache php56w-mbstring php56w-opcache php56w-mcrypt php56w-intl php56w-devel php56w-gd php56w-ldap php56w-mysql php56w-pdo php56w-pgsql php56w-xml php56w-pear php56w-pecl-xdebug php56w-soap && yum clean all

COPY packages/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /tmp/
COPY packages/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm /tmp/
COPY packages/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /tmp/
RUN yum install -y /tmp/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
RUN yum install -y /tmp/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
RUN yum install -y /tmp/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm

RUN printf "\n" | pecl install oci8-2.0.11
RUN echo "extension=oci8.so" > /etc/php.d/oci8.ini

RUN printf "\n" | pecl install mongo
RUN echo "extension=mongo.so" > /etc/php.d/mongo.ini

RUN sed -i "s/^;date.timezone =$/date.timezone = \"America\/Sao_Paulo\"/" /etc/php.ini
RUN sed -i "s/^memory_limit =$/memory_limit = 1024M/" /etc/php.ini

#VOLUME ["/var/lib/jenkins", "/var/log/jenkins"]

COPY config/plugins.sh config/plugins.txt /tmp/
RUN chmod +x /tmp/plugins.sh
RUN /tmp/plugins.sh
RUN chown jenkins:jenkins -R /var/lib/jenkins/plugins

# PHP Related
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer global require phpmetrics/phpmetrics --no-progress
RUN composer global require squizlabs/php_codesniffer --no-progress
RUN composer global require phpunit/phpunit --no-progress
RUN composer global require sebastian/phpcpd --no-progress
RUN composer global require sebastian/phpdcd --no-progress
RUN composer global require pdepend/pdepend --no-progress
RUN composer global require phploc/phploc --no-progress
RUN composer global require phpmd/phpmd --no-progress
RUN composer global require theseer/phpdox --no-progress

RUN chmod a+rwx -R /usr/share/composer/cache
RUN ln -s /usr/share/composer/vendor/bin/* /usr/local/bin/

RUN install -p /var/lib/jenkins/jobs/php_template -d  -o jenkins -g jenkins
ADD https://raw.githubusercontent.com/fabioluciano/jenkins-php-builds/master/config.xml /var/lib/jenkins/jobs/php_template
RUN chown -R jenkins:jenkins /var/lib/jenkins/jobs -R

CMD /etc/init.d/jenkins start && tail -F /var/log/jenkins/jenkins.log
