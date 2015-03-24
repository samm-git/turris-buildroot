# OpenWRT buildroot docker image
# use debian as build os
FROM debian:latest
MAINTAINER Alex Samorukov
# install packages needed to build OS and packages
RUN apt-get update
RUN apt-get install -y gawk unzip ncurses-dev git-core build-essential libssl-dev  subversion mercurial wget
# create OpenWRT buildroot in /opt/turris/openwrt
RUN mkdir -p /opt/turris
WORKDIR /opt/turris
# add builder uid/gid
RUN useradd builder && chown builder:builder /opt/turris
USER builder
RUN git clone https://gitlab.labs.nic.cz/turris/openwrt.git
# use stable branch. no idea what is used to generate Turris OS releases.
RUN git checkout -b stable remotes/origin/stable
# put turris config in place
RUN cp -p configs/config-turris-nand ./.config
RUN su builder -c 'make defconfig'
