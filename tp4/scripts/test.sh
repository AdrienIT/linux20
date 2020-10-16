#!/bin/bash
# AdrienIT

yum install -y yum install zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig curl jq nodejs wget git
yum update

bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait