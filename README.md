为避免重要的更新在某些平台上依赖，现在制定以下规则：

# Firefly Linux repo 仓库管理原则

- 1. 与平台无关，涉及到固件打包、命名、格式等的git仓库，所有平台必须使用一个分支。
- 2. 与平台相关，应用层的软件，所有平台尽量使用同一分支。
- 3. 与平台相关，如内核、u-boot等分支，可以使用不同的分支管理。

附上：
## 1. 必须同一分支管理的仓库：

device/rockchip
tools

## 2. 尽量同一分支管理的仓库：

rkbin
app
buildroot
distro
docs
external
prebuilts
rk-rootfs-build

## 3. 可以使用不同分支管理的仓库：
kernel
u-boot
