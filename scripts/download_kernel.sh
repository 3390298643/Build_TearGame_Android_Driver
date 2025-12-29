#!/bin/bash
# Download GKI 6.12-android16 Kernel Source
# This script uses Google's repo tool to sync the kernel source

set -e
set -o pipefail

# Configuration - use environment variable or default
KERNEL_BRANCH="${KERNEL_BRANCH:-android16-6.12}"
KERNEL_MANIFEST="https://android.googlesource.com/kernel/manifest"
KERNEL_DIR="${KERNEL_DIR:-kernel-source}"

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

# Check if repo is installed
check_repo() {
    if ! command -v repo &> /dev/null; then
        log_error "repo tool is not installed"
        log_info "Installing repo tool..."
        mkdir -p ~/bin
        curl -sL https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
        chmod a+x ~/bin/repo
        export PATH=~/bin:$PATH
        log_info "repo tool installed successfully"
    fi
    
    # Verify repo is working
    repo --version || {
        log_error "repo tool verification failed"
        exit 1
    }
}

# Configure git for repo
configure_git() {
    log_info "Configuring git for repo..."
    git config --global user.email "github-actions@github.com" || true
    git config --global user.name "GitHub Actions" || true
    git config --global color.ui false || true
    # Required for newer git versions
    git config --global init.defaultBranch main || true
    git config --global protocol.version 2 || true
}

# Initialize repo
init_repo() {
    log_info "Initializing repo with branch: ${KERNEL_BRANCH}"
    
    mkdir -p "${KERNEL_DIR}"
    cd "${KERNEL_DIR}"
    
    # Use --partial-clone for faster download and add retry logic
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        log_info "Attempt $((retry_count + 1)) of ${max_retries}..."
        
        if repo init -u "${KERNEL_MANIFEST}" -b "${KERNEL_BRANCH}" --depth=1 --partial-clone; then
            log_info "Repo initialized successfully"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            log_warn "Repo init failed, retrying in 10 seconds..."
            sleep 10
        fi
    done
    
    log_error "Failed to initialize repo after ${max_retries} attempts"
    exit 1
}

# Sync kernel source
sync_source() {
    log_info "Syncing kernel source (this may take a while)..."
    
    # Use parallel jobs for faster sync, but limit to avoid OOM
    JOBS=$(nproc)
    if [ "$JOBS" -gt 4 ]; then
        JOBS=4
    fi
    
    # Add retry logic for sync
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        log_info "Sync attempt $((retry_count + 1)) of ${max_retries} with ${JOBS} jobs..."
        
        if repo sync -c -j${JOBS} --no-tags --no-clone-bundle --optimized-fetch --fail-fast; then
            log_info "Kernel source synced successfully"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            log_warn "Sync failed, retrying in 30 seconds..."
            sleep 30
        fi
    done
    
    log_error "Failed to sync kernel source after ${max_retries} attempts"
    exit 1
}

# Verify download
verify_download() {
    log_info "Verifying kernel source..."
    
    if [ ! -d "common" ]; then
        log_error "Kernel source directory 'common' not found"
        exit 1
    fi
    
    if [ ! -f "common/Makefile" ]; then
        log_error "Kernel Makefile not found"
        exit 1
    fi
    
    # Print kernel version
    VERSION=$(grep "^VERSION" common/Makefile | head -1 | awk '{print $3}')
    PATCHLEVEL=$(grep "^PATCHLEVEL" common/Makefile | head -1 | awk '{print $3}')
    log_info "Downloaded kernel version: ${VERSION}.${PATCHLEVEL}"
    
    log_info "Kernel source verification passed"
}

# Main function
main() {
    log_info "Starting GKI 6.12-android16 kernel source download"
    log_info "Target directory: ${KERNEL_DIR}"
    
    check_repo
    configure_git
    init_repo
    sync_source
    verify_download
    
    log_info "Download completed successfully!"
    log_info "Kernel source is available at: ${KERNEL_DIR}/common"
}

# Run main function
main "$@"
