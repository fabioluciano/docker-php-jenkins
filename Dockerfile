FROM centos:latest

MAINTAINER Fábio Luciano <fabio.goisl@ctis.com.br>

ENV COMPOSER_HOME /usr/share/composer/

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
ADD http://pkg.jenkins-ci.org/redhat/jenkins.repo /etc/yum.repos.d/jenkins.repo
RUN rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

RUN yum install -y java jenkins dejavu-fonts-common ant wget initscripts && yum groupinstall 'Development Tools' -y && yum install -y php56w-common php56w-opcache php56w-mbstring php56w-opcache php56w-mcrypt php56w-intl php56w-devel php56w-gd php56w-ldap php56w-mysql php56w-pdo php56w-pgsql php56w-xml php56w-pear &&  yum clean all

COPY packages/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /tmp/
COPY packages/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm /tmp/
COPY packages/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /tmp/
RUN yum install -y /tmp/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
RUN yum install -y /tmp/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
RUN yum install -y /tmp/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm

RUN printf "\n" | pecl install oci8-2.0.11
RUN echo "extension=oci8.so" > /etc/php.d/oci8.ini

#VOLUME ["/var/lib/jenkins", "/var/log/jenkins"]

COPY config/plugins.sh config/plugins.txt /tmp/
RUN chmod +x /tmp/plugins.sh
RUN /tmp/plugins.sh
RUN chown jenkins:jenkins -R /var/lib/jenkins/plugins

# PHP Related
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer global require phpmetrics/phpmetrics
RUN composer global require squizlabs/php_codesniffer
RUN composer global require phpunit/phpunit
RUN composer global require sebastian/phpcpd
RUN composer global require sebastian/phpdcd
RUN composer global require pdepend/pdepend
RUN composer global require phploc/phploc
RUN composer global require phpmd/phpmd
RUN composer global require theseer/phpdox
#RUN composer global require phpdocumentor/phpdocumentor

RUN ln -s /usr/share/composer/vendor/bin/* /usr/local/bin/

RUN install -p /var/lib/jenkins/jobs/php_template -d  -o jenkins -g jenkins
ADD https://raw.github.com/sebastianbergmann/php-jenkins-template/master/config.xml /var/lib/jenkins/jobs/php_template
RUN chown -R jenkins:jenkins /var/lib/jenkins/jobs -R

CMD /etc/init.d/jenkins start && tail -F /var/log/jenkins/jenkins.log
