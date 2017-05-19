FROM centos:6

RUN mkdir -p /usr/local/src
RUN yum install -y wget gcc make automake autoconf

ENV PHP_VERSION 7.1.5

RUN wget -O /usr/local/src/php-$PHP_VERSION.tar.gz http://cn2.php.net/get/php-$PHP_VERSION.tar.gz/from/this/mirror
RUN tar -xzf /usr/local/src/php-$PHP_VERSION.tar.gz -C /usr/local/src

RUN wget -O /usr/local/src/libiconv-1.15.tar.gz http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
RUN tar -xzf /usr/local/src/libiconv-1.15.tar.gz -C /usr/local/src

RUN yum install -y libtool

RUN cd /usr/local/src/libiconv-1.15 \
    && ./configure --prefix=/usr/local/libiconv  \
    && make && make install \
    && libtool --finish /usr/local/libiconv/lib \
    && ls -al /usr/local/libiconv 

RUN yum install -y libxml2 libxml2-devel gmp-devel
RUN yum install -y libzip-devel zlib-devel bzip2-devel gettext-devel libcurl-devel gd-devel openssl-devel 

RUN wget -O /usr/local/src/epel-release-6-8.noarch.rpm http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
    && wget -O /usr/local/src/remi-release-6.rpm http://rpms.famillecollet.com/enterprise/remi-release-6.rpm \
    && rpm -Uvh /usr/local/src/remi-release-6*.rpm /usr/local/src/epel-release-6*.rpm \
    && yum install -y libmcrypt-devel \
    && yum install -y libmhash-devel

# RUN wget -O /usr/local/src/libmcrypt-2.6.8.tar.gz https://ncu.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
# RUN tar -xzf /usr/local/src/libmcrypt-2.6.8.tar.gz -C /usr/local/src
# RUN cd /usr/local/src/libmcrypt-2.6.8 \
#    && ./configure \
#    && make \
#    && make install

ENV PHP_PREFIX /usr
ENV PHP_CONFIG_FILE_PATH /etc

RUN cd /usr/local/src/php-$PHP_VERSION \
    && ./configure \
        --prefix=$PHP_PREFIX \
        --with-config-file-path=$PHP_CONFIG_FILE_PATH \
        --with-config-file-scan-dir=$PHP_CONFIG_FILE_PATH/php.d \
        --enable-opcache \
        --enable-mbstring \
        --enable-zip \
        --enable-bcmath \
        --enable-pcntl \
        --enable-ftp \
        --enable-calendar \
        --enable-sysvmsg \
        --enable-sysvsem \
        --enable-sysvshm \
        --enable-wddx \
        --enable-exif \
        --enable-shmop \
        --enable-soap \
        --enable-sockets \
        --with-curl \
        --with-mcrypt \
        --with-iconv=/usr/local/libiconv \
        --with-gmp \
        --with-openssl \
        --with-readline \
        --with-zlib=/usr \
        --with-bz2=/usr \
        --with-gettext=/usr \
        --with-mysql=mysqlnd \
        --with-mysqli=mysqlnd \
        --with-pdo-mysql=mysqlnd \
        --with-gd=/usr \
        --with-jpeg-dir=/usr \
        --with-png-dir=/usr \
        --with-readline \
        --with-imap \
        --with-ldap \
    && make  \
    # && make test \
    && make install 

RUN PECL=$PHP_PREFIX/bin/pecl \
    for x in redis imagick igbinary inotify intl memcache; do \
        $PECL install $x; \
        echo "exstension=$x.so" > /data/server/etc/php-7.1.5/php.d/$x.ini; \
    done;


