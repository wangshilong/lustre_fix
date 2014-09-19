#!/bin/bash

MLNXSYMFILE=${MLNXSYMFILE:-/usr/src/ofa_kernel/Module.symvers}
KSYMFILE=${KSYMFILE:-/usr/src/linux-headers-3.13.0-35-generic/Module.symvers}

#Original kernel file should be replaced with this one
TARGET=/tmp/Module.symvers.new
TMPFILE=`mktemp /tmp/Module.symvers.XXXXXX`
DIFFFILE=$HOME/tmp/Module.symvers.add

CLEANFILE=`mktemp /tmp/ba.XXXXXX`

trap 'rm -f ${TMPFILE} ${DIFFFILE} ${CLEANFILE}' INT QUIT EXIT TERM

cat $KSYMFILE > $TMPFILE

cat $MLNXSYMFILE | while read line;do
	set -- $line
	func=$(echo $2 | sed -e 's/__crc_//')
	mlnxaddr=$1
	path=$3

	#Check if symbol exists in the orignal file
	grep "\s${func}\s" $TMPFILE >/dev/null 2>&1
	if [ $? -ne 0 ];then
		echo "Symbol $func not found in $KSYMFILE"
		continue
	fi
	echo "Deleting $func from $TMPFILE"
	grep -v "\s$func\s" $TMPFILE > ${CLEANFILE}
	mv ${CLEANFILE} ${TMPFILE}
done


rm -f ${DIFFFILE}
cat $MLNXSYMFILE |  while read line;do
	set -- $line
	func=$(echo $2 | sed -e 's/__crc_//')
	mlnxaddr=$1
	path=$3
	printf "%s\t%s\t%s\n" ${mlnxaddr} ${func} ${path} >> ${DIFFFILE}
done
cat ${TMPFILE} ${DIFFFILE} > ${TARGET}

echo "New ${TARGET} is ready"

