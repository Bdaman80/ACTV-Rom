#!/system/bin/sh
export PATH=/system/bin:$PATH

# Install GAN virtual interface kernel module
if [ -e /system/lib/modules/kineto_gan.ko ]; then
	insmod /system/lib/modules/kineto_gan.ko
fi
