FROM jed.ocir.io/axsmatigqj6i/php:7.4-apache

#install all the system dependencies and enable PHP modules
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpq-dev \
    libmcrypt-dev \
    libonig-dev \
    libzip-dev \
    libpng-dev \
    libsodium-dev \
    git \
    zip \
    unzip

RUN rm -r /var/lib/apt/lists/*
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd 
RUN docker-php-ext-install \
    intl \
    mbstring \
    # mcrypt \
    # pcntl \
    pdo_mysql \
    gd \
    zip \
    sodium \
    opcache

#install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

#set our application folder as an environment variable
ENV APP_HOME /var/www/html

#change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

#change the web_root to laravel /var/www/html/public folder
RUN sed -i -e "s/html/html\/public/g" /etc/apache2/sites-enabled/000-default.conf

# enable apache module rewrite
RUN a2enmod rewrite

#copy source files and run composer
WORKDIR $APP_HOME

COPY composer.json composer.json
COPY database database
RUN composer install --no-scripts

RUN curl -fsSL https://deb.nodesource.com/setup_15.x | bash - && \
    apt-get install -y nodejs

# Install packages.json
# COPY package.json package.json
# COPY resources resources
# COPY webpack.mix.js webpack.mix.js
# RUN npm install --no-dev \
#     && npm run prod \
#     && rm node_modules -R

COPY --chown=www-data:www-data . .

USER root
COPY start.sh /usr/local/bin/start
RUN chmod +x /usr/local/bin/start

RUN composer dumpautoload

#change ownership of our applications
# RUN chown -R www-data:www-data $APP_HOME

EXPOSE 80

CMD ["/usr/local/bin/start"]
