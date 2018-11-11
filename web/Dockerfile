FROM centos:latest

LABEL maintainer="Landon Manning <lmanning17@gmail.com>"

# Software versions
ARG LUAROCKS_VERSION="2.4.3"
ARG RESTY_VERSION="1.13.6.2"
ARG GIFLIB_VERSION="5.1.1"

# Necessary files
ADD OpenResty.repo /etc/yum.repos.d/OpenResty.repo
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Install from repos
RUN yum -y update; yum clean all
RUN yum -y install epel-release; yum clean all
RUN yum -y install \
		dos2unix \
		ffmpeg \
		gcc \
		git \
		ImageMagick-devel \
		luajit \
		luajit-devel \
		make \
		openresty-${RESTY_VERSION} \
		openresty-opm-${RESTY_VERSION} \
		openresty-resty-${RESTY_VERSION} \
		openssl \
		openssl-devel \
		unzip; \
		yum clean all

# Make executable
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN dos2unix /usr/local/bin/docker-entrypoint.sh

# Install giflib
RUN cd /tmp && \
	curl -fSL "https://downloads.sourceforge.net/project/giflib/giflib-${GIFLIB_VERSION}.tar.gz?r=&ts=1514450280&use_mirror=superb-dca2" -o giflib-${GIFLIB_VERSION}.tar.gz && \
	tar xzf giflib-${GIFLIB_VERSION}.tar.gz && \
	cd giflib-${GIFLIB_VERSION} && \
	./configure \
		--prefix=/usr && \
	make && \
	make install && \
	cd /

# Install LuaRocks
RUN cd /tmp  && \
	curl -fSL https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz -o luarocks-${LUAROCKS_VERSION}.tar.gz && \
	tar xzf luarocks-${LUAROCKS_VERSION}.tar.gz && \
	cd luarocks-${LUAROCKS_VERSION} && \
	./configure \
		--prefix=/usr \
		--lua-suffix=jit \
		--with-lua-include=/usr/include/luajit-2.0 && \
	make build && \
	make install && \
	cd /

# Cleanup /tmp
RUN rm /tmp/* -r

# Install from LuaRocks
RUN luarocks install luasec
RUN luarocks install bcrypt
RUN luarocks install giflib --server=http://luarocks.org/dev
RUN luarocks install i18n
RUN luarocks install lapis
RUN luarocks install luafilesystem
RUN luarocks install luaposix
RUN luarocks install magick
RUN luarocks install markdown
RUN luarocks install md5

# Link OpenResty logs to /dev
RUN ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log
RUN ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

# Update PATH
ENV PATH=$PATH:/usr/local/openresty/luajit/bin/:/usr/local/openresty/nginx/sbin/:/usr/local/openresty/bin/

# Update LD cache
RUN ldconfig

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
