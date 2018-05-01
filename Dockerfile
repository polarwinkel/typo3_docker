FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

USER root

LABEL maintainer="it@polarwinkel.de"

ARG TYPO3_VERSION=7

#RUN apt-get update && apt-get install --assume-yes apt-utils
RUN apt-get update && apt-get install --no-install-recommends -y nginx php-fpm graphicsmagick wget
RUN apt-get update && apt-get install --no-install-recommends -y openssl php-gd php-xml php-mysql php-zip php-soap

# Configure extensions
RUN echo 'always_populate_raw_post_data = -1' >> /etc/php/7.0/fpm/php.ini && \
    echo 'max_execution_time = 240' >> /etc/php/7.0/fpm/php.ini && \
    echo 'max_input_vars = 1500' >> /etc/php/7.0/fpm/php.ini && \
    echo 'post_max_size = 32M' >> /etc/php/7.0/fpm/php.ini && \
    echo 'post_max_size = 32M' >> /etc/php/7.0/fpm/php.ini

#COPY index.html /var/www/html/
COPY default /etc/nginx/sites-available/
RUN rm /var/www/html/*
VOLUME /var/www/html/fileadmin
VOLUME /var/www/html/typo3conf
VOLUME /var/www/html/uploads

RUN wget --content-disposition --no-check-certificate https://get.typo3.org/$TYPO3_VERSION && \
    tar -xzf typo3_src-* -C /var/www/ && \
    mv /var/www/typo3_src-* /var/www/typo3_src
WORKDIR /var/www/html/
RUN ln -s ../typo3_src/ typo3_src && \
    ln -s typo3_src/typo3/ typo3 && \
    ln -s typo3_src/index.php index.php && \
    touch /var/www/html/FIRST_INSTALL
RUN chown -R www-data /var/www/

WORKDIR /
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN echo "#!/bin/sh\n" >> run.sh
RUN echo "service php7.0-fpm start\n" >> /run.sh 
RUN echo "nginx\n" >> /run.sh && chmod +x /run.sh

CMD ["./run.sh"]
#CMD service php7.0-fpm start && nginx

EXPOSE 80
EXPOSE 443
