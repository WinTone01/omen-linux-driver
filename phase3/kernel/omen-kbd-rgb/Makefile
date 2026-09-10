KDIR ?= /lib/modules/$(shell uname -r)/build

# Cekirdek clang ile derlenmisse (CachyOS) modul de clang ile derlenmeli;
# yoksa kbuild clang'a ozgu bayraklari gcc'ye gecirip patliyor.
# Ayni tespit phase2/scripts/build-module.sh'ta da var.
LLVM_FLAG := $(shell grep -q '^CONFIG_CC_IS_CLANG=y' $(KDIR)/.config 2>/dev/null && echo LLVM=1)

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) $(LLVM_FLAG) modules

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) $(LLVM_FLAG) clean

.PHONY: all clean
