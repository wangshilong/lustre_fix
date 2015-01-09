#!/bin/bash

function __fail
{
	echo "$1"
	exit 1
}

function generate_missing_include_file
{

	if [ ! -f "/usr/src/ofa_kernel/ofed_scripts/create_Modules.symvers.patch" ];then
		#we need generate autocomapt.h file
		cp ./create_Modules.symvers.patch /usr/src/ofa_kernel/ofed_scripts || __fail "cp failed"
		pushd /usr/src/ofa_kernel/ofed_scripts || __fail "pushd failed"
		# patch -p1  < ./create_Modules.symvers.patch || __fail "failed to apply patch"
		popd
	fi

	if [ ! -f "/usr/src/ofa_kernel/include/linux/compat_autoconf.h" ];then
		pushd /usr/src/ofa_kernel
		./ofed_scripts/gen-compat-autoconf.sh  include/linux/compat-3.13.h   > include/linux/compat_autoconf.h || __fail "generate header failed"
		export MODULES_DIR=/lib/modules/`uname -r`/updates/dkms
		./ofed_scripts/create_Module.symvers.sh || __fail "Symbol generated failed"
		popd
	fi
	#please use that one whatever
	#cp /var/lib/dkms/mlnx-ofed-kernel/2.3/build/Module.symvers /usr/src/ofa_kernel/Module.symvers || __fail "copy Module.symvers failed"
}

function replace_symbol()
{
	if [ -f "/usr/src/linux-headers-`uname -r`/Module.symvers.orig" ];then
		#echo "Symbol file have been uptodate"
		return 0
	fi
	# this script could only be runned once.
	./lustre_mofed_ksym_fix.sh
	cp /usr/src/linux-headers-`uname -r`/Module.symvers /usr/src/linux-headers-`uname -r`/Module.symvers.orig
	cp /tmp/Module.symvers.new /usr/src/linux-headers-`uname -r`/Module.symvers
}

function cleanup_before()
{
	rm -f /usr/src/ofa_kernel/include/linux/compat_autoconf.h
	cp /usr/src/linux-headers-`uname -r`/Module.symvers.orig /usr/src/linux-headers-`uname -r`/Module.symvers
	rm /usr/src/linux-headers-`uname -r`/Module.symvers.orig -f
}
cleanup_before
generate_missing_include_file
replace_symbol
echo "Success!!!"

