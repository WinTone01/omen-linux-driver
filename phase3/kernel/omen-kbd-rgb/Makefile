KDIR ?= /lib/modules/$(shell uname -r)/build

# If the kernel was built with clang (CachyOS does), the module must be too;
# otherwise kbuild passes clang-only flags to gcc and the build dies on the
# first file. The same detection lives in phase2/scripts/build-module.sh.
LLVM_FLAG := $(shell grep -q '^CONFIG_CC_IS_CLANG=y' $(KDIR)/.config 2>/dev/null && echo LLVM=1)

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) $(LLVM_FLAG) modules

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) $(LLVM_FLAG) clean

.PHONY: all clean
