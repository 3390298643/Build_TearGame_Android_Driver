# Requirements Document

## Introduction

本功能旨在创建一个完整的 GitHub Actions 工作流项目，实现自动化下载 Google GKI 6.12-android16 内核源码、编译完整内核以及编译 Hello World 内核模块。用户只需将代码推送到 GitHub 仓库，即可通过工作流自动完成所有编译任务。

## Glossary

- **GKI**: Generic Kernel Image，谷歌通用内核镜像
- **Workflow**: GitHub Actions 工作流，自动化 CI/CD 流程
- **Kernel_Module**: Linux 内核模块，可动态加载的内核扩展
- **Clang_Toolchain**: LLVM/Clang 编译工具链
- **repo**: Google 的多仓库管理工具

## Requirements

### Requirement 1: 项目结构初始化

**User Story:** As a developer, I want a well-organized project structure, so that I can easily manage and maintain the workflow files and kernel module source code.

#### Acceptance Criteria

1. THE Project_Structure SHALL contain a `.github/workflows/` directory for GitHub Actions workflow files
2. THE Project_Structure SHALL contain a `hello_module/` directory for Hello World kernel module source code
3. THE Project_Structure SHALL contain a `scripts/` directory for helper scripts
4. THE Project_Structure SHALL contain a `README.md` file with usage instructions

### Requirement 2: Hello World 内核模块源码

**User Story:** As a developer, I want a simple Hello World kernel module source code, so that I can verify the kernel module compilation process works correctly.

#### Acceptance Criteria

1. THE Hello_Module SHALL contain a `hello.c` source file with basic module init and exit functions
2. THE Hello_Module SHALL contain a `Makefile` for out-of-tree module compilation
3. WHEN the module is loaded, THE Hello_Module SHALL print "Hello, GKI 6.12 World!" to kernel log
4. WHEN the module is unloaded, THE Hello_Module SHALL print "Goodbye, GKI 6.12 World!" to kernel log
5. THE Hello_Module SHALL be compatible with GKI 6.12 kernel (MODULE_LICENSE, MODULE_AUTHOR, MODULE_DESCRIPTION)

### Requirement 3: 内核源码下载脚本

**User Story:** As a developer, I want an automated script to download GKI 6.12-android16 kernel source, so that the workflow can obtain the kernel source without manual intervention.

#### Acceptance Criteria

1. THE Download_Script SHALL use Google's repo tool to sync kernel source
2. THE Download_Script SHALL target the `android16-6.12` branch from Google's kernel manifest
3. THE Download_Script SHALL handle repo initialization and synchronization
4. IF the download fails, THEN THE Download_Script SHALL exit with a non-zero status code and error message

### Requirement 4: 内核编译脚本

**User Story:** As a developer, I want an automated script to compile the GKI kernel, so that the workflow can build the kernel image automatically.

#### Acceptance Criteria

1. THE Build_Script SHALL set up the correct environment variables for cross-compilation
2. THE Build_Script SHALL use Clang toolchain for kernel compilation
3. THE Build_Script SHALL compile the kernel for aarch64 architecture
4. THE Build_Script SHALL generate the kernel Image file
5. IF the compilation fails, THEN THE Build_Script SHALL exit with a non-zero status code

### Requirement 5: 内核模块编译脚本

**User Story:** As a developer, I want an automated script to compile the Hello World kernel module, so that the workflow can build the module against the compiled kernel.

#### Acceptance Criteria

1. THE Module_Build_Script SHALL compile the Hello World module against the GKI 6.12 kernel source
2. THE Module_Build_Script SHALL use the same Clang toolchain as kernel compilation
3. THE Module_Build_Script SHALL generate a `.ko` file as output
4. IF the module compilation fails, THEN THE Module_Build_Script SHALL exit with a non-zero status code

### Requirement 6: GitHub Actions 工作流

**User Story:** As a developer, I want a GitHub Actions workflow that automates the entire process, so that I can trigger kernel and module compilation by pushing code to the repository.

#### Acceptance Criteria

1. THE Workflow SHALL be triggered on push to main/master branch
2. THE Workflow SHALL be manually triggerable via workflow_dispatch
3. THE Workflow SHALL run on ubuntu-latest runner
4. THE Workflow SHALL install all required dependencies (repo, clang, build tools)
5. THE Workflow SHALL download GKI 6.12-android16 kernel source
6. THE Workflow SHALL compile the kernel
7. THE Workflow SHALL compile the Hello World kernel module
8. THE Workflow SHALL upload compiled artifacts (kernel Image, hello.ko) as workflow artifacts
9. IF any step fails, THEN THE Workflow SHALL stop and report the failure

### Requirement 7: 文档和使用说明

**User Story:** As a developer, I want clear documentation, so that I can understand how to use and customize the workflow.

#### Acceptance Criteria

1. THE README SHALL explain the project purpose and structure
2. THE README SHALL provide step-by-step instructions for using the workflow
3. THE README SHALL list all prerequisites and dependencies
4. THE README SHALL explain how to customize the kernel module
