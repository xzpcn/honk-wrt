# OpenWRT-CI 
云编译OpenWRT固件，开启内核eBPF，内置honk内核级透明代理（Rust实现，daeuniverse出品，替代dae/daed）

主编译机型：Redmi AX5 JDC（IPQ6000/512M，配置 IPQ60XX-AX5JDC，带WiFi）。
已移除Docker相关组件（dockerd、docker-compose、containerd、luci-app-dockerman等），节省内存。
其余机型配置文件保留，如需编译可自行修改工作流矩阵。

官方版：
https://github.com/immortalwrt/immortalwrt.git

高通版：
https://github.com/VIKINGYFY/immortalwrt.git

LiBWrt：
https://github.com/LiBwrt/openwrt-6.x

honk上游（早期alpha阶段，关注上游更新）：
https://github.com/daeuniverse/honk

honk使用说明：

默认配置全部直连，需先添加节点/订阅和路由规则再启用服务（LuCI：服务→honk，或doona面板）。
doona Web面板：http://路由器LAN IP:9527/（首次访问创建管理员，仅HTTP，WAN侧默认关闭）。
Clash兼容API：127.0.0.1:9090（可接zashboard等面板）。
配置文件：/etc/honk/config.dae（dae语法）；geoip/geosite数据由v2ray-geodata-updater每周自动更新并热重载honk。
honk与dae互斥，本固件已彻底移除dae/daed。

# 固件简要说明：

固件每天早上4点自动编译。

固件信息里的时间为编译开始的时间，方便核对上游源码提交时间。

MEDIATEK系列、QUALCOMMAX系列、ROCKCHIP系列、X86系列。

# 目录简要说明：

workflows——自定义CI配置

Scripts——自定义脚本

Config——自定义配置
