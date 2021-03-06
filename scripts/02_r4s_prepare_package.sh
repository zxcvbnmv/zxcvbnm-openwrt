#!/bin/bash
clear
# Make target for support NanoPi R4S
rm -rf ./target/linux/rockchip
svn co https://github.com/project-openwrt/openwrt/branches/master/target/linux/rockchip target/linux/rockchip
rm -rf ./package/boot/uboot-rockchip
svn co https://github.com/project-openwrt/openwrt/branches/master/package/boot/uboot-rockchip package/boot/uboot-rockchip
rm ./target/linux/rockchip/patches-5.4/992-rockchip-rk3399-overclock-to-2.2-1.8-GHz-for-NanoPi4.patch
cp -f ../PATCH/766-rk3399-overclock.patch ./target/linux/rockchip/patches-5.4/
cp -f ../PATCH/249-rk3399dtsi.patch ./target/linux/rockchip/patches-5.4/
cp -f ../PATCH/02_network ./target/linux/rockchip/armv8/base-files/etc/board.d/
# Use 19.07-feed
rm -f ./feeds.conf.default
wget https://github.com/openwrt/openwrt/raw/openwrt-19.07/feeds.conf.default
# Enable O3 & optimize
sed -i 's/Os/O3/g' include/target.mk
sed -i 's/O2/O3/g' ./rules.mk
# Update feed
./scripts/feeds update -a && ./scripts/feeds install -a
# patch jsonc
patch -p1 < ../PATCH/use_json_object_new_int64.patch
# patch dnsmasq
patch -p1 < ../PATCH/dnsmasq-Update.patch
patch -p1 < ../PATCH/dnsmasq-add-filter-aaaa-option.patch
patch -p1 < ../PATCH/luci-add-filter-aaaa-option.patch
cp -f ../PATCH/900-add-filter-aaaa-option.patch ./package/network/services/dnsmasq/patches/900-add-filter-aaaa-option.patch
rm -rf ./package/base-files/files/etc/init.d/boot
wget -P package/base-files/files/etc/init.d https://raw.githubusercontent.com/project-openwrt/openwrt/openwrt-18.06-k5.4/package/base-files/files/etc/init.d/boot
# Patch Kernel with fullcone
pushd target/linux/generic/hack-5.4
wget https://github.com/coolsnowwolf/lede/raw/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
popd
# Patch FireWall fullcone
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://github.com/project-openwrt/openwrt/raw/master/package/network/config/firewall/patches/fullconenat.patch
# Patch LuCI fullcone-switch
patch -p1 < ../PATCH/fullconenat-switch.patch
# FullCone Module
cp -rf ../PATCH/fullconenat ./package/network/fullconenat
# Patch FireWall with SFE-switch
patch -p1 < ../PATCH/luci-app-firewall_add_sfe_switch.patch
# Patch Kernel with SFE
pushd target/linux/generic/hack-5.4
wget https://github.com/coolsnowwolf/lede/raw/master/target/linux/generic/hack-5.4/953-net-patch-linux-kernel-to-support-shortcut-fe.patch
popd
# SFE Module
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe package/lean/shortcut-fe
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/fast-classifier package/lean/fast-classifier
cp -f ../PATCH/shortcut-fe package/base-files/files/etc/init.d
# NIC
cp -f ../PATCH/fa-rk3399-netdev-cpu package/base-files/files/etc/init.d
# Add R8168 driver
svn co https://github.com/project-openwrt/openwrt/branches/master/package/ctcgfw/r8168 package/new/r8168
# Arpbind
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-arpbind package/lean/luci-app-arpbind
# AutoCore
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/autocore package/lean/autocore
rm -rf feeds/packages/utils/coremark/
rm -rf package/feeds/packages/coremark
svn co https://github.com/project-openwrt/packages/trunk/utils/coremark feeds/packages/utils/coremark
ln -sf ../../../feeds/packages/utils/coremark ./package/feeds/packages/coremark
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
