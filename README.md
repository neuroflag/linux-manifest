
# 获取SDK

## XML 介绍
以rk356x为例子：

* rk356x_linux_release.xml SDK的 release 版本
* rk356x_linux_next.xml SDK的开发版本
* rk356x_linux_bsp_release.xml bsp的 release 版本
* rk356x_linux_bsp_next.xml bsp的开发版本


## 拉取SDK
```
mkdir ~/proj/rk356x_linux_release_20211019/
cd ~/proj/rk356x_linux_release_20211019/

## 完整 SDK
repo init --no-clone-bundle --repo-url https://gitlab.com/firefly-linux/git-repo.git -u https://gitlab.com/firefly-linux/manifests.git -b master -m rk356x_linux_release.xml

## BSP （ 只包含基础仓库和编译工具 ）
## BSP 包括 device/rockchip 、docs 、 kernel 、 u-boot 、 rkbin 、 tools 和交叉编译链
repo init --no-clone-bundle --repo-url https://gitlab.com/firefly-linux/git-repo.git -u https://gitlab.com/firefly-linux/manifests.git -b master -m rk356x_linux_bsp_release.xml
```

后续可以使用以下命令更新 SDK：
```
.repo/repo/repo sync -c --no-tags
```