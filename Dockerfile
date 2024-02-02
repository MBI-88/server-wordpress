# Usar Ubuntu como imagen base
FROM ubuntu:latest

# Evitar mensajes de error de frontend durante la instalación de paquetes
ARG DEBIAN_FRONTEND=noninteractive

# Actualizar e instalar dependencias
RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    php-mysql \
    libapache2-mod-php \
    wget \
    mysql-server \
    && rm -rf /var/lib/apt/lists/*

# Configurar MySQL
ENV MYSQL_ROOT_PASSWORD=12345
ENV MYSQL_DATABASE=wordpress
ENV MYSQL_USER=wordpress
ENV MYSQL_PASSWORD=12345

ENV WORDPRESS_DB_HOST=localhost:3306
ENV WORDPRESS_DB_USER=wordpress
ENV WORDPRESS_DB_PASSWORD=12345
ENV WORDPRESS_DB_NAME=wordpress

RUN mkdir -p /var/run/mysqld \
    && chown mysql:mysql /var/run/mysqld \
    # Iniciar MySQL en segundo plano para configuración inicial
    && (/usr/bin/mysqld_safe & sleep 10) \
    # Configurar la contraseña de root y crear la base de datos y el usuario de WordPress
    && mysqladmin password "${MYSQL_ROOT_PASSWORD}" \
    && mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};" \
    && mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';" \
    && mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';" \
    && mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"


RUN rm /var/www/html/*.html

# Descargar e instalar WordPress
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /tmp/ \
    && mv /tmp/wordpress/* /var/www/html/ \
    && rm /tmp/wordpress.tar.gz \
    && chown -R www-data:www-data /var/www/html \
    && a2enmod rewrite

# Configurar Apache para servir WordPress
COPY wordpress.conf /etc/apache2/sites-available/wordpress.conf

# Copiar el script de inicio
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80


CMD ["/start.sh"]