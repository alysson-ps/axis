FROM ubuntu/apache2

# install dependencies
RUN apt update && apt install iproute2 wget php openssh-server git php-xml php-gd php-mbstring php-curl unzip sudo -y

# install composer
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet
RUN mv composer.phar /usr/bin/composer