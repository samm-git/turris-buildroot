# Dockerfile for the Turris OpenWRT buildroot
## about
Goal of this project is to provide OpenWRT buildroot for the [Turris router](https://www.turris.cz/). I decided to use docker for a number of reasons:
- Its giving ability to create repeatable builds undepended from the host environment. Turris OS build process is not exactly the same as OpenWRT so its easy to forgot/miss something. 
- It is possible to use it directly on Linux and also on OSX/Windows using boot2docker project.
- Ability to automate build process, make snapshots, etc.
- Possibility to host image on [docker hub](https://hub.docker.com/) and deploy it on any server (e.g. in cloud environment or locally). 

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

4. If everything works fine you should see container prompt (something like builder@188508e1863d:~/openwrt$). Container using "builder" user with uid/gid 1000/1000. If you need root - use `su` command without password. Its time to test environment, lets compile kernel and some basic packages:

        builder@188508e1863d:~/openwrt$ cp configs/config-turris-nand ./.config
        builder@188508e1863d:~/openwrt$ make defconfig
        Collecting package info: done
        Collecting target info: done
        #
        # configuration written to .config
        #
        make -j18 LOGFILE=1 BUILD_LOG=1 IS_TTY=1
        <output skipped>
This should build GCC/uClibc toolchain, build tools, kernel and some packages. On a 16 Cores VM it takes about 25 minutes. 
5. To build entire firmware (please note, it will take a lot of time), use command like that:

        USE_CCACHE=y BUILD_ALL=y ./compile_turris_fw -j8 LOGFILE=1 BUILD_LOG=1 IS_TTY=1
Most likely this step will fail, because during build process it will try to fetch many files from remote locations, and not all of them were available during my tests. I was looking for such files on the mirrors and downloaded them to `dl/` folder manually. After `dl/` is populated you can run `make package/compile -j8` to continue. Also parallel build is not always working very well with openwrt.

## building kernel modules matching Turris release version
OpenWRT using `vermagic` number which contain hash of the kernel configuration, including all enabled modules. To build 

```
builder@188508e1863d:~/openwrt$ cp configs/config-turris-nand ./.config
builder@188508e1863d:~/openwrt$ echo "CONFIG_ALL=y" >> .config
builder@188508e1863d:~/openwrt$ make defconfig
builder@188508e1863d:~/openwrt$ make -j 18 target/compile
 make[1] target/compile
 make[2] -C target/linux compile
builder@fcac61323ebe:~/openwrt$ make -j 18 package/linux/compile
 make[1] package/linux/compile
 make[2] -C package/libs/toolchain compile
 make[2] -C package/firmware/linux-firmware compile
 make[2] -C package/kernel/linux compile
```
After compilation you should find all kernel packages with matching vermagic number in the `bin/mpc85xx/packages/` directory. 
## troubleshooting
As i mentioned before - openwrt build system is not very stable. I am recommending to grep ' Error' in the `/opt/turris/openwrt/logs/build.log` in case of fail to find exact reason and failed package. Sometime it is enough to run build one more time. Often it is enough to put unavialable distfile to the `dl/` directory. Also you will find that some packages are very outdated - this is because Turris OS overrides default openwrt packages for some reason. Also use [OpenWRT article](http://wiki.openwrt.org/doc/howto/build).

In case of any comments or suggestions - pull requests are welcome :)
