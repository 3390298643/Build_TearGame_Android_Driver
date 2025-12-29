#!/bin/bash
# Build GKI 6.12 Kernel
# This script compiles the kernel using Clang toolchain for aarch64

set -e
set -o pipefail

# Configuration
KERNEL_DIR="${KERNEL_DIR:-kernel-source}"
KERNEL_SRC="${KERNEL_DIR}/common"
OUT_DIR="${OUT_DIR:-out}"
ARCH="arm64"
DEFCONFIG="gki_defconfig"

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
        log_error "Please run download_kernel.sh first"
        exit 1
    fi
    
    # Check clang
    if ! command -v clang &> /dev/null; then
        log_error "clang is not installed"
        exit 1
    fi
    
    # Check other tools
    for tool in make ld.lld llvm-ar llvm-nm llvm-objcopy; do
        if ! command -v $tool &> /dev/null; then
            log_warn "$tool not found, will try to continue"
        fi
    done
    
    log_info "Prerequisites check passed"
}

# Setup environment
setup_environment() {
    log_info "Setting up build environment..."
    
    # Get number of CPUs for parallel build
    JOBS=$(nproc)
    
    # Export environment variables
    export ARCH="${ARCH}"
    export SUBARCH="${ARCH}"
    
    # LLVM/Clang settings
    export LLVM=1
    export LLVM_IAS=1
    
    # Cross compile prefix (for non-LLVM tools if needed)
    export CROSS_COMPILE="aarch64-linux-gnu-"
    
    # Output directory
    export KBUILD_OUTPUT="${OUT_DIR}"
    
    log_info "Build environment configured"
    log_info "  ARCH: ${ARCH}"
    log_info "  LLVM: ${LLVM}"
    log_info "  JOBS: ${JOBS}"
    log_info "  OUTPUT: ${OUT_DIR}"
}

# Generate defconfig
generate_defconfig() {
    log_info "Generating kernel config..."
    
    mkdir -p "${OUT_DIR}"
    
    cd "${KERNEL_SRC}"
    
    # Try gki_defconfig first, fallback to defconfig
    if [ -f "arch/${ARCH}/configs/${DEFCONFIG}" ]; then
        make O="${OUT_DIR}" ARCH="${ARCH}" LLVM=1 "${DEFCONFIG}"
    elif [ -f "arch/${ARCH}/configs/defconfig" ]; then
        log_warn "gki_defconfig not found, using defconfig"
        make O="${OUT_DIR}" ARCH="${ARCH}" LLVM=1 defconfig
    else
        log_error "No suitable defconfig found"
        exit 1
    fi
    
    if [ $? -ne 0 ]; then
        log_error "Failed to generate kernel config"
        exit 1
    fi
    
    log_info "Kernel config generated successfully"
}

# Build kernel
build_kernel() {
    log_info "Building kernel (this will take a while)..."
    
    cd "${KERNEL_SRC}"
    
    # Build kernel image
    make O="${OUT_DIR}" \
        ARCH="${ARCH}" \
        LLVM=1 \
        LLVM_IAS=1 \
        -j${JOBS} \
        Image
    
    if [ $? -ne 0 ]; then
        log_error "Kernel build failed"
        exit 1
    fi
    
    log_info "Kernel build completed successfully"
}

# Verify build
verify_build() {
    log_info "Verifying kernel build..."
    
    IMAGE_PATH="${KERNEL_SRC}/${OUT_DIR}/arch/${ARCH}/boot/Image"
    
    if [ ! -f "${IMAGE_PATH}" ]; then
        # Try alternative path
        IMAGE_PATH="${OUT_DIR}/arch/${ARCH}/boot/Image"
    fi
    
    if [ ! -f "${IMAGE_PATH}" ]; then
        log_error "Kernel Image not found"
        exit 1
    fi
    
    IMAGE_SIZE=$(du -h "${IMAGE_PATH}" | cut -f1)
    log_info "Kernel Image built successfully"
    log_info "  Path: ${IMAGE_PATH}"
    log_info "  Size: ${IMAGE_SIZE}"
    
    # Copy to output directory root for easy access
    cp "${IMAGE_PATH}" "${OUT_DIR}/Image" 2>/dev/null || true
    
    log_info "Kernel build verification passed"
}

# Main function
main() {
    log_info "Starting GKI 6.12 kernel build"
    
    # Get absolute paths
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    WORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
    
    # Update paths to absolute
    KERNEL_DIR="${WORK_DIR}/${KERNEL_DIR}"
    KERNEL_SRC="${KERNEL_DIR}/common"
    OUT_DIR="${WORK_DIR}/${OUT_DIR}"
    
    check_prerequisites
    setup_environment
    generate_defconfig
    build_kernel
    verify_build
    
    log_info "Kernel build completed successfully!"
    log_info "Output directory: ${OUT_DIR}"
}

# Run main function
main "$@"
