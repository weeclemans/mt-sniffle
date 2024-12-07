
FROM ubuntu:oracular

ENV WINEPREFIX=/opt/app/.wine64
ENV WINEARCH=win64
#ENV WINEDLLOVERRIDES="mscoree=d;mshtml=d"
ENV DISPLAY=:0
ENV USER=nobody
ENV PASSWORD=nobody

# Basic init and admin tools
RUN set -eux; \
    mkdir -p /opt/app/etc; \
    apt-get update; \
    apt-get install -y --no-install-recommends supervisor sudo wget ca-certificates gnupg; \
    rm -rf /var/lib/apt/lists/*

# Install X11 server and vnc server
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends tigervnc-standalone-server tigervnc-tools; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /opt/app/.config/tigervnc; \
    echo "password" | vncpasswd -f > /opt/app/.config/tigervnc/passwd; \
    chmod 0600 /opt/app/.config/tigervnc/passwd

RUN set -eux; \
    wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add -; \
    echo "deb https://dl.winehq.org/wine-builds/ubuntu/ $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) main" >> /etc/apt/sources.list; \
    dpkg --add-architecture i386; \
    apt-get update; \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
      winehq-staging="9.22~oracular-1" wine-staging="9.22~oracular-1" wine-staging-amd64="9.22~oracular-1" wine-staging-i386="9.22~oracular-1"; \
    rm -rf /var/lib/apt/lists/*


# Configure init
COPY assets/supervisord.conf /opt/app/etc/supervisord.conf

# Metatrader
COPY Metatrader /opt/app/Metatrader

#winecfg -v=win10
RUN set -eux; \
    #mkdir -p /usr/share/wine/mono; \
    #wget -nv -P /usr/share/wine/mono/ https://dl.winehq.org/wine/wine-mono/9.3.0/wine-mono-9.3.0-x86.msi; \
    wineboot -u; \
    chown -vR nobody:nogroup /opt/app

USER nobody
WORKDIR /opt/app
EXPOSE 5900
CMD ["/usr/bin/supervisord","-c","/opt/app/etc/supervisord.conf"]

