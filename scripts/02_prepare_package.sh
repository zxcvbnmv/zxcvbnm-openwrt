#!/bin/bash
clear
# Make target
#sed -i 's/KERNEL_PATCHVER:=5.4/KERNEL_PATCHVER:=4.19/g' ./target/linux/x86/Makefile
#sed -i 's/KERNEL_TESTING_PATCHVER:=5.4/KERNEL_TESTING_PATCHVER:=4.19/g' ./target/linux/x86/Makefile
# Use 19.07-feed	
rm -f ./feeds.conf.default	
wget https://raw.githubusercontent.com/openwrt/openwrt/openwrt-19.07/feeds.conf.default	
wget -P include/ https://raw.githubusercontent.com/openwrt/openwrt/openwrt-19.07/include/scons.mk
# Del snapshot tag
sed -i 's,SNAPSHOT,,g' include/version.mk
sed -i 's,snapshots,,g' package/base-files/image-config.in
# Enable O3-compile
sed -i 's/Os/O3/g' include/target.mk
sed -i 's/O2/O3/g' ./rules.mk
# Update feed
./scripts/feeds update -a && ./scripts/feeds install -a
# patch jsonc
patch -p1 < ../PATCH/use_json_object_new_int64.patch
# patch dnsmasq
rm -rf ./package/network/services/dnsmasq
svn co https://github.com/openwrt/openwrt/trunk/package/network/services/dnsmasq package/network/services/dnsmasq
patch -p1 < ../PATCH/dnsmasq-add-filter-aaaa-option.patch
patch -p1 < ../PATCH/luci-add-filter-aaaa-option.patch
cp -f ../PATCH/900-add-filter-aaaa-option.patch ./package/network/services/dnsmasq/patches/900-add-filter-aaaa-option.patch
rm -rf ./package/base-files/files/etc/init.d/boot
wget -P package/base-files/files/etc/init.d https://raw.githubusercontent.com/project-openwrt/openwrt/openwrt-18.06-k5.4/package/base-files/files/etc/init.d/boot
# Patch FireWall fullcone
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/fullconenat.patch
# Patch LuCI fullcone-switch
pushd feeds/luci
wget -O- https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/luci.patch | git apply
popd
# Patch Kernel with fullcone
wget -P target/linux/generic/hack-5.4/ https://github.com/coolsnowwolf/lede/raw/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
# FullCone Module
cp -rf ../openwrt-lienol/package/network/fullconenat ./package/network/fullconenat
# Patch FireWall with SFE
patch -p1 < ../PATCH/luci-app-firewall_add_sfe_switch.patch
# Patch Kernel with SFE
pushd target/linux/generic/hack-5.4
wget https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/hack-5.4/953-net-patch-linux-kernel-to-support-shortcut-fe.patch
popd
# SFE Module
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe package/new/shortcut-fe
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/fast-classifier package/new/fast-classifier
# Add 2.5G Ethernet LINUX driver
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/r8125 ./package/kernel
# Arpbind
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-arpbind package/lean/luci-app-arpbind
# AutoCore
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/autocore package/lean/autocore
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/coremark package/lean/coremark
mkdir package/lean/coremark/patches
wget -P package/lean/coremark/patches/ https://raw.githubusercontent.com/zxcvbnmv/zxcvbnm-openwrt/master/PATCH/coremark.patch
# Edge theme
git clone -b master --single-branch https://github.com/garypang13/luci-theme-edge package/new/luci-theme-edge
# UPnP
rm -rf ./feeds/packages/net/miniupnpd
svn co https://github.com/coolsnowwolf/packages/trunk/net/miniupnpd feeds/packages/net/miniupnpd
# Translate
cp -rf ../PATCH/addition-trans-zh-master package/lean/lean-translate
# Vermagic
#latest_version="$(curl -s https://github.com/openwrt/openwrt/releases |grep -Eo "v[0-9\.]+.tar.gz" |sed -n 1p |sed 's/v//g' |sed 's/.tar.gz//g')"
#wget https://downloads.openwrt.org/releases/${latest_version}/targets/x86/64/packages/Packages.gz
#zgrep -m 1 "Depends: kernel (=.*)$" Packages.gz | sed -e 's/.*-\(.*\))/\1/' > .vermagic
#sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
# Replace cryptodev-linux
rm -rf ./package/kernel/cryptodev-linux
svn co https://github.com/project-openwrt/openwrt/trunk/package/kernel/cryptodev-linux package/kernel/cryptodev-linux
# Replace Gcc version
rm -rf ./feeds/packages/devel/gcc
svn co https://github.com/openwrt/packages/trunk/devel/gcc feeds/packages/devel/gcc
# Grub time
sed -i 's/default "5"/default "0"/g' config/Config-images.in
# Limits
sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
# Del default configuration
rm -rf .config
exit 0
