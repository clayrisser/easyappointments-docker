FROM php:8.4-apache

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && install-php-extensions gd gettext intl ldap mysqli pdo_mysql zip \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www/html

ARG EASYAPPOINTMENTS_VERSION
RUN curl -fsSL "https://github.com/alextselegidis/easyappointments/releases/download/${EASYAPPOINTMENTS_VERSION}/easyappointments-${EASYAPPOINTMENTS_VERSION}.zip" \
        -o /tmp/easyappointments.zip \
    && unzip -q -o /tmp/easyappointments.zip -d /var/www/html \
    && rm /tmp/easyappointments.zip \
    && chown -R www-data:www-data /var/www/html

COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --start-interval=2s --retries=3 \
    CMD curl -fsS -o /dev/null http://localhost/index.php || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
