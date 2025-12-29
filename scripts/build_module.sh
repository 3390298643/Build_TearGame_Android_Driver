#!/bin/bash
# Build Hello World Kernel Module
# This script compiles the kernel module against GKI 6.12 kernel source

set -e
set -o pipefail

# Configuration
KERNEL_DIR="${KERNEL_DIR:-kernel-source}"
KERNEL_SRC="${KERNEL_DIR}/common"
KERNEL_OUT="${KERNEL_OUT:-out}"
MODULE_DIR="${MODULE_DIR:-hello_module}"
MODULE_OUT="${MODULE_OUT:-module_out}"
ARCH="arm64"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check kernel source
    if [ ! -d "${KERNEL_SRC}" ]; then
        log_error "Kernel source not found at ${KERNEL_SRC}"
        exit 1
    fi
    
    # Check kernel build output (for Module.symvers)
    if [ ! -d "${KERNEL_OUT}" ]; then
        log_error "Kernel build output not found at ${KERNEL_OUT}"
        log_error "Please run build_kernel.sh first"
        exit 1
    fi
    
    # Check module source
    if [ ! -d "${MODULE_DIR}" ]; then
        log_error "Module source not found at ${MODULE_DIR}"
        exit 1
    fi
    
    if [ ! -f "${MODULE_DIR}/hello.c" ]; then
        log_error "hello.c not found in ${MODULE_DIR}"
        exit 1
    fi
    
    # Check clang
    if ! command -v clang &> /dev/null; then
        log_error "clang is not installed"
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

# Setup environment
setup_environment() {
    log_info "Setting up build environment..."
    
    # Export environment variables
    export ARCH="${ARCH}"
    export SUBARCH="${ARCH}"
    export LLVM=1
    export LLVM_IAS=1
    export CROSS_COMPILE="aarch64-linux-gnu-"
    
    # Clang/LLVM tools
    export CC="clang"
    export LD="ld.lld"
    export AR="llvm-ar"
    export NM="llvm-nm"
    export OBJCOPY="llvm-objcopy"
    export OBJDUMP="llvm-objdump"
    export STRIP="llvm-strip"
    
    log_info "Build environment configured"
}

# Build module
build_module() {
    log_info "Building Hello World kernel module..."
    
    # Create output directory
    mkdir -p "${MODULE_OUT}"
    
    # Get absolute paths
    ABS_KERNEL_SRC="$(cd "${KERNEL_SRC}" && pwd)"
    ABS_KERNEL_OUT="$(cd "${KERNEL_OUT}" && pwd)"
    ABS_MODULE_DIR="$(cd "${MODULE_DIR}" && pwd)"
    ABS_MODULE_OUT="$(cd "${MODULE_OUT}" && pwd)"
    
    log_info "Kernel source: ${ABS_KERNEL_SRC}"
    log_info "Kernel output: ${ABS_KERNEL_OUT}"
    log_info "Module source: ${ABS_MODULE_DIR}"
    
    # Build module
    cd "${ABS_MODULE_DIR}"
    
    make -C "${ABS_KERNEL_SRC}" \
        O="${ABS_KERNEL_OUT}" \
        M="${ABS_MODULE_DIR}" \
        ARCH="${ARCH}" \
        CROSS_COMPILE="${CROSS_COMPILE}" \
        CC="${CC}" \
        LD="${LD}" \
        AR="${AR}" \
        NM="${NM}" \
        OBJCOPY="${OBJCOPY}" \
        OBJDUMP="${OBJDUMP}" \
        STRIP="${STRIP}" \
        LLVM=1 \
        modules
    
    if [ $? -ne 0 ]; then
        log_error "Module build failed"
        exit 1
    fi
    
    log_info "Module build completed"
}

# Verify and copy output
verify_and_copy() {
    log_info "Verifying module build..."
    
    if [ ! -f "${MODULE_DIR}/hello.ko" ]; then
        log_error "hello.ko not found"
        exit 1
    fi
    
    # Copy to output directory
    cp "${MODULE_DIR}/hello.ko" "${MODULE_OUT}/"
    
    # Copy Module.symvers if exists
    if [ -f "${MODULE_DIR}/Module.symvers" ]; then
        cp "${MODULE_DIR}/Module.symvers" "${MODULE_OUT}/"
    fi
    
    # Get module info
    MODULE_SIZE=$(du -h "${MODULE_OUT}/hello.ko" | cut -f1)
    
    log_info "Module built successfully"
    log_info "  Path: ${MODULE_OUT}/hello.ko"
    log_info "  Size: ${MODULE_SIZE}"
    
    # Show module info if modinfo is available
    if command -v modinfo &> /dev/null; then
        log_info "Module information:"
        modinfo "${MODULE_OUT}/hello.ko" 2>/dev/null || true
    fi
    
    log_info "Module build verification passed"
}

# Clean module build
clean_module() {
    log_info "Cleaning module build..."
    
    cd "${MODULE_DIR}"
    
    # Clean build artifacts
    rm -f *.o *.ko *.mod.c *.mod.o *.order *.symvers .*.cmd
    rm -rf .tmp_versions
    
    log_info "Module cleaned"
}

# Main function
main() {
    log_info "Starting Hello World module build"
    
    # Get absolute paths
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    WORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
    
    # Update paths to absolute
    KERNEL_DIR="${WORK_DIR}/${KERNEL_DIR}"
    KERNEL_SRC="${KERNEL_DIR}/common"
    KERNEL_OUT="${WORK_DIR}/${KERNEL_OUT}"
    MODULE_DIR="${WORK_DIR}/${MODULE_DIR}"
    MODULE_OUT="${WORK_DIR}/${MODULE_OUT}"
    
    # Parse arguments
    if [ "$1" == "clean" ]; then
        clean_module
        exit 0
    fi
    
    check_prerequisites
    setup_environment
    build_module
    verify_and_copy
    
    log_info "Module build completed successfully!"
    log_info "Output: ${MODULE_OUT}/hello.ko"
}

# Run main function
main "$@"
