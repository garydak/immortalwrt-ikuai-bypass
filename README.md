# ⚡ ImmortalWrt 终极旁路由自动化构建系统 (PVE 9.2.2 & ESXi)

> **全自动化构建 · 零配置即刷即用 · 深度集成 iKuai Bypass · 完美释放双线多线负载 · 上游稳定版自动巡检追踪**

---

## 📖 项目简介

本项目是专为 **爱快（iKuai）+ ImmortalWrt 旁路由** 双软路由架构量身打造的高性能、高可用自动化固件构建系统。

基于 GitHub Actions 与 ImmortalWrt 官方 ImageBuilder 引擎构建，深度融合了 [joyanhui/ikuai-bypass](https://github.com/joyanhui/ikuai-bypass) 下一代下一跳智能分流技术，彻底解决传统旁路由“一人折腾、全家断网”的单点故障痛点，并完美解决了多 WAN 环境下国内流量死锁导致多线负载失效的行业难题！

---

## 🌟 固件核心优势与特性

### 1. 终结旁路由单点故障（电信级高可用）
* **权威网关收归爱快**：局域网 DHCP 默认网关与 DNS 保持为爱快主路由（`192.168.0.1`）。
* **旁路由宕机免死**：无论 OpenWrt 重启、升级、核心崩溃还是死机，全家正常上网、看电视、工作通讯 **100% 毫秒不卡顿、毫无感知**！
* **国内流量零损耗直出**：国内日常流量（占 95% 以上）由爱快直接转发至光猫原生宽带，不经过旁路由虚拟网卡中转，大幅降低 CPU 负载与发热，测速轻松跑满千兆/双千兆极限。

### 2. 双宽带多线负载完美兼容（2:1 并发叠加）
* **解除端口分流死锁**：深度优化了分流策略，彻底移除了将国内流量死锁在单一 WAN 口的传统弊端。
* **原生负载均衡生效**：所有国内数据包自然进入爱快底层的 `ML_1` (wan1:wan2 = 2:1) 多线负载策略，双宽带并发叠加发挥到极致。

### 3. 精准智能分流与 NAS 专线支持
* **下一跳定向引流**：仅将真正命中 GFWList 与境外特定网段（如 Telegram）的目标流量下一跳送入 OpenWrt 旁路由（`192.168.0.2`），由 OpenClash（TUN 模式）进行无感加速。
* **NAS 专线完整覆盖**：NAS 设备（`192.168.0.188`）全协议（`tcp+udp`）严格绑定 WAN2，既保障远程 Web/DSM 访问源进源出，又完美支持 PT/BT 极速做种与 P2P 异地组网打洞。

### 4. 首次开机零配置（Zero-Touch Provisioning）
* 刷机首次开机，系统通过底层的 `uci-defaults` 脚本静默执行初始化：
  * 自动锁定静态 IP：**`192.168.0.2/24`**（严格遵循新版 CIDR 规范，杜绝 `/32` 单机掩码死机陷阱）；
  * 自动将网关与 DNS 指向爱快 **`192.168.0.1`**；
  * 自动清理无用的 WAN/WAN6 拨号口；
  * 彻底关闭旁路由 DHCP 与 IPv6 RA 宣告，避免局域网地址冲突；
  * 强制语言为简体中文，并自动预埋已调优的 `config.yml` 启动 bypass 服务。

### 5. 双平台原生镜像双向直出
* **PVE 9.2.2 专用**：`immortalwrt-pve.qcow2`（VirtIO 极致压缩，体积仅 ~35MB，一键命令挂载开机）。
* **ESXi 专用**：`immortalwrt-esxi.vmdk.gz`（monolithicFlat 单盘扁平格式，解压直接挂载）。
* 内置 **`qemu-ga`（QEMU Guest Agent）**，PVE 仪表盘实时呈现真实 IP 与流量，支持平滑一键平稳关机。

### 6. 上游最新稳定版全天候自动追踪与编译
* 每天早晨 08:00（UTC 00:00）GitHub Actions 自动调取官方 API 探测上游发布；
* 只要检测到 ImmortalWrt 发布了新正式版本（如 `24.10.1`、`25.12.0`），自动启动编译并发布为 GitHub Releases，永久直链下载！

---

## 📦 预装核心软件包清单

| 类别 | 包含软件包 | 作用说明 |
| :--- | :--- | :--- |
| **旁路分流** | `luci-app-ikuai-bypass` + x86_64 CLI 核心 | 自动抓取规则并调用爱快官方 API 增量同步 |
| **出海代理** | `luci-app-openclash`, `kmod-tun`, `kmod-nft-tproxy`, `kmod-nft-nat` | Meta 内核支持，TUN 模式低延迟透明转发 |
| **网络基础** | `-dnsmasq`, `dnsmasq-full`, `bind-dig`, `ip-full`, `ipset` | 完整 DNS 解析与 IPSet 路由支持 |
| **虚拟化** | `qemu-ga` | PVE / ESXi 虚拟机状态通信与平滑电源管理 |
| **系统瘦身** | 剔除所有物理网卡驱动 (`-kmod-e1000e`, `-kmod-r8169` 等) 及 `-ppp` | 极致精简，系统内存占用极低，启动飞快 |

---

## 🚀 镜像部署说明

### 1. PVE 9.2.2 极速部署（推荐 ⭐⭐⭐）
1. 在 PVE 网页控制台新建虚拟机（ID 填 `102`，名称起名 `OpenWrt`，网络选择 `vmbr0`，勾选 `Qemu Agent`，磁盘页点击垃圾桶删掉默认空盘）；
2. 从 Releases 中下载 `immortalwrt-pve.qcow2` 并上传到 PVE 的 `/root/` 目录；
3. 打开 PVE 节点的 Shell 终端执行导入命令：
   ```bash
   qm importdisk 102 immortalwrt-pve.qcow2 local-lvm
   ```
4. 回到 PVE 网页：
   * 在虚拟机的【硬件】中双击挂载刚生成的未分配磁盘（总线选择 **SCSI** 并确认）；
   * 在【选项】->【引导顺序】中勾选该 SCSI 磁盘并拖动到第一位；
   * 点击【启动】开机！仪表盘将自动识别出 IP：`192.168.0.2`。

### 2. ESXi 部署
1. 下载 Releases 中的 `immortalwrt-esxi.vmdk.gz` 并解压得到 `immortalwrt-esxi.vmdk`；
2. 上传至 ESXi 存储器，新建虚拟机并选择“使用现有磁盘”，挂载开机即可。

---

## 🙏 致敬与鸣谢

* [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)：优秀强大的开源软路由系统与 ImageBuilder 架构。
* [joyanhui/ikuai-bypass](https://github.com/joyanhui/ikuai-bypass)：卓越的爱快自动化旁路分流项目，带来全新的网络拓扑灵感。
* [vernesong/OpenClash](https://github.com/vernesong/OpenClash)：功能强大的图形化规则代理核心。

---
*Licensed under GPL-3.0.*
