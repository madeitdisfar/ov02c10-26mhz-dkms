# Out-of-tree build of the patched ov02c10 module (used by DKMS, which
# passes KERNELRELEASE and KDIR). The module itself is listed in Kbuild.
KERNELRELEASE ?= $(shell uname -r)
KDIR ?= /lib/modules/$(KERNELRELEASE)/build
# Modules must be built with the kernel's compiler: CachyOS kernels use
# Clang/LLD (ThinLTO), so pass LLVM=1 when the kernel was built that way.
LLVM ?= $(if $(shell grep -s '^CONFIG_CC_IS_CLANG=y' $(KDIR)/.config),1)
export LLVM

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) clean
