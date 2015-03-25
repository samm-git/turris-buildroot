# Dockerfile for the turris OpenWRT buildroot
## about
Goal of this project is to provide OpenWRT buildroot for the turris router. I decided to use docker for a number of reasons:
- Its giving ability to create repeatable builds undepended from host environment
- It is possible to use it directly on Linux and also on OSX/Windows using boot2docker project
- Ability to automate build process, make snapshots, etc.
- Possibility to host image on docker hub and deploy it on any server (e.g. in cloud environment or locally). 

## how it works
Image is based on debian wheezy. All packages required to rebuild turris firmware are installed. OpenWRT + all feeds are fetched from the CZNIC server and ready to use. Build of this image is completely automated using Docker Hub. 

## how to use it
1. You should have [docker](http://www.docker.com) installed and configured.
2. Image is available on the docker hub: 

        bash-3.2$ docker search turris
        NAME                      DESCRIPTION   STARS     OFFICIAL   AUTOMATED
        sammcz/turris-buildroot                 0                    [OK]

3. Its time to start our container. I am recommending to mount `build_dir` to the host (e.g. to `/opt/turris/build_dir`), because it can grow to 20+ Gb during full firmware rebuild. Also `dl` directory which is used to download port source files should be mounted to host `/opt/turris/dl`:

        sh# mkdir -p  /opt/turris/dl /opt/turris/build_dir && chmod -R 1000:1000 /opt/turris/
        sh# docker run --name turris_buildroot -v /opt/turris/dl:/opt/turris/openwrt/dl \
        -v /opt/turris/build_dir:/opt/turris/openwrt/build_dir -ti sammcz/turris-buildroot

4. If everything works fine you should see container prompt (something like builder@188508e1863d:~/openwrt$). Container using "builder" user with uid/gid 1000/1000. If you need root - use `su` command without password. Its time to test it, lets compile kernel and some basic packages:

        builder@188508e1863d:~/openwrt$ cp configs/config-turris-nand ./.config
        builder@188508e1863d:~/openwrt$ make defconfig
        Collecting package info: done
        Collecting target info: done
        #
        # configuration written to .config
        #
        make -j18 LOGFILE=1 BUILD_LOG=1 IS_TTY=1
        <output skipped>
This should build GCC/uClibc toolchain, build tools, kernel and some packages
5. To build entire firmware (please note, it will take a lot of time), use command like that:

        USE_CCACHE=y BUILD_ALL=y ./compile_turris_fw -j8 LOGFILE=1 BUILD_LOG=1 IS_TTY=1
Most likely this step will fail, because during build process it will try to fetch many files from remote locations, and not all of them were available during my tests. I was looking for such files on the mirrors and downloaded them to `dl/` folder directly.After `dl/` is filled you can run `make package/compile -j8` to continue. Also parallel build is not always working very well with openwrt.
