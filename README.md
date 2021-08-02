# Deploying the Static Webserver appliance to host the Toro's website
## Introduction
This repository contains the scripts to deploy the Toro's website by using the static webserver appliance. These scripts have been tested on an OVH host (**s1-2**), which has Debian 10. Once the appliance is deployed, the website can be reached at port 4000.

## How to launch the webserver appliance?
This setup creates the directory named `staticwebserver` in `$HOME` from which the following scripts are invoked. The scripts requires that you have installed the ssh-key that you use to clone from github:
```bash
mkdir staticwebserver
cd staticwebserver
wget https://raw.githubusercontent.com/torokernel/torowebserverappliance/main/scripts/install.sh
wget https://raw.githubusercontent.com/torokernel/torowebserverappliance/main/scripts/launch.sh
chmod +x ./install.sh
chmod +x ./launch.sh
./install.sh
./launch.sh
```
You can see the output of the appliance at `staticwebserver/toroforwebsite/examples/StaticWebServer/nohup`:
```bash
Loading Toro ...
commit: 605e979, build time: Mon 02 Aug 2021 02:15:27 PM UTC
Core#0 ... Running
System Memory ... 1023 MB
Memory per Core ... 1016 MB
Core#0, StartAddress: 0x800000, EndAddress: 0x3FFFFFFF
Loading Virtual FileSystem ...
Loading Network Stack ...
Starting MainThread: 0x3FFFBF90
VirtIO: found device at 0xFEB00E00:12
VirtIO: found device at 0xFEB00C00:11
VirtIOFS: tag: FS, nr queues: 1
VirtIOVSocket: cid=5
Networks Packets Service .... Thread: 0x3083BF98
DedicateNetworkSocket: success on core #0
SysMount: Filesystem mounted on CPU#0
27/02/1987-14:15:30 WebServer: listening ...
27/02/1987-14:15:30 WebServer: /index.html loaded, size: 10581 bytes
27/02/1987-14:15:30 WebServer: /vendor/bootstrap/css/bootstrap.min.css loaded, size: 153182 bytes
27/02/1987-14:15:30 WebServer: /css/heroic-features.css loaded, size: 289 bytes
27/02/1987-14:15:30 WebServer: /images/btcaddr.png loaded, size: 12732 bytes
27/02/1987-14:15:30 WebServer: /images/apporikernel.png loaded, size: 136486 bytes
27/02/1987-14:15:30 WebServer: /vendor/bootstrap/js/bootstrap.bundle.min.js loaded, size: 76308 bytes
27/02/1987-14:15:30 WebServer: /images/toroandgpos.png loaded, size: 90454 bytes
27/02/1987-14:15:30 WebServer: /vendor/jquery/jquery.min.js loaded, size: 86927 bytes
```

## What do these scripts do?
The installer and the launcher do the following steps to prepare, build, and finally, launch the webserver appliance to host the Toro's website:

### Step 1. Update and install tools
```bash
apt update
apt install python3-pip make git libcap-dev libcap-ng-dev libcurl4-gnutls-dev libgtk-3-dev libglib2.0-dev libpixman-1-dev libseccomp-dev autoconf -y
pip3 install ninja
wget https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20amd64%20DEB/Lazarus%202.0.10/fpc-laz_3.2.0-1_amd64.deb/download
mv download fpc-laz_3.2.0-1_amd64.deb
apt install ./fpc-laz_3.2.0-1_amd64.deb -y
git clone git@github.com:torokernel/torokernel.github.io.git
git clone https://github.com/torokernel/freepascal.git -b fpc-3.2.0 fpc-3.2.0
git clone git@github.com:torokernel/torokernel.git toroforwebsite
export PATH="/home/debian/.local/bin:$PATH"
git clone https://github.com/qemu/qemu.git qemuforvmm
cd qemuforvmm
git checkout 51204c2f
mkdir build
cd build
../configure --target-list=x86_64-softmmu
make
cd ../..
git clone git@github.com:stefano-garzarella/socat-vsock.git
cd socat-vsock
autoreconf -fiv
./configure
make socat
cd ..
sed -i '/qemudir=/c\qemudir="'"$PWD"'/qemuforvmm/build/x86_64-softmmu"' ./toroforwebsite/examples/CloudIt.sh
sed -i '/fpcrtlsource=/c\fpcrtlsource="'"$PWD"'/fpc-3.2.0/rtl/"' ./toroforwebsite/examples/CloudIt.sh
```

### Step 2. Run the static-webserver appliance
```bash
nohup ./qemuforvmm/build/tools/virtiofsd/virtiofsd -d --socket-path=/tmp/vhostqemu1 -o source="$PWD"/torokernel.github.io/ -o cache=always &
nohup ./socat-vsock/socat TCP4-LISTEN:4000,reuseaddr,fork VSOCK-CONNECT:5:80 &
cd ./toroforwebsite/examples/StaticWebServer
nohup ../CloudIt.sh StaticWebServer &
```
## Comments
matiasevara@gmail.com
