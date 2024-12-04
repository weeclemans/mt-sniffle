
FROM alpine:3.20

ENV WINEPREFIX=/opt/app/.wine64
ENV WINEARCH=win64
#ENV WINEDLLOVERRIDES="mscoree=d;mshtml=d"
ENV DISPLAY=:0
ENV USER=nobody
ENV PASSWORD=nobody

# Basic init and admin tools
RUN mkdir -p /opt/app/etc \
    && apk --no-cache add supervisor sudo wget \
    && rm -rf /apk /tmp/* /var/cache/apk/*

# Install X11 server and vnc server
RUN apk add tigervnc --update --no-cache \
    && mkdir -p /opt/app/.config/tigervnc \
    && echo "password" | vncpasswd -f > /opt/app/.config/tigervnc/passwd \
    && chmod 0600 /opt/app/.config/tigervnc/passwd

RUN apk add wine --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/\
    && apk add wine-mono --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
    && rm -rf /apk /tmp/* /var/cache/apk/*

# Configure init
COPY assets/supervisord.conf /opt/app/etc/supervisord.conf

# Metatrader
COPY Metatrader /opt/app/Metatrader

#winecfg -v=win10
RUN wineboot \
    && chown -vR nobody:nobody /opt/app

USER nobody
WORKDIR /opt/app
EXPOSE 5900
CMD ["/usr/bin/supervisord","-c","/opt/app/etc/supervisord.conf"]

