#!/bin/bash
git clone -b master https://git.openwrt.org/openwrt/openwrt.git openwrt
cd openwrt
git checkout master
git reset --hard a472791
git checkout -b hooo a472791
cd ../
git clone -b main --depth 1 https://github.com/Lienol/openwrt.git openwrt-lienol
exit 0
