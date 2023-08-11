#!/bin/bash
#
#sudo apt install libfl-dev libfl2
echo Cleaning up...
sudo rm -rf /opt/hostedtoolcache /usr/share/dotnet /usr/share/swift /usr/share/miniconda /usr/local/lib/android
echo Downloading...
sudo aria2c &>/dev/null -x8 -j8 -s8 https://downloads.intel.com/akdlm/software/acdsinst/18.1std/625/ib_tar/Quartus-lite-18.1.0.625-linux.tar --dir /mnt
echo Decompressing...
tar -xf /mnt/Quartus-lite-18.1.0.625-linux.tar
sudo rm /mnt/Quartus-lite-18.1.0.625-linux.tar
echo Installing...
./setup.sh --mode unattended --unattendedmodeui none --accept_eula 1 --installdir /opt/fpga
rm -rf setup.sh components
export LD_LIBRARY_PATH="/opt/fpga/quartus/linux64"
export PATH=/opt/fpga/nios2eds/bin:/opt/fpga/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/bin:/opt/fpga/quartus/linux64:$PATH
export QUARTUS_ROOTDIR="/opt/fpga/quartus"
echo Cloning...
git &>/dev/null clone --recurse-submodules -j8 https://github.com/GideonZ/1541ultimate
cd 1541ultimate
git reset --hard $1
make u2plus
export -n LD_LIBRARY_PATH
cp target/u2plus/nios/ultimate/result/ultimate.bin .
cp target/u2plus/nios/recovery/result/recovery.bin .
ver=$(grep APPL ./software/application/versions.h|cut -d'"' -f2)
curl -s "https://api.github.com/repos/Zibri/1541ultimate/commits" >shv || true 
shv=$(git rev-parse HEAD)|cut -c1-7
7z a ../u2plus_fw_${ver}_${shv}.7z ultimate.bin update.u2p recovery.bin
echo "```" >revbody.txt
curl -s https://api.github.com/repos/GideonZ/1541ultimate/commits|jq '.[] | .commit.author.date + ": " + .commit.message' | tr -d '"'>>revbody.txt
echo "```" >>revbody.txt
gh release create -R "Zibri/1541-Ultimate-Firmware" -t "Firmware version ${ver} (${shv}) by Zibri" -F revbody.txt z${shv} $(realpath ../*.7z)
