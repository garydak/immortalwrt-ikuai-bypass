#!/bin/sh
# 记录执行日志（可在 /tmp/setup.log 查看）
exec >/tmp/setup.log 2>&1

# ========================================================
# 1. 旁路由参数设置（严格遵循 25.12 的 CIDR 规范）
# ========================================================
lan_ip="192.168.0.2/24"    # 重点：带上 /24，杜绝 /32 单机掩码
gateway_ip="192.168.0.1"   # 主路由 iKuai 的 IP
dns_ip="192.168.0.1"       # DNS 指向 iKuai

# 密码为空，登录后提示用户设置密码
passwd -d root >/dev/null 2>&1

# ========================================================
# 2. 清理无用的 WAN/WAN6 拨号口
# ========================================================
uci -q delete network.wan
uci -q delete network.wan6

# ========================================================
# 3. 设置静态网络与主路由网关/DNS
# ========================================================
uci set network.lan.proto='static'
uci set network.lan.ipaddr="$lan_ip"
uci set network.lan.gateway="$gateway_ip"
uci set network.lan.dns="$dns_ip"
uci commit network

# ========================================================
# 4. 彻底关闭旁路由 DHCP 与 IPv6 广播（完全交给 iKuai）
# ========================================================
uci set dhcp.lan.ignore='1'
uci -q delete dhcp.lan.ra
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ndp
uci commit dhcp

# ========================================================
# 5. 强制界面语言为简体中文并设置 Argon 为默认主题
# ========================================================
uci set luci.main.lang='zh_cn'
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

# ========================================================
# 6. 预热 iKuai Bypass 本地离线检测缓存（免联网）
# ========================================================
if [ -d /opt/ikuai-bypass/install-cache ]; then
  mkdir -p /tmp/ikuai-bypass-install-cache/install-file
  cp -rf /opt/ikuai-bypass/install-cache/install.sh /tmp/ikuai-bypass-install-cache/install.sh 2>/dev/null || true
  cp -rf /opt/ikuai-bypass/install-cache/install-file/common.sh /tmp/ikuai-bypass-install-cache/install-file/common.sh 2>/dev/null || true
  chmod +x /tmp/ikuai-bypass-install-cache/install.sh /tmp/ikuai-bypass-install-cache/install-file/common.sh 2>/dev/null || true
  date +%s > /tmp/ikuai-bypass-install-cache/.stamp 2>/dev/null || true
fi

# ========================================================
# 7. 激活并开启 iKuai Bypass 服务开机自启
# ========================================================
if [ -f /etc/init.d/ikuai-bypass ]; then
  chmod +x /etc/init.d/ikuai-bypass
  /etc/init.d/ikuai-bypass enable
  /etc/init.d/ikuai-bypass start
fi

# ========================================================
# 8. 预置 OpenClash 黄金运行参数 (Meta 内核 + linux-amd64-v3 + 禁用开机自动联网更新)
# ========================================================
touch /etc/config/openclash 2>/dev/null || true
uci -q set openclash.config.core_type='Meta'
uci -q set openclash.config.core_version='linux-amd64-v3'
uci -q set openclash.config.auto_update_core='0'
uci -q set openclash.config.auto_update='0'
uci -q commit openclash

if [ -f /etc/openclash/core/clash_meta ]; then
  chmod +x /etc/openclash/core/clash_meta
  ln -sf /etc/openclash/core/clash_meta /etc/openclash/core/clash 2>/dev/null || true
fi

exit 0
#!/bin/sh
# 记录执行日志（可在 /tmp/setup.log 查看）
exec >/tmp/setup.log 2>&1

# ========================================================
# 1. 旁路由参数设置（严格遵循 25.12 的 CIDR 规范）
# ========================================================
lan_ip="192.168.0.2/24"    # 重点：带上 /24，杜绝 /32 单机掩码
gateway_ip="192.168.0.1"   # 主路由 iKuai 的 IP
dns_ip="192.168.0.1"       # DNS 指向 iKuai

# 密码为空，登录后提示用户设置密码
passwd -d root >/dev/null 2>&1

# ========================================================
# 2. 清理无用的 WAN/WAN6 拨号口
# ========================================================
uci -q delete network.wan
uci -q delete network.wan6

# ========================================================
# 3. 设置静态网络与主路由网关/DNS
# ========================================================
uci set network.lan.proto='static'
uci set network.lan.ipaddr="$lan_ip"
uci set network.lan.gateway="$gateway_ip"
uci set network.lan.dns="$dns_ip"
uci commit network

# ========================================================
# 4. 彻底关闭旁路由 DHCP 与 IPv6 广播（完全交给 iKuai）
# ========================================================
uci set dhcp.lan.ignore='1'
uci -q delete dhcp.lan.ra
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ndp
uci commit dhcp

# ========================================================
# 5. 强制界面语言为简体中文并设置 Argon 为默认主题
# ========================================================
uci set luci.main.lang='zh_cn'
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

# ========================================================
# 6. 预热 iKuai Bypass 本地离线检测缓存（免联网）
# ========================================================
if [ -d /opt/ikuai-bypass/install-cache ]; then
  mkdir -p /tmp/ikuai-bypass-install-cache/install-file
  cp -rf /opt/ikuai-bypass/install-cache/install.sh /tmp/ikuai-bypass-install-cache/install.sh 2>/dev/null || true
  cp -rf /opt/ikuai-bypass/install-cache/install-file/common.sh /tmp/ikuai-bypass-install-cache/install-file/common.sh 2>/dev/null || true
  chmod +x /tmp/ikuai-bypass-install-cache/install.sh /tmp/ikuai-bypass-install-cache/install-file/common.sh 2>/dev/null || true
  date +%s > /tmp/ikuai-bypass-install-cache/.stamp 2>/dev/null || true
fi

# ========================================================
# 7. 激活并开启 iKuai Bypass 服务开机自启
# ========================================================
if [ -f /etc/init.d/ikuai-bypass ]; then
  chmod +x /etc/init.d/ikuai-bypass
  /etc/init.d/ikuai-bypass enable
  /etc/init.d/ikuai-bypass start
fi

exit 0
