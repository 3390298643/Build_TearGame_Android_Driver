# Makefile for Hello World Kernel Module
# Supports out-of-tree compilation for GKI 6.12

# Module name
obj-m += hello.o

# Kernel source directory (set by build script or environment)
KERNEL_SRC ?= /lib/modules/$(shell uname -r)/build

# Cross-compilation settings (for aarch64)
ARCH ?= arm64
CROSS_COMPILE ?= aarch64-linux-gnu-

# Clang/LLVM settings
CC ?= clang
LD ?= ld.lld
AR ?= llvm-ar
NM ?= llvm-nm
OBJCOPY ?= llvm-objcopy
OBJDUMP ?= llvm-objdump
STRIP ?= llvm-strip

# Build flags
EXTRA_CFLAGS += -Wall -Werror

# Default target
all:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) \
		ARCH=$(ARCH) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		CC=$(CC) \
		LD=$(LD) \
		AR=$(AR) \
		NM=$(NM) \
		OBJCOPY=$(OBJCOPY) \
		OBJDUMP=$(OBJDUMP) \
		STRIP=$(STRIP) \
		LLVM=1 \
		modules

# Clean target
clean:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) clean
	rm -f *.o *.ko *.mod.c *.mod.o *.order *.symvers

# Install target (for local testing)
install:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) modules_install

.PHONY: all clean install
