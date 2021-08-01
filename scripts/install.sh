sudo apt update
sudo apt install python3-pip make git libcap-dev libcap-ng-dev libcurl4-gnutls-dev libgtk-3-dev libglib2.0-dev libpixman-1-dev libseccomp-dev autoconf -y
sudo pip3 install ninja
wget https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20amd64%20DEB/Lazarus%202.0.10/fpc-laz_3.2.0-1_amd64.deb/download
mv download fpc-laz_3.2.0-1_amd64.deb
sudo apt install ./fpc-laz_3.2.0-1_amd64.deb -y
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
