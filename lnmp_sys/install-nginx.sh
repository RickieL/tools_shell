#!/bin/sh

OneSpt=$1
SrcDir=/opt/app/src
if [ "x$OneSpt" != "x1script" ] ;then
# 创建用户
groupadd mysql  -g 27
useradd -g mysql mysql  -u 27 -s /bin/false
groupadd www  -g 600
useradd -g www www  -u 600 -s /bin/false

# 创建目录
mkdir -p $SrcDir
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

# 依赖包
yum install -y make  gcc gcc-c++ zlib-devel pcre-devel

# 将所有软件包复制到源文件src目录
cp -rf Packages/* $SrcDir

fi

# 安装libunwind [TCMalloc的依赖包,安装gperftools时需要]
cd $SrcDir
tar zxf libunwind-1.1.tar.gz
cd libunwind-1.1
./configure
make
make install

# 安装gperftools [google开发的，gperftools对nginx与mysql进行内存管理、性能优化、降低负载]
cd $SrcDir
tar zxf gperftools-2.0.tar.gz
cd gperftools-2.0
./configure --enable-frame-pointers
make
make install

cd $SrcDir
tar xzf pcre-8.32.tar.gz 

# 使系统加载库文件
echo -e "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
/sbin/ldconfig

# 安装nginx
cd $SrcDir
tar zxf nginx-1.4.1.tar.gz
cd nginx-1.4.1
./configure --prefix=/opt/app/nginx --with-google_perftools_module  --without-http_memcached_module --user=www --group=www --with-http_stub_status_module --with-pcre=$SrcDir/pcre-8.32
make
make install
chmod  777 /tmp/tcmalloc -R
/opt/app/nginx/sbin/nginx
cp $SrcDir/etc/nginx  /etc/rc.d/init.d/nginx
chmod 775 /etc/rc.d/init.d/nginx
chkconfig nginx on
/etc/rc.d/init.d/nginx restart

# 优化的默认配置
/bin/cp $SrcDir/etc/nginx.conf  /opt/app/nginx/conf/nginx.conf
/bin/cp $SrcDir/etc/rewrite.conf  /opt/app/nginx/conf/rewrite.conf
/bin/cp $SrcDir/etc/mime.types  /opt/app/nginx/conf/mime.types
/bin/cp $SrcDir/etc/fcgi.conf /opt/app/nginx/conf/fcgi.conf
/bin/cp $SrcDir/etc/localhost.conf /opt/app/nginx/conf/vhost/localhost.conf

# nginx测试文件
cd /opt/app/nginx/html/
rm -rf /opt/app/nginx/html/*
/bin/cp $SrcDir/etc/index.php  /opt/app/nginx/html/index.php
/bin/cp $SrcDir/etc/gd.php  /opt/app/nginx/html/gd.php
/bin/cp $SrcDir/etc/server.php  /opt/app/nginx/html/server.php
/bin/cp $SrcDir/etc/phpinfo.php  /opt/app/nginx/html/phpinfo.php
chown www.www /opt/app/nginx/html/ -R
chmod 700 /opt/app/nginx/html/ -R

cd $SrcDir
rm -rf nginx-1.4.1 libunwind-1.1  gperftools-2.0 pcre-8.32

