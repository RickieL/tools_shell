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

yum install -y make  gcc gcc-c++ zlib-devel pcre-devel

# 将所有软件包复制到源文件src目录
cp -rf Packages/* /opt/app/src

# 安装libunwind [TCMalloc的依赖包,安装gperftools时需要]
cd /opt/app/src
tar zxf libunwind-1.1.tar.gz
cd libunwind-1.1
./configure
make
make install
cd ..
rm -rf libunwind-1.1

# 安装gperftools [google开发的，gperftools对nginx与mysql进行内存管理、性能优化、降低负载]
cd /opt/app/src
tar zxf gperftools-2.0.tar.gz
cd gperftools-2.0
./configure --enable-frame-pointers
make
make install
cd ..
rm -rf gperftools-2.0

# 使系统加载库文件
echo -e "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
/sbin/ldconfig

# 安装nginx
cd /opt/app/src
tar zxf nginx-1.4.1.tar.gz
cd nginx-1.4.1
./configure --prefix=/opt/app/nginx --with-google_perftools_module  --without-http_memcached_module --user=www --group=www --with-http_stub_status_module --with-pcre=/opt/app/src/pcre-8.32
make
make install
chmod  777 /tmp/tcmalloc -R
/opt/app/nginx/sbin/nginx
cp /opt/app/src/etc/nginx  /etc/rc.d/init.d/nginx
chmod 775 /etc/rc.d/init.d/nginx
chkconfig nginx on
/etc/rc.d/init.d/nginx restart

# 优化的默认配置
/bin/cp /opt/app/src/etc/nginx.conf  /opt/app/nginx/conf/nginx.conf
/bin/cp /opt/app/src/etc/rewrite.conf  /opt/app/nginx/conf/rewrite.conf
/bin/cp /opt/app/src/etc/mime.types  /opt/app/nginx/conf/mime.types
/bin/cp /opt/app/src/etc/fcgi.conf /opt/app/nginx/conf/fcgi.conf
/bin/cp /opt/app/src/etc/localhost.conf /opt/app/nginx/conf/vhost/localhost.conf

cd /opt/app/src
rm -rf nginx-1.4.1

# nginx测试文件
cd /opt/app/nginx/html/
rm -rf /opt/app/nginx/html/*
/bin/cp /opt/app/src/etc/index.php  /opt/app/nginx/html/index.php
/bin/cp /opt/app/src/etc/gd.php  /opt/app/nginx/html/gd.php
/bin/cp /opt/app/src/etc/server.php  /opt/app/nginx/html/server.php
/bin/cp /opt/app/src/etc/phpinfo.php  /opt/app/nginx/html/phpinfo.php
chown www.www /opt/app/nginx/html/ -R
chmod 700 /opt/app/nginx/html/ -R
