#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# ===================== 新增：Samba4 菜单位置调整 =====================
# 功能：将 Samba4 菜单从 admin/nas 迁移到 admin/services
# 可自定义配置
MENU_NAME="Network Shares"  # 菜单显示名称（可改为中文："Samba 共享"）
MENU_PRIORITY=10            # 排序优先级（数值越小越靠前）

# 颜色输出函数
red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }

# 查找 Samba4 控制器文件（兼容 Lean 源码/官方 feeds）
SAMBA4_CTRL=""
if [ -f "package/lean/luci-app-samba4/luasrc/controller/samba4.lua" ]; then
    SAMBA4_CTRL="package/lean/luci-app-samba4/luasrc/controller/samba4.lua"
elif [ -f "feeds/luci/applications/luci-app-samba4/luasrc/controller/samba4.lua" ]; then
    SAMBA4_CTRL="feeds/luci/applications/luci-app-samba4/luasrc/controller/samba4.lua"
fi

# 执行菜单路径修改
if [ -n "$SAMBA4_CTRL" ]; then
    # 备份原文件（避免重复修改）
    [ ! -f "${SAMBA4_CTRL}.bak" ] && cp -f "$SAMBA4_CTRL" "${SAMBA4_CTRL}.bak"
    # 替换菜单路径、名称、优先级
    sed -i "/entry({\"admin\",.*\"samba4\"}/c\    entry({\"admin\", \"services\", \"samba4\"}, cbi(\"samba4\"), _(\"${MENU_NAME}\"), ${MENU_PRIORITY}).dependent = true" "$SAMBA4_CTRL"
    green "✅ Samba4 菜单位置已调整至：admin/services (名称：${MENU_NAME}，优先级：${MENU_PRIORITY})"
else
    yellow "⚠️  未找到 luci-app-samba4 控制器文件，跳过菜单调整"
fi
# ===================== Samba4 菜单调整结束 =====================

# 原有自定义配置（保留不变）
# Modify default IP   第一行19.07的路径   第二行23.05的路径
#sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate
#sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/luci2/bin/config_generate

# 修改主机名
#sed -i 's/LEDE/OpenWrt/g' package/base-files/files/bin/config_generate
#sed -i 's/LEDE/OpenWrt/g' package/base-files/luci2/bin/config_generate

# 修正俩处错误的翻译
sed -i 's/<%:Up%>/<%:Move up%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Down%>/<%:Move down%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm

# 修改opkg.conf文件-测试没有效果
#sed -i '/option overlay_root \/overlay/a #option check_signature' /etc/opkg.conf

# 设置为bootstrap默认主题-测试没有效果
#sed -i 's/luci-theme-argon/luci-theme-bootstrap/g' feeds/luci/collections/luci/Makefile
#sed -i 's/luci-theme-argon/luci-theme-bootstrap/g' feeds/luci/collections/luci-light/Makefile
#sed -i 's/luci-theme-argon/luci-theme-bootstrap/g' feeds/luci/collections/luci-nginx/Makefile
#sed -i 's/luci-theme-argon/luci-theme-bootstrap/g' feeds/luci/collections/luci-ssl-nginx/Makefile

# 拉取passwall
git clone https://github.com/xiaorouji/openwrt-passwall --depth=1 package/passwall
git clone https://github.com/xiaorouji/openwrt-passwall2 --depth=1 package/passwall2
git clone https://github.com/xiaorouji/openwrt-passwall-packages
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky
   

# 增加 alist （在 ./scripts/feeds install -a 操作之后更换 golang 版本）
#rm -rf feeds/packages/lang/golang
#svn export https://github.com/sbwml/packages_lang_golang/branches/19.x feeds/packages/lang/golang

# tmp fix-20230819之前编译失败回滚配置
#wget -O ./package/kernel/linux/modules/netsupport.mk https://raw.githubusercontent.com/coolsnowwolf/lede/3ef1f5ade3b8f6527bbc4eb9494138de66e07d13/package/kernel/linux/modules/netsupport.mk

# 2023-08-29 aliyundrive-webdav 编译报错回滚到2.2.1
#curl -o ./feeds/packages/multimedia/aliyundrive-webdav/Makefile https://raw.githubusercontent.com/Jason6111/OpenWrt_Personal/main/other/aliyun/Makefile

# 临时修复acpid,aliyundrive-webdav,xfsprogs,perl-html-parser,v2dat 导致的编译失败问题
#sed -i 's#flto#flto -D_LARGEFILE64_SOURCE#g' feeds/packages/utils/acpid/Makefile
#sed -i 's/stripped/release/g' feeds/packages/multimedia/aliyundrive-webdav/Makefile
#sed -i 's#SYNC#SYNC -D_LARGEFILE64_SOURCE#g' feeds/packages/utils/xfsprogs/Makefile
sed -i 's/REENTRANT -D_GNU_SOURCE/LARGEFILE64_SOURCE/g' feeds/packages/lang/perl/perlmod.mk
sed -i 's#GO_PKG_TARGET_VARS.*# #g' feeds/packages/utils/v2dat/Makefile

# 修复v2ray-plugin编译失败
rm -rf feeds/luci/applications/luci-app-mosdns
#rm -rf feeds/packages/net/{alist,adguardhome,xray*,v2ray*,v2ray*,sing*,smartdns}
#rm -rf feeds/packages/lang/golang
#git clone https://github.com/kenzok8/golang feeds/packages/lang/golang
rm -rf feeds/packages/lang/golang
rm -rf feeds/luci/themes/luci-theme-design
rm -rf feeds/luci/applications/luci-app-design-config

git clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
