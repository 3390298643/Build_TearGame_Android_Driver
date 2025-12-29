# GKI 6.12 Kernel Build Workflow


@TearGame
@teartalk
泪心 tearhacker@outlook.com
[![Build GKI 6.12 Kernel and Module](https://github.com/YOUR_USERNAME/gki-kernel-workflow/actions/workflows/build.yml/badge.svg)](https://github.com/YOUR_USERNAME/gki-kernel-workflow/actions/workflows/build.yml)

自动化构建 Google GKI 6.12-android16 内核和 Hello World 内核模块的 GitHub Actions 工作流。

## 功能特性

- ✅ 自动下载 Google GKI 6.12-android16 内核源码
- ✅ 使用 Clang/LLVM 工具链编译内核
- ✅ 编译 Hello World 内核模块
- ✅ 自动上传编译产物
- ✅ 支持手动触发和推送触发

## 项目结构

```
gki-kernel-workflow/
├── .github/
│   └── workflows/
│       └── build.yml           # GitHub Actions 工作流配置
├── hello_module/
│   ├── hello.c                 # Hello World 模块源码
│   └── Makefile                # 模块编译 Makefile
├── scripts/
│   ├── download_kernel.sh      # 内核源码下载脚本
│   ├── build_kernel.sh         # 内核编译脚本
│   └── build_module.sh         # 模块编译脚本
└── README.md                   # 本文档
```

## 快速开始

### 1. Fork 或克隆仓库

```bash
git clone https://github.com/YOUR_USERNAME/gki-kernel-workflow.git
cd gki-kernel-workflow
```

### 2. 推送到 GitHub

```bash
git remote set-url origin https://github.com/YOUR_USERNAME/gki-kernel-workflow.git
git push -u origin main
```

### 3. 触发工作流

工作流会在以下情况自动触发：
- 推送到 `main` 或 `master` 分支
- 创建 Pull Request

也可以手动触发：
1. 进入 GitHub 仓库的 **Actions** 页面
2. 选择 **Build GKI 6.12 Kernel and Module** 工作流
3. 点击 **Run workflow**
4. 可选择配置参数后点击 **Run workflow**

### 4. 下载编译产物

工作流完成后，在 Actions 页面的运行记录中可以下载：
- `gki-kernel-6.12-build` - 包含内核 Image 和构建信息
- `hello-module` - 包含 hello.ko 模块文件

## 编译产物

| 文件 | 说明 |
|------|------|
| `Image` | 编译后的内核镜像 (aarch64) |
| `hello.ko` | Hello World 内核模块 |
| `Module.symvers` | 模块符号表 |
| `build_info.txt` | 构建信息 |

## 工作流参数

手动触发时可配置以下参数：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `kernel_branch` | `android16-6.12` | 内核分支 |
| `build_kernel` | `true` | 是否编译内核 |
| `build_module` | `true` | 是否编译模块 |

## 自定义内核模块

### 修改 Hello World 模块

编辑 `hello_module/hello.c`：

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("Your Module Description");

static int __init your_module_init(void)
{
    pr_info("Your module loaded!\n");
    // 添加你的初始化代码
    return 0;
}

static void __exit your_module_exit(void)
{
    pr_info("Your module unloaded!\n");
    // 添加你的清理代码
}

module_init(your_module_init);
module_exit(your_module_exit);
```

### 添加新模块

1. 在 `hello_module/` 目录创建新的 `.c` 文件
2. 修改 `hello_module/Makefile`：

```makefile
obj-m += hello.o
obj-m += your_new_module.o
```

## 本地编译

### 前置条件

- Ubuntu 20.04+ 或类似 Linux 发行版
- 至少 50GB 磁盘空间
- 至少 8GB 内存

### 安装依赖

```bash
sudo apt-get update
sudo apt-get install -y \
    git curl wget python3 build-essential \
    bc bison flex libssl-dev libelf-dev \
    clang lld llvm \
    gcc-aarch64-linux-gnu
```

### 下载内核源码

```bash
chmod +x scripts/download_kernel.sh
./scripts/download_kernel.sh
```

### 编译内核

```bash
chmod +x scripts/build_kernel.sh
./scripts/build_kernel.sh
```

### 编译模块

```bash
chmod +x scripts/build_module.sh
./scripts/build_module.sh
```

## 在设备上加载模块

```bash
# 推送模块到设备
adb push hello.ko /data/local/tmp/

# 加载模块 (需要 root)
adb shell su -c "insmod /data/local/tmp/hello.ko"

# 查看内核日志
adb shell dmesg | grep -i hello

# 卸载模块
adb shell su -c "rmmod hello"
```

## 注意事项

1. **编译时间**: 完整内核编译可能需要 1-3 小时
2. **磁盘空间**: GitHub Actions runner 有磁盘限制，工作流会自动清理空间
3. **KMI 兼容性**: 模块需要与目标设备的内核 KMI 版本匹配
4. **签名**: 某些设备可能需要签名的内核模块

## 故障排除

### 编译失败

1. 检查 Actions 日志中的错误信息
2. 确保所有依赖已正确安装
3. 检查磁盘空间是否充足

### 模块加载失败

1. 检查内核版本是否匹配
2. 检查 KMI 符号版本
3. 使用 `dmesg` 查看详细错误

## 许可证

本项目采用 GPL-2.0 许可证。

## 参考链接

- [Android GKI 文档](https://source.android.com/docs/core/architecture/kernel/generic-kernel-image)
- [Linux 内核模块编程指南](https://tldp.org/LDP/lkmpg/2.6/html/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
