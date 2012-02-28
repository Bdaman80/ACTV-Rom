#!/system/bin/sh

# If this is a user build, only run if the APK is installed.
case $(getprop ro.build.type) in
"user")
    apkInstalled=0
    for package in $(/system/bin/pm list packages com.motorola.bug2go)
    do
        case "$package" in
        package:com.motorola.bug2go)
            apkInstalled=1
            break;
            ;;
        esac
    done
    case $apkInstalled in
    0)
        echo "Abort due to Bug2Go.apk not installed on user build";
        exit 1;
        ;;
    esac
    ;;
esac

# Start Bug2Go App
/system/bin/am start -a motorola.intent.action.BUG2GO.START -t "text/plain"

# The vibrator path varies per the hardware
if [ -w /sys/class/timed_output/vibrator/enable ]; then
    # OMAP
    vibratorPath="/sys/class/timed_output/vibrator/enable"
elif [ -w /sys/class/vibrator/vibrator/enable ]; then
    # MSM 7k
    vibratorPath="/sys/class/vibrator/vibrator/enable"
else
    echo "Vibrator path not found!"
    vibratorPath="/dev/null"
fi

# Mimic the start vibrations of dumpstate
# Disable this until we can get dumpstate to recognize the missing -v option
# again.  We're getting double vibrations  because we can't disable the
# vibrations in dumpstate.
#echo 150 > $vibratorPath

# Get environment & status info
timestamp=`date +'%Y-%m-%d_%H-%M-%S'`
product=`/system/bin/getprop ro.build.product`
device=`/system/bin/getprop ro.product.device`
buildType=`/system/bin/getprop ro.build.type`
serialNum=`/system/bin/getprop ro.serialno`
apVersion=`/system/bin/getprop ro.build.version.full`
apDescrip=`/system/bin/getprop ro.build.description`
bpVersion=`/system/bin/getprop gsm.version.baseband`

if [ -w /sdcard ]; then
    storagePath="/sdcard/bug2go"
else
    echo "Nowhere to store output!"
    /system/bin/am start -a motorola.intent.action.BUG2GO.ERR -t "text/plain"
    exit 1
fi

# Create the storage directory
if [ ! -e $storagePath ]; then
    mkdir $storagePath
fi

# Capture the dumpstate (AP state snapshot + log buffers)
/system/bin/dumpstate -o $storagePath/bugreport_$timestamp



# Create a package
/system/bin/gzip $storagePath/bugreport_$timestamp.txt

# Mimic the end vibrations of dumpstate (as best we can)
# Disable this until we can get dumpstate to recognize the missing -v option
# again.  We're getting double vibrations  because we can't disable the
# vibrations in dumpstate.
#echo 75 > $vibratorPath; sleep 1; echo 75 > $vibratorPath; sleep 1; echo 75 > $vibratorPath

# Forward info to the Bug2Go app

/system/bin/am start -a motorola.intent.action.BUG2GO.END -t "application/gzip" \
    -e "path" "$storagePath/bugreport_$timestamp.txt.gz" \
    -e "serial" "$serialNum" \
    -e "timestamp" "$timestamp" \
    -e "ap_version" "$apVersion" \
    -e "bp_version" "$bpVersion" \
    -e "timestamp" "$timestamp" \
    -e "product" "$product" \
    -e "device" "$device" \
    -e "build_type" "$buildType"