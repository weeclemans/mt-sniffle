
FROM alpine:3.20

USER root
ENV WINEPREFIX=/root/.wine64
ENV WINEARCH=win64
#ENV WINEDLLOVERRIDES="mscoree=d;mshtml=d"
ENV DISPLAY=:0
ENV USER=root
ENV PASSWORD=root

# Basic init and admin tools
RUN apk --no-cache add supervisor sudo wget \
    && echo "$USER:$PASSWORD" | /usr/sbin/chpasswd \
    && rm -rf /apk /tmp/* /var/cache/apk/*

# Install X11 server and vnc server
RUN apk add tigervnc --update --no-cache \
    && mkdir -p /root/.config/tigervnc \
    && echo "password" | vncpasswd -f > /root/.config/tigervnc/passwd \
    && chmod 0600 /root/.config/tigervnc/passwd

# Configure init
COPY assets/supervisord.conf /etc/supervisord.conf

RUN apk add wine --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
    && apk add wine-mono --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
    && rm -rf /apk /tmp/* /var/cache/apk/* \
    && wineboot -i #winecfg -v=win10

# Metatrader
COPY Metatrader /root/Metatrader

WORKDIR /root
EXPOSE 5900
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]

