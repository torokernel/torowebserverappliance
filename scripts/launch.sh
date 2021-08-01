nohup sudo ./qemuforvmm/build/tools/virtiofsd/virtiofsd -d --socket-path=/tmp/vhostqemu1 -o source="$PWD"/torokernel.github.io/ -o cache=always &
nohup ./socat-vsock/socat TCP4-LISTEN:4000,reuseaddr,fork VSOCK-CONNECT:5:80 &
cd ./toroforwebsite/examples/StaticWebServer
nohup sudo ../CloudIt.sh StaticWebServer &
