#!/bin/bash
git clone -b master https://git.openwrt.org/openwrt/openwrt.git openwrt
cd openwrt
git checkout master
git reset --hard a472791
git checkout -b hooo a472791
cd ../
git clone -b main --depth 1 https://github.com/Lienol/openwrt.git openwrt-lienol
git clone -b main --depth 1 https://github.com/Lienol/openwrt-packages packages-lienol
git clone -b main --depth 1 https://github.com/Lienol/openwrt-luci luci-lienol
git clone -b linksys-ea6350v3-mastertrack --depth 1 https://github.com/NoTengoBattery/openwrt NoTengoBattery
exit 0
