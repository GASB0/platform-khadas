#!/bin/bash
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export PATH=/opt/toolchains/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin/:$PATH
export INSTALL_MOD_STRIP=1 
KERNELDIR=/home/gabriel/Documents/Projects/linux-mp1
PLATFORMDIR=/home/gabriel/Documents/Projects/volumio3-os/platform-khadas

cd $KERNELDIR
echo "Cleaning and preparing .config"

cp $PLATFORMDIR/vims/khadas-vims_defconfig arch/arm64/configs/
make clean

make khadas-vims_defconfig
# make menuconfig
cp .config $PLATFORMDIR/vims/khadas-vims_defconfig

echo "Compressing the kernel sources"
git archive --format=tar.gz --prefix linux-4.9.206/ -v -o $PLATFORMDIR/`date +%Y.%m.%d-%H.%M`-linux4.9.206.tar.gz khadas-vims-4.9.y

echo "Compiling dts, image and modules"
make -j12 Image dtbs modules

echo "Saving to khadas/vims on NAS"
cp arch/arm64/boot/Image $PLATFORMDIR/vims/boot
cp arch/arm64/boot/dts/amlogic/kvim_linux.dtb $PLATFORMDIR/vims/boot/dtb
cp arch/arm64/boot/dts/amlogic/kvim2_linux.dtb $PLATFORMDIR/vims/boot/dtb
cp arch/arm64/boot/dts/amlogic/kvim3_linux.dtb $PLATFORMDIR/vims/boot/dtb
cp arch/arm64/boot/dts/amlogic/kvim3l_linux.dtb $PLATFORMDIR/vims/boot/dtb
cp arch/arm64/boot/dts/amlogic/kvim3l_primo_linux.dtb $PLATFORMDIR/vims/boot/dtb

kver=`make kernelrelease`-`date +%Y.%m.%d-%H.%M`
rm $PLATFORMDIR/vims/boot/config*
cp arch/arm64/configs/khadas-vims_defconfig $PLATFORMDIR/vims/boot/config-${kver}
rm -r $PLATFORMDIR/vims/lib/modules
make modules_install ARCH=arm64 INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$PLATFORMDIR/vims/

echo "Compressing $PLATFORMDIR/vims"
cd $PLATFORMDIR
tar cvfJ vims.tar.xz ./vims
