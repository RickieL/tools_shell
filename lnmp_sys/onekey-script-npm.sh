#!/bin/sh

PwdPath=$(pwd)

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
cp -r Packages/* /opt/app/src


# 安装mysql
chmod +x $PwdPath/install-mysql-5.6.sh
$PwdPath/install-mysql-5.6.sh 1script 1>/tmp/install.mysql.log 2>/tmp/install.mysql.err

# 安装nginx
chmod +x $PwdPath/install-nginx.sh
$PwdPath/install-nginx.sh 1script 1>/tmp/install.nginx.log 2>/tmp/install.nginx.err

# 安装php
chmod +x $PwdPath/install-php-5.3.sh
$PwdPath/install-php-5.3.sh  1script 1>/tmp/install.php.log 2>/tmp/install.php.err

