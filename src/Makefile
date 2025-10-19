KDIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

obj-m += ath11k.o
obj-m += ath11k_ahb.o
obj-m += ath11k_pci.o

ath11k-y += core.o dp.o dp_tx.o dp_rx.o mac.o mhi.o ce.o \
            hal.o hal_tx.o hal_rx.o wmi.o reg.o htc.o qmi.o \
            dbring.o hw.o peer.o wow.o

ath11k_ahb-y += ahb.o
ath11k_pci-y += pci.o pcic.o

all:
	$(MAKE) KBUILD_MODPOST_WARN=1 -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
