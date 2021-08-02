# Deploying the Static Webserver appliance to host the Toro's website
## Introduction
This repository contains the scripts to deploy the Toro's website by using the static webserver appliance. These scripts have been tested on an OVH host (**s1-2**), which has Debian 10. Once the appliance is deployed, the website can be reached at port 4000.

## How to launch the webserver appliance?
This setup creates the directory named `staticwebserver` in `$HOME` from which the following scripts are invoked:
```bash
mkdir staticwebserver
cd staticwebserver
wget https://github.com/torokernel/torowebserverappliance/blob/main/scripts/install.sh
wget https://github.com/torokernel/torowebserverappliance/blob/main/scripts/launch.sh
chmod +x ./install.sh
chmod +x ./launch.sh
./install.sh
./launch.sh
```

## What does the installation do?
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
