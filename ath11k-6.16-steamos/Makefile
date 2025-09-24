# DKMS wrapper Makefile for ath11k backport (SteamOS 6.11)
KERNEL_SRC ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

obj-m += ath11k.o
obj-m += ath11k_pci.o
obj-m += ath11k_ahb.o

# Include ath11k/ subdirectory for trace/testmode relative includes
ccflags-y += -I$(src)/ath11k

ath11k-y := \
	ath11k/core.o \
	ath11k/mac.o \
	ath11k/hal.o \
	ath11k/hal_tx.o \
	ath11k/hal_rx.o \
	ath11k/wmi.o \
	ath11k/reg.o \
	ath11k/htc.o \
	ath11k/qmi.o \
	ath11k/dp.o \
	ath11k/dp_tx.o \
	ath11k/dp_rx.o \
	ath11k/debug.o \
	ath11k/ce.o \
	ath11k/peer.o \
	ath11k/dbring.o \
	ath11k/hw.o \
	ath11k/fw.o \
	ath11k/p2p.o \
	ath11k/debugfs.o \
	ath11k/debugfs_htt_stats.o \
	ath11k/debugfs_sta.o \
	ath11k/trace.o \
	ath11k/thermal.o \
	ath11k/spectral.o \
	ath11k/wow.o \
	ath11k/coredump.o
	# NOTE: testmode.o intentionally omitted for SteamOS 6.11 backport

ath11k_pci-y := \
	ath11k/pci.o \
	ath11k/pcic.o \
	ath11k/mhi.o

ath11k_ahb-y := \
	ath11k/ahb.o

all:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) modules

modules_install:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) modules_install

clean:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) clean

.PHONY: all modules_install clean
