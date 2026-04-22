#!/bin/bash

#克隆LLVM工具链
git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 --depth=1 -b android14-release build-tools

#设置环境变量
export PATH=${PWD}/build-tools/clang-r487747c/bin:${PATH}

#克隆Anykernel3
git clone https://github.com/xiaoxian8/AnyKernel3.git --depth=1

#合并配置文件
ARCH=arm64 ./scripts/kconfig/merge_config.sh -m \
	arch/arm64/configs/vendor/pineapple_GKI.config \
    arch/arm64/configs/vendor/pineapple_consolidate.config \
    arch/arm64/configs/oem/pineapple_diff_config \
    arch/arm64/configs/oem/boards/cerro_diff_config

mv .config arch/arm64/configs/nx721j_defconfig

#编译参数
args=(-j$(nproc --all)
    O=out
	ARCH=arm64
	CLANG_TRIPLE=aarch64-linux-gnu-
	CROSS_COMPILE=aarch64-linux-gnu-
	CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
    CC=clang
	LD=ld.lld
	AR=llvm-ar
	NM=llvm-nm
	AS=llvn-as
	STRIP=llvm-strip
	OBJCOPY=llvm-objcopy
	OBJDUMP=llvm-objdump
	READELF=llvm-readelf
	HOSTCC=clang
	HOSTCXX=clang++
	HOSTAR=llvm-ar
	HOSTLD=ld.lld
    DEPMOD=depmod
    DTC=usr/bin/dtc)
#开始编译
make ${args[@]} nx721j_defconfig

make ${args[@]} all

make ${args[@]} INSTALL_MOD_PATH=modules modules_install

# cp $(find out -type f \( -name "Image" -o -name "dtbo.img" \)) ./

cp out/arch/arm64/boot/Image AnyKernel3/Image

cd AnyKernel3
zip -r9v ../out/kernel.zip *
