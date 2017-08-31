# Node.js for cross build MT7688
# More info: http://seans.tw

FROM ubuntu:16.04

MAINTAINER @opjlmi <opjlmi@gmail.com>

# 7688 cross-compile need to build with normal user
# If need to process with su, use `sudo su`, passwd is ubuntu.
RUN  useradd -ms /bin/bash ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

# Install
RUN \
  apt-get update && \
  apt-get install -y python-software-properties software-properties-common && \
  add-apt-repository ppa:fkrull/deadsnakes && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y sudo git g++ libncurses5-dev subversion libssl-dev gawk libxml-parser-perl unzip wget build-essential python2.7

USER ubuntu

RUN \
  cd /home/ubuntu && \
  git clone git://git.openwrt.org/15.05/openwrt.git

# Define working directory.
WORKDIR /home/ubuntu/openwrt

RUN \
  # Prepare the default configuration file for feeds
  cp feeds.conf.default feeds.conf && \
  echo src-git linkit https://github.com/MediaTek-Labs/linkit-smart-7688-feed.git >> feeds.conf && \
  echo src-git node https://github.com/nxhack/openwrt-node-packages.git\;for-15.05 >> feeds.conf && \
  # Update the feed information for all available packages to build the firmware
  ./scripts/feeds update && \
  # Change the packages installed as default
  # Fix build error of depend on node.js version
  wget https://gist.githubusercontent.com/nxhack/7ced4d866a59ebc72737589b49a220f8/raw/1bebfe9f6091f55a5856bc4af00da456a4995b09/mtk-linkit.patch && \
  patch -p1 < mtk-linkit.patch && \
  wget https://gist.githubusercontent.com/nxhack/4357d51918ba8f3cb5cc00080ad0815c/raw/e96758224ade8cb224523aedf5ea3249a6a59425/MRAA.patch && \
  patch -p1 < MRAA.patch && \
  wget https://gist.githubusercontent.com/nxhack/78fa1df0a1224a168191dd1ab5b3336e/raw/94b6ded945c61809103e529ddbc41cb4cb757792/fix-git-submodule.patch && \
  patch -p1 < fix-git-submodule.patch && \
  # Hack for wifi driver so build completes
  # Copy kernel objects for support kernel 3.18.45
  cp ./feeds/linkit/mtk-sdk-wifi/wifi_binary/mt_wifi.ko_3.18.44 ./feeds/linkit/mtk-sdk-wifi/wifi_binary/mt_wifi.ko_3.18.45 && \
  cp ./feeds/linkit/mtk-sdk-wifi/wifi_binary/mt_wifi.ko_3.18.44_all ./feeds/linkit/mtk-sdk-wifi/wifi_binary/mt_wifi.ko_3.18.45_all && \
  # Prepare for building node.js(patch to toolchain)
  patch -p1 < ./feeds/node/for_building_latest_node.patch

# Install all packages
# Use node.js custom packages
RUN  \
  ./scripts/feeds install -a && \
  rm ./package/feeds/packages/node && \
  rm ./package/feeds/packages/node-arduino-firmata && \
  rm ./package/feeds/packages/node-cylon && \
  rm ./package/feeds/packages/node-hid && \
  rm ./package/feeds/packages/node-serialport && \
  ./scripts/feeds install -a -p node

# Define default command.
CMD /bin/bash
