#!/bin/sh

# 创建用户
groupadd mysql  -g 27
useradd -g mysql mysql  -u 27 -s /bin/false
groupadd www  -g 600
useradd -g www www  -u 600 -s /bin/false

# 创建目录
mkdir -p /opt/app/src
mkdir -p /opt/app/pcre
mkdir -p /data/mysql
mkdir -p /var/lib/mysql
mkdir -p /opt/app/mysql
chown -R mysql:mysql /data/mysql

mkdir -p /tmp/tcmalloc
mkdir -p /opt/app/php5
mkdir -p /opt/app/nginx/conf/vhost
mkdir -p /tmp/phpsession
chown -R 777 /tmp/phpsession

# 一键安装脚本的 依赖包
yum install -y make  autoconf automake curl curl-devel gcc gcc-c++ zlib-devel openssl openssl-devel pcre-devel keyutils perl compat-glibc compat-glibc-headers  cpp glibc libgomp libstdc++-devel keyutils-libs-devel libsepol-devel libselinux-devel krb5-devel gd freetype freetype-devel fontconfig fontconfig-devel  libjpeg libjpeg-devel libpng libpng-devel gettext gettext-devel ncurses ncurses-devel libtool libtool-ltdl libtool-ltdl-devel libxml2 libxml2-devel patch policycoreutils bison gmp gmp-devel

# 将所有软件包复制到源文件src目录
cp -rf Packages/* /opt/app/src

# 安装libmcrypt [php的依赖软件]
cd /opt/app/src
tar zxf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make
make install
cd ..
rm -rf libmcrypt-2.5.8

# re2c [安装php时依赖]
cd /opt/app/src
tar -zxf re2c-0.13.5.tar.gz
cd re2c-0.13.5
./configure
make
make install
cd ..
rm -rf re2c-0.13.5

# 使系统加载库文件
echo -e "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
/sbin/ldconfig


# 安装php
cd /opt/app/src
tar -zxf php-5.3.25.tar.gz
cd php-5.3.25
./configure --prefix=/opt/app/php5 --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-gd --with-png-dir=/usr --with-jpeg-dir=/usr --with-freetype-dir=/usr --with-zlib --with-curlwrappers --with-gettext --with-openssl --with-mcrypt --with-curl --with-libxml-dir=/usr --with-gmp --with-xmlrpc  --with-libdir=lib64 --enable-bcmath --enable-shmop  --enable-fpm --enable-mbstring --enable-gd-native-ttf --enable-exif --enable-pcntl --enable-sockets --enable-zip --enable-soap  --enable-sysvmsg --enable-sysvshm --enable-sysvsem --without-sqlite --without-pear --disable-phar
make
make install
/bin/cp /opt/app/src/etc/php.ini /opt/app/php5/lib/php.ini
/bin/cp /opt/app/src/etc/php-fpm.conf /opt/app/php5/etc/php-fpm.conf
/bin/cp ./sapi/fpm/init.d.php-fpm  /etc/rc.d/init.d/php-fpm
chmod +x /etc/rc.d/init.d/php-fpm
chkconfig php-fpm on
mkdir -p /opt/app/php5/log

# 优化的默认配置
touch /dev/shm/php.socket
chown www.www /dev/shm/php.socket

# php扩展 memcache
cd /opt/app/src
tar zxf memcache-2.2.6.tgz
cd memcache-2.2.6
/opt/app/php5/bin/phpize
./configure --with-php-config=/opt/app/php5/bin/php-config
make
make install

# php扩展 redis
cd /opt/app/src
tar zxf phpredis-master.tar.gz
cd phpredis-master
/opt/app/php5/bin/phpize
./configure --with-php-config=/opt/app/php5/bin/php-config
make
make install

# php扩展 apc
cd /opt/app/src
tar zxf APC-3.1.6.tgz
cd APC-3.1.6
/opt/app/php5/bin/phpize
./configure  --enable-apc --enable-apc-mmap --enable-apc-spinlocks --with-php-config=/opt/app/php5/bin/php-config
make
make install

# php扩展 xdebug
cd /opt/app/src
tar zxf xdebug-2.2.2.tgz
cd xdebug-2.2.2
/opt/app/php5/bin/phpize
./configure --enable-xdebug --with-php-config=/opt/app/php5/bin/php-config
make
make install

cd ..
rm -rf php-5.3.25
rm -rf memcache-2.2.6 phpredis-master APC-3.1.6 xdebug-2.2.2
