if [ -z "$1" ]; then
    echo usage:  $0 dom-XXXX.gz
    exit 0;
fi

if [ ! -e $1 ]; then
    echo "ERROR:  dom image file $1 doesn't exist"
    exit 1
fi

tar xf $1
rm $1
cd DOM
mount -o remount,rw /DOM
for f in initrd-* vmlinuz-2.6.18.6-2g2g grub/grub.conf ; do mv $f /DOM/$f.new; done
pushd /DOM
for f in *.new; do mv $f `basename $f .new` ; done
rm vmlinuz-2.6.18.* System.map-2.6.18.*
cd grub
for f in *.new; do mv $f `basename $f .new` ; done
if [ ` awk '/MemTotal/{print $2}' /proc/meminfo` -gt 1000000 ]; then 
    if [ -s grub.conf.2G ]; then
        cp grub.conf.2G grub.conf
    fi
fi
popd
mv defaults.tgz /DOM/
