#!/bin/bash
clear
SETUP_TEMP="$(mktemp -d)"
CURRENT_VER=$(curl -fsSL -o /dev/null -w "%{url_effective}" "https://github.com/Switch123456789/ddp2spi/releases/latest" | sed "s|.*/tag/v||")
curl -Lso "${TEMP_DIR}/ddp2spi.tar.gz" "https://github.com/Switch123456789/ddp2spi/releases/download/v0.1-beta/ddp2spi-linux-a64-v0.1-beta.tar.gz"
#curl -Lso "${TEMP_DIR}/ddp2spi.tar.gz" "https://github.com/Switch123456789/ddp2spi/releases/latest/download/ddp2spi-linux-a64-v${CURRENT_VER}.tar.gz"
tar -xOf "${TEMP_DIR}/ddp2spi.tar.gz" "ddp2spi" | install -D -m "755" "/dev/stdin" "/usr/local/bin/ddp2spi"
curl -Ls "https://raw.githubusercontent.com/Switch123456789/ddp2spi/main/ddp2spi.service" | install -D -m "644" "/dev/stdin" "/etc/systemd/system/ddp2spi.service"