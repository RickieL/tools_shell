#!/bin/sh

OneSpt=$1
SrcDir=/opt/app/src

# 判断是否为一键安装脚本
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

# 一键安装脚本的 依赖包
yum install -y wget gcc-c++ ncurses-devel ncurses make perl

# 将所有软件包复制到源文件src目录
cp -rf Packages/* $SrcDir

fi

# 安装cmake  [mysql 5.5以上的安装编译工具]
cd $SrcDir
tar zxf cmake-2.8.10.tar.gz
cd cmake-2.8.10
./configure
make
make install

# 使系统加载库文件
echo -e "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
/sbin/ldconfig

# 安装mysql 5.6
cd $SrcDir
tar zxf mysql-5.6.11.tar.gz
cd mysql-5.6.11
cmake . \
 -DCMAKE_INSTALL_PREFIX=/opt/app/mysql \
 -DMYSQL_DATADIR=/data/mysql \
 -DSYSCONFDIR=/etc \
 -DDEFAULT_CHARSET=utf8 \
 -DDEFAULT_COLLATION=utf8_general_ci
make
make install

/bin/mv -f /etc/my.cnf /etc/my.cnf.yongfu.bak
cd /opt/app/mysql
./scripts/mysql_install_db --user=mysql --basedir=/opt/app/mysql --datadir=/data/mysql
ln -s /opt/app/mysql/my.cnf /etc/my.cnf
cp ./support-files/mysql.server  /etc/rc.d/init.d/mysqld
chmod 755 /etc/init.d/mysqld
chkconfig mysqld on

echo 'basedir=/opt/app/mysql/' >> /etc/rc.d/init.d/mysqld
echo 'datadir=/data/mysql/' >>/etc/rc.d/init.d/mysqld
service mysqld start
echo 'export PATH=$PATH:/opt/app/mysql/bin' >> /etc/profile
ln -s /opt/app/mysql/lib /usr/lib/mysql
ln -s /opt/app/mysql/lib /usr/lib64/mysql
ln -s /opt/app/mysql/lib /opt/app/mysql/lib64
ln -s /opt/app/mysql/include /usr/include/mysql
ln -s /tmp/mysql.sock  /var/lib/mysql/mysql.sock

cd $SrcDir
rm -rf mysql-5.6.11
rm -rf cmake-2.8.10
