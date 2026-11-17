#!/bin/bash

    TEMP_DIR="$(mktemp -d.)"

# DOWNLOAD BINARY

    CURRENT_VER=$( curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/Switch123456789/ddp2spi/releases/latest" | sed 's|.*/tag/v||' )
    curl -Lo "${TEMP_DIR}/ddp2spi.tar.gz" "https://github.com/Switch123456789/ws2812-ddpd/releases/latest/download/ddp2spi-${CURRENT_VER}-linux-arm64.tar.gz"
    tar -xOf "${TEMP_DIR}/ddp2spi.tar.gz" "ddp2spi" | install -D -m "755" "/dev/stdin" "/usr/local/bin/ddp2spi"

# DOWNLOAD SERVICE-FILE

    curl -L "https://raw.githubusercontent.com/Switch123456789/Soundjar/main/root/ddp2spi.service" | install -D -m "644" "/dev/stdin" "/etc/ddp2spi"
