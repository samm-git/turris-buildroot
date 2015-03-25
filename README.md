# Dockerfile for the turris OpenWRT buildroot
## about
Goal of this project is to provide OpenWRT buildroot for the turris router. I decided to use docker for a number of reasons:
- Its giving ability to create repeatable builds undepended from host environment
- It is possible to use it directly on Linux and also on OSX/Windows using boot2docker project
- Ability to automate build process, use snapshots, etc.
- Possibility to host image on docker hub and deploy it on any server (e.g. in cloud environment or locally). 
## how it works
Image is based on debian wheezy. All packages required to rebuild turris firmware are installed. OpenWRT + all feeds are fetched from the CZNIC server and ready to use. Build of this image is completely automated using Docker Hub. 

## how to use it
kklkl

USE_CCACHE=y BUILD_ALL=y ./compile_turris_fw -j8 LOGFILE=1 BUILD_LOG=1 IS_TTY=1
