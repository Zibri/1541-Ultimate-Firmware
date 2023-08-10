#!/bin/bash
#
#sudo apt install libfl-dev libfl2
sudo rm -rf /opt/hostedtoolcache
wget -q https://downloads.intel.com/akdlm/software/acdsinst/18.1std/625/ib_tar/Quartus-lite-18.1.0.625-linux.tar -O - | tar -xvf -
./setup.sh --mode unattended --unattendedmodeui none --accept_eula 1 --installdir /opt/fpga
rm -rf setup.sh components
export LD_LIBRARY_PATH="/opt/fpga/quartus/linux64"
export PATH=/opt/fpga/nios2eds/bin:/opt/fpga/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/bin:/opt/fpga/quartus/linux64:$PATH
export QUARTUS_ROOTDIR="/opt/fpga/quartus"
git clone --recurse-submodules -j8 https://github.com/Zibri/1541ultimate
cd 1541ultimate
sed -i "s/0x1E00/0x1E0C/g" software/drive/disk_image.h
sed -i "s/0x1E00, 0x1BE0, 0x1A00, 0x1860, 0x1E00, 0x1BE0, 0x1A00, 0x1860/0X1E0C, 0x1BE6, 0x1A0A, 0x186A, 0X1E0C, 0x1BE6, 0x1A0A, 0x186A/g" software/drive/disk_image.cc
sed -i "s/0x1E00/0x1E0C/g" software/drive/disk_image.cc
make u2plus
export -n LD_LIBRARY_PATH
cp target/u2plus/nios/ultimate/result/ultimate.bin .
cp target/u2plus/nios/recovery/result/recovery.bin .
ver=$(grep APPL ./software/application/versions.h|cut -d'"' -f2)
curl -s "https://api.github.com/repos/GideonZ/1541ultimate/commits" >shv || true 
shv=$(cat shv|grep 2>/dev/null sha|head -1|cut -d'"' -f4|cut -c 1-7)
7z a ../u2plus_fw_${ver}_${shv}.7z ultimate.bin update.u2p recovery.bin
curl -s https://api.github.com/repos/GideonZ/1541ultimate/commits|jq '.[] | .commit.author.date + ": " + .commit.message' >revbody.txt
gh release create -t "Firmware version ${ver} (${shv}) by Zibri" -F revbodyg.txt zz${shv} $(realpath ../*.7z)
