FROM ubuntu:latest
MAINTAINER Gayatri S Ajith gayatri@schogini.com
RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d
# COPY installm2.sh /usr/local/bin/

# Get the libraries needed to setup the environment for Magento2
# RUN chmod u+x /usr/local/bin/installm2.sh && \ 
RUN apt update && apt -y install apache2 && \ 
    apt-get update && apt-get install -y \
    nano wget tar git php7.0 php7.0-fpm php7.0-mysql libapache2-mod-php php-mcrypt \
    php-zip php-curl php-soap php-intl php-mcrypt php-bcmath php-gd php-xml \
    php-json php-common php-mbstring php-opcache php-readline

# Setup composer
RUN php -r "copy('https://getcomposer.org/installer', '/var/www/composer-setup.php');" && \
    php -r "if (hash_file('SHA384', '/var/www/composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('/var/www/composer-setup.php'); } echo PHP_EOL;" && \
    php /var/www/composer-setup.php && \
    php -r "unlink('/var/www/composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# Setup MySQL and create a database
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mysql-server mysql-server/root_password password madad123'"] 
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password madad123'"]
RUN apt-get install mysql-server -y && \
    a2enmod rewrite && \
    sed -ie '/Directory \/var\/www/{;N;N;s/None/All/;}' /etc/apache2/apache2.conf 

# Create the database
RUN service mysql start && \
    mysql -u root -pmadad123 -e "create database db_madad" && \ 
    apt-get clean

# Expose the ports for the host to map
EXPOSE 80 443 3306

RUN ["/bin/bash", "-c", "echo '#!/bin/sh' > /usr/local/bin/installm2.sh && echo 'service mysql restart && service apache2 restart && exec \"$@\"' > /usr/local/bin/installm2.sh && chmod u+x /usr/local/bin/installm2.sh"]

ENTRYPOINT ["/usr/local/bin/installm2.sh"]
CMD ["/bin/bash"]
