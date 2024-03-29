FROM alpine:latest

RUN apk update && apk upgrade
RUN apk add alpine-sdk gawk bash bzip2 perl python3 xz sed make argp-standalone asciidoc bash bc binutils bzip2 cdrkit coreutils diffutils \
  elfutils-dev findutils flex musl-fts-dev g++ gawk gcc gettext git grep gzip intltool libxslt linux-headers make musl-libintl musl-obstack-dev \
  ncurses-dev openssl-dev patch perl python3-dev rsync tar unzip util-linux wget zlib-dev

RUN addgroup -g 1000 build
RUN adduser -D -u 1000 -G build build
USER build
WORKDIR /home/build

RUN wget https://downloads.openwrt.org/snapshots/targets/x86/64/openwrt-imagebuilder-x86-64.Linux-x86_64.tar.xz
RUN tar -J -x -f openwrt-imagebuilder-*.tar.xz
WORKDIR /home/build/openwrt-imagebuilder-x86-64.Linux-x86_64

RUN sed -i 's/^\s*\(CONFIG_TARGET_KERNEL_PARTSIZE\)\s*=\s*[^#\n \t]*/\1=20/' .config
RUN sed -i 's/^\s*\(CONFIG_TARGET_ROOTFS_PARTSIZE\)\s*=\s*[^#\n \t]*/\1=1024/' .config

CMD make FORCE=1 V=s image FILES="files" PACKAGES="collectd collectd-mod-mqtt collectd-mod-memory collectd-mod-interface \
  collectd-mod-load collectd-mod-uptime collectd-mod-ping collectd-mod-cpu iperf3 tcpdump-mini unbound-daemon libunbound \
  unbound-control wireguard-tools luci luci-ssl luci-mod-dashboard luci-proto-wireguard luci-app-wireguard luci-app-unbound \
  odhcp6c odhcpd-ipv6only luci-app-ddns ddns-scripts-cloudflare sqm-scripts luci-app-sqm nlbwmon luci-app-nlbwmon"
