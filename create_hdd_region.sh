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

PS3HVC_DEV=/dev/ps3hvc
PS3HVC_HVCALL=ps3hvc_hvcall

PS3STORMGR_DEV=/dev/ps3stormgr
PS3STOR_REGION=ps3stor_region

LPAR_ID=1
LAID=0x1070000002000001

RNV_BUS4=0x0000000062757304
RNV_NUM_DEV=0x6e756d5f64657600
RNV_DEV=0x6465760000000000
RNV_ID=0x6964000000000000
RNV_TYPE=0x7479706500000000
RNV_DEV_TYPE_DISK=0x0000000000000000
RNV_N_BLOCKS=0x6e5f626c6f636b73
RNV_N_REGS=0x6e5f726567730000
RNV_REGION=0x726567696f6e0000
RNV_START=0x7374617274000000
RNV_SIZE=0x73697a6500000000

# get number of storage devices

num_dev=`$PS3HVC_HVCALL $PS3HVC_DEV get_repo_node_val $LPAR_ID $RNV_BUS4 $RNV_NUM_DEV 0 0 |
	awk '{ printf $1 }'`
num_dev=`printf "%d" $num_dev`

echo "number of storage devices $num_dev"

# get index of disk storage device

echo "searching for disk storage device ..."

dev_idx=0
found=0
while [ $dev_idx -lt $num_dev -a $found -eq 0 ]; do
	rnv_dev="`expr substr $RNV_DEV 1 17`${dev_idx}"

	type=`$PS3HVC_HVCALL $PS3HVC_DEV get_repo_node_val $LPAR_ID $RNV_BUS4 $rnv_dev $RNV_TYPE 0 |
		awk '{ printf $1 }'`
	if [ "$type" = "$RNV_DEV_TYPE_DISK" ]; then
		found=1
	else
		dev_idx=`expr $dev_idx + 1`
	fi
done

if [ $found -eq 0 ]; then
	echo "disk storage device was not found"
	exit 1
fi

echo "found disk storage device"
echo "device index $dev_idx"

# get id of disk storage device

dev_id=`$PS3HVC_HVCALL $PS3HVC_DEV get_repo_node_val $LPAR_ID $RNV_BUS4 $rnv_dev $RNV_ID 0 |
	awk '{ printf $1 }'`

echo "device id $dev_id"

# get number of regions on disk storage device

n_regs=`$PS3HVC_HVCALL $PS3HVC_DEV get_repo_node_val $LPAR_ID $RNV_BUS4 $rnv_dev $RNV_N_REGS 0 |
	awk '{ printf $1 }'`
n_regs=`printf "%d" $n_regs`

echo "number of regions $n_regs"

# get total size of disk storage device

n_blocks=`$PS3HVC_HVCALL $PS3HVC_DEV get_repo_node_val $LPAR_ID $RNV_BUS4 $rnv_dev $RNV_N_BLOCKS 0 |
	awk '{ printf $1 }'`
n_blocks=`printf "%d" $n_blocks`

echo "total number of blocks $n_blocks"

# calculate start sector and sector count for new region on disk storage device

last_reg_idx=`expr $n_regs - 1`
rnv_reg="`expr substr $RNV_REGION 1 17`${last_reg_idx}"

last_reg_start_sector=`$PS3HVC_HVCALL $PS3HVC_DEV get_repo_node_val $LPAR_ID $RNV_BUS4 $rnv_dev \
	$rnv_reg $RNV_START | awk '{ printf $1 }'`
last_reg_start_sector=`printf "%d" $last_reg_start_sector`

echo "last region start sector $last_reg_start_sector"

last_reg_sector_count=`$PS3HVC_HVCALL $PS3HVC_DEV get_repo_node_val $LPAR_ID $RNV_BUS4 $rnv_dev \
	$rnv_reg $RNV_SIZE | awk '{ printf $1 }'`
last_reg_sector_count=`printf "%d" $last_reg_sector_count`

echo "last region sector count $last_reg_sector_count"

new_reg_start_sector=`expr $last_reg_start_sector + $last_reg_sector_count + 8`
free_sector_count=`expr $n_blocks - $new_reg_start_sector`
new_reg_sector_count=`expr $free_sector_count - 8`

echo "number of free sectors $free_sector_count"

# create new region on disk storage device

echo "creating new storage region ($new_reg_start_sector, $new_reg_sector_count) ..."

new_reg_id=`$PS3STOR_REGION $PS3STORMGR_DEV create $dev_id $new_reg_start_sector $new_reg_sector_count $LAID`

echo "new storage region id $new_reg_id"
