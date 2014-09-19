These instructions are valid for the following combination of software
1. Ubuntu-14.04 and kernel 3.13.0.35-generic and allow to Lustre  to be compiled.


IMPORTANT!!!!!
==============================
Compiled Lustre is not tested.
==============================



==============================
Install and prepare MOFED
==============================
1. Create MOFED Module.symvers file

cd /usr/src/ofa_kernel
patch -p1 < create_Modules.symvers.patch
./ofed_scripts/gen-compat-autoconf.sh  include/linux/compat-3.13.h   > include/linux/compat_autoconf.h
export MODULES_DIR=/lib/modules/3.13.0-35-generic/updates/dkms
./ofed_scripts/create_Module.symvers.sh

2. Backup original symbols file
cd /usr/src/linux-headers-3.13.0-35-generic
cp  Module.symvers  Module.symvers.orig

3. Fix existing symbols with the new one from Mellanox OFED by running
chmod 755 lustre_mofed_ksym_fix
./lustre_mofed_ksym_fix.sh

4. Replace existing symbol version file with the generated one
cp /tmp/Module.symvers.new /usr/src/linux-headers-3.13.0-35-generic/Module.symvers


==============================
Lustre time
==============================

Checkout and compile Lustre 

git clone git://git.whamcloud.com/fs/lustre-release.git 
cd lustre-release
...
..
other configure && make steps
Example  of configure line that points to new Mellanox IB headers:
./configure --with-o2ib=/usr/src/ofa_kernel --disable-server --enable-quota

There is probably another Lustre issue with redefintion of CONFIG_LNET_MAX_PAYLOAD variable that might be fixed by editing config.h file and setting to the the same value as in the origial kernel file - 1048576. Check the error message in order to get location of orignal definition.


