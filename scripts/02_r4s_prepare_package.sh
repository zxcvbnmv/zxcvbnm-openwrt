#!/bin/bash
clear
# Make target for support NanoPi R4S
rm -rf ./target/linux/rockchip
svn co https://github.com/1715173329/openwrt/branches/1806-k54-nanopi-r4s/target/linux/rockchip target/linux/rockchip
rm -rf ./package/boot/uboot-rockchip
svn co https://github.com/1715173329/openwrt/branches/1806-k54-nanopi-r4s/package/boot/uboot-rockchip package/boot/uboot-rockchip
rm ./target/linux/rockchip/patches-5.4/991-rockchip-rk3399-overclock-to-2.2-1.8-GHz-for-NanoPi4.patch
cp -f ../PATCH/991-rk3399-overclock1.8-2.2GHz.patch ./target/linux/rockchip/patches-5.4/
cp -f ../PATCH/249-rk3399dtsi.patch ./target/linux/rockchip/patches-5.4/
mkdir -p ./target/linux/rockchip/armv8/base-files/etc/hotplug.d/iface
cp -f ../PATCH/12-disable-rk3399-eth-offloading ./target/linux/rockchip/armv8/base-files/etc/hotplug.d/iface
# Use 19.07-feed
rm -f ./feeds.conf.default
wget https://github.com/openwrt/openwrt/raw/openwrt-19.07/feeds.conf.default
# Del snapshot tag
#sed -i 's,SNAPSHOT,,g' include/version.mk
#sed -i 's,snapshots,,g' package/base-files/image-config.in
# Enable O3-compile
sed -i 's/Os/O3/g' include/target.mk
sed -i 's/O2/O3/g' ./rules.mk
# Update feed
./scripts/feeds update -a && ./scripts/feeds install -a
# patch jsonc
patch -p1 < ../PATCH/use_json_object_new_int64.patch
# patch dnsmasq
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
pushd target/linux/generic/hack-5.4
wget https://github.com/coolsnowwolf/lede/raw/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
popd
# FullCone Module
cp -rf ../openwrt-lienol/package/network/fullconenat ./package/network/fullconenat
# Add R8168 driver
svn co https://github.com/project-openwrt/openwrt/branches/master/package/ctcgfw/r8168 package/new/r8168
# Arpbind
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-arpbind package/lean/luci-app-arpbind
# AutoCore
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/autocore package/lean/autocore
svn co https://github.com/project-openwrt/packages/trunk/utils/coremark feeds/packages/utils/coremark
ln -sf ../../../feeds/packages/utils/coremark ./package/feeds/packages/coremark
sed -i 's,default n,default y,g' feeds/packages/utils/coremark/Makefile
# Add Edge theme
git clone -b master --depth 1 https://github.com/garypang13/luci-theme-edge.git package/new/luci-theme-edge
# UPnP
rm -rf ./feeds/packages/net/miniupnpd
svn co https://github.com/coolsnowwolf/packages/trunk/net/miniupnpd feeds/packages/net/miniupnpd
# Translate
cp -rf ../PATCH/addition-trans-zh-master package/lean/lean-translate
# Limits
sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
# Del default configuration
rm -rf .config
# Chmod
chmod -R 755 ./
exit 0
