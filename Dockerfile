FROM alpine:3.13 AS builder
RUN set -x \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache \
          gcc \
          libc-dev \
          make \
          openssl-dev \
          pcre-dev \
          zlib-dev \
          linux-headers \
          libxslt-dev \
          gd-dev \
          geoip-dev \
          perl-dev \
          libedit-dev \
          mercurial \
          bash \
          alpine-sdk \
          findutils \
          openssl-dev
ADD http://nginx.org/download/nginx-1.19.3.tar.gz /build/nginx-1.19.3.tar.gz
RUN cd /build && tar xvzf nginx-1.19.3.tar.gz
# ADD nginx-1.19.3.tar.gz /build
WORKDIR /build/nginx-1.19.3
RUN git clone https://github.com/chobits/ngx_http_proxy_connect_module.git ../ngx_http_proxy_connect_module \
    && patch -p1 < ../ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_1018.patch \
    && ./configure \
          --with-http_ssl_module \
          --with-threads \
          --with-file-aio \
          --with-http_ssl_module \
          --with-http_v2_module \
          --with-http_realip_module \
          --with-http_addition_module \
          --with-http_xslt_module \
          --with-http_image_filter_module \
          --with-http_geoip_module \
          --with-http_sub_module \
          --with-http_dav_module \
          --with-http_flv_module \
          --with-http_mp4_module \
          --with-http_gunzip_module \
          --with-http_gzip_static_module \
          --with-http_auth_request_module \
          --with-http_random_index_module \
          --with-http_secure_link_module \
          --with-http_degradation_module \
          --with-http_slice_module \
          --with-http_stub_status_module \
          --with-stream \
          --with-stream_ssl_preread_module \
          --with-stream_ssl_module \
          --add-module=/build/ngx_http_proxy_connect_module \
    && make && make install


FROM alpine:3.13
LABEL maintainer="Nick Jiang <congtao.jiang@outlook.com>"
COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY ./nginx.conf /usr/local/nginx/conf/nginx-proxy.conf
WORKDIR /usr/local/nginx
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache pcre zlib openssl libxml2 libxslt gd geoip \
    && mkdir certs\
    && openssl req \
            -newkey rsa:4096 \
            -x509 \
            -sha256 \
            -days 3650 \
            -nodes \
            -out certs/public.pem \
            -keyout certs/private.pem \
            -subj "/C=CN/ST=SH/L=SH/O=HLT/OU=ChinaTechnology/CN=httpproxy.com"
EXPOSE 8888 8443

CMD ["sbin/nginx", "-g", "daemon off;", "-c", "conf/nginx-proxy.conf"]