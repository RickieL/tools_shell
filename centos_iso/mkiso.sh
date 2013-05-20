#!/bin/sh

if [ -z $1 ]; then
	exit 1
else
	version=$1
fi

rm -f /tmp/CentOS-5.6-HaoDou-$version.iso

cd /los
declare -x discinfo=`head -1 .discinfo`
createrepo -u "media://$discinfo" -g repodata/comps.xml .

mkisofs -R -J -T -r -l -d -allow-multidot -allow-leading-dots -no-bak -o /tmp/CentOS-5.6-HaoDou-$version.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table .

/usr/lib/anaconda-runtime/implantisomd5 /tmp/CentOS-5.6-HaoDou-$version.iso

