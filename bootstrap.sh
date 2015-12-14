#!/usr/bin/env bash

# APT
echo "Updating system (apt)..."
apt-get update > /dev/null 2>&1
apt-get upgrade > /dev/null 2>&1

# Set timezone.
echo "Setting up timezone..."
echo "Europe/Copenhagen" > /etc/timezone
/usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1

# Set locale
echo "Setting up locale..."
echo en_GB.UTF-8 UTF-8 > /etc/locale.gen
echo en_DK.UTF-8 UTF-8 >> /etc/locale.gen
echo da_DK.UTF-8 UTF-8 >> /etc/locale.gen
/usr/sbin/locale-gen > /dev/null 2>&1
export LANGUAGE=en_DK.UTF-8 > /dev/null 2>&1
export LC_ALL=en_DK.UTF-8 > /dev/null 2>&1
echo "locales locales/locales_to_be_generated multiselect da_DK.UTF-8 UTF-8, en_DK.UTF-8 UTF-8, en_GB.UTF-8 UTF-8" | debconf-set-selections
/usr/sbin/dpkg-reconfigure --frontend noninteractive locales > /dev/null 2>&1

# Drush
echo "Installing drush..."
apt-get install -y php-pear unzip > /dev/null 2>&1
pear channel-discover pear.drush.org > /dev/null 2>&1
pear install drush/drush > /dev/null 2>&1
drush version > /dev/null 2>&1

# Apache config
echo "Configuring Apache..."
apt-get -y install git php5-mysql libapache2-mod-php5 php5-gd php-db apache2 php5-curl php5-dev php5-xdebug > /dev/null 2>&1
rm -rf /var/www
ln -s /vagrant/htdocs /var/www
sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default
sed -i '/export APACHE_RUN_USER=www-data/c export APACHE_RUN_USER=vagrant' /etc/apache2/envvars
sed -i '/export APACHE_RUN_GROUP=www-data/c export APACHE_RUN_GROUP=vagrant' /etc/apache2/envvars
sed -i '/memory_limit = 128M/c memory_limit = 512M' /etc/php5/apache2/php.ini
chown vagrant:vagrant /var/lock/apache2
a2enmod rewrite > /dev/null 2>&1
a2enmod php5 > /dev/null 2>&1
a2enmod expires > /dev/null 2>&1

# Configura PHP
echo "Configuring up PHP..."
sed -i '/memory_limit = 128M/c memory_limit = 512M' /etc/php5/apache2/php.ini
sed -i '/;date.timezone =/c date.timezone = Europe\/Copenhagen' /etc/php5/apache2/php.ini
sed -i '/;date.timezone =/c date.timezone = Europe\/Copenhagen' /etc/php5/cli/php.ini
sed -i '/upload_max_filesize = 2M/c upload_max_filesize = 16M' /etc/php5/apache2/php.ini
sed -i '/post_max_size = 8M/c post_max_size = 20M' /etc/php5/apache2/php.ini
sed -i '/;realpath_cache_size = 16k/c realpath_cache_size = 256k' /etc/php5/apache2/php.ini

cat << DELIM >> /etc/php5/conf.d/20-xdebug.ini
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_host=192.168.50.1
xdebug.remote_port=9000
xdebug.remote_autostart=0
DELIM

pecl install uploadprogress > /dev/null 2>&1
echo "extension=uploadprogress.so" > /etc/php5/conf.d/uploadprogress.ini

# Mysql
echo "Installing MySQL..."
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password vagrant' > /dev/null 2>&1
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password vagrant' > /dev/null 2>&1
apt-get install -y mysql-server > /dev/null 2>&1

# Configure MySQL
echo "Configuring MySQL..."
cat > /etc/mysql/conf.d/innodb.cnf <<DELIM
[mysqld]
innodb_buffer_pool_size=256M
innodb_flush_method=O_DIRECT
innodb_additional_mem_pool_size=10M
innodb_flush_log_at_trx_commit=0
innodb_thread_concurrency=6
DELIM

# Memcache
echo "Installing MemCached"
apt-get install -y memcached php5-memcached > /dev/null 2>&1

# APC
echo "Configuring APC"
apt-get install -y php-apc > /dev/null 2>&1
cat > /etc/php5/conf.d/apc.ini <<DELIM
apc.enabled=1
apc.shm_segments=1
apc.optimization=0
apc.shm_size=128M
apc.ttl=7200
apc.user_ttl=7200
apc.num_files_hint=1024
apc.mmap_file_mask=/tmp/apc.XXXXXX
apc.enable_cli=1
apc.cache_by_default=1
DELIM

# Restart services
echo "Restarting services..."
service apache2 restart > /dev/null 2>&1
service mysql restart > /dev/null 2>&1
service memcached restart > /dev/null 2>&1

echo "Provisioning completed..."
