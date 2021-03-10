#!/bin/sh

WHOAMI_VERSION=0.2.0

DEST_DIR=/whoami
WHOAMI_ARCHIVE="whoami-v${WHOAMI_VERSION}-linux-amd64.tar.gz"

yum update -y && \
wget -O /tmp/whoami.tar.gz "https://github.com/desotech-it/whoami/releases/download/v${WHOAMI_VERSION}/$WHOAMI_ARCHIVE" && \
mkdir "$DEST_DIR" && cd "$DEST_DIR" && \
tar -xf /tmp/whoami.tar.gz && \
rm -f /tmp/whoami.tar.gz && \
exec ./whoami -p 80
