KDIR ?= /lib/modules/$(shell uname -r)/build

# If the kernel was built with clang (CachyOS does), the module must be too;
# otherwise kbuild passes clang-only flags to gcc and the build dies on the
# first file. The same detection lives in kernel/hp-wmi-8d24/build-module.sh.
LLVM_FLAG := $(shell grep -q '^CONFIG_CC_IS_CLANG=y' $(KDIR)/.config 2>/dev/null && echo LLVM=1)

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) $(LLVM_FLAG) modules

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) $(LLVM_FLAG) clean

# For distributions without makepkg. Copies the source where DKMS expects it
# and lets DKMS rebuild the module on every kernel update, which is the whole
# point of shipping it this way.
# The one version number, kept in dkms.conf.
VERSION := $(shell sed -n 's/^PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)
DKMS_SRC := /usr/src/omen-kbd-rgb-$(VERSION)

# Any version already registered goes first: left in place, DKMS would
# rebuild it next to this one on every kernel update, and which of the two
# gets loaded would be down to directory order.
dkms-install:
	-dkms remove -m omen-kbd-rgb --all 2>/dev/null
	find /usr/src -maxdepth 1 -name 'omen-kbd-rgb-*' ! -name 'omen-kbd-rgb-$(VERSION)' -exec rm -rf {} +
	install -Dm644 omen-kbd-rgb.c $(DKMS_SRC)/omen-kbd-rgb.c
	install -Dm644 Kbuild         $(DKMS_SRC)/Kbuild
	install -Dm644 Makefile       $(DKMS_SRC)/Makefile
	install -Dm644 dkms.conf      $(DKMS_SRC)/dkms.conf
	install -Dm644 omen-kbd-rgb-modules.conf \
		/usr/lib/modules-load.d/omen-kbd-rgb.conf
	dkms add     -m omen-kbd-rgb -v $(VERSION) || true
	dkms install -m omen-kbd-rgb -v $(VERSION) --force
	modprobe -r omen-kbd-rgb 2>/dev/null || true
	modprobe omen-kbd-rgb

dkms-remove:
	dkms remove -m omen-kbd-rgb --all || true
	rm -rf /usr/src/omen-kbd-rgb-* /usr/lib/modules-load.d/omen-kbd-rgb.conf

.PHONY: all clean dkms-install dkms-remove
