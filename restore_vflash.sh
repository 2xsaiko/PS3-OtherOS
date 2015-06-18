#!/bin/sh
#
# Copyright (C) 2011 glevand (geoffrey.levand@mail.ru)
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

PS3STORMGR_DEV=/dev/ps3stormgr
PS3STOR_REGION=ps3stor_region

VFLASH_DEVID=4
VFLASH_REG7_ID=7
HDD_DEV=/dev/ps3da
HDD_VFLASH_SIZE_OFFSET=56

echo "unmounting all VFLASH regions ..."

for i in 1 2 3 4 5 6 7 8 9 10; do
	umount /dev/ps3vflashh$i 2>/dev/null
done

echo "removing VFLASH region 7 ..."

if ! $PS3STOR_REGION $PS3STORMGR_DEV delete $VFLASH_DEVID $VFLASH_REG7_ID; then
	echo "couldn't remove VFLASH region 7"
	exit 1
fi

echo "VFLASH region 7 was removed"

echo "patching size of VFLASH ..."

printf "\x00\x00\x00\x00\x00\x08\x00\x00" | dd of=$HDD_DEV seek=$HDD_VFLASH_SIZE_OFFSET bs=1 count=8

