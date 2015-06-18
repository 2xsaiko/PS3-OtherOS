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

#
# Don't ask me how i know all this magic stuff and offsets. I just do.
#

#
# ram_read_val_8
#
ram_read_val_8()
{
	_off=$1
	_val=0x`dd if=$PS3RAM_DEV bs=1 count=1 skip=$(($_off)) 2>/dev/null | hexdump -v -e '1/1 "%02x"'`
	printf "0x%02x" $_val
}

#
# ram_read_val_64
#
ram_read_val_64()
{
	_off=$1
	_val=0x`dd if=$PS3RAM_DEV bs=1 count=8 skip=$(($_off)) 2>/dev/null | hexdump -v -e '1/1 "%02x"'`
	printf "0x%016x" $_val
}

#
# ram_write_val_64
#
ram_write_val_64()
{
	_off=$1
	_val=$2
	printf $_val | dd of=$PS3RAM_DEV bs=1 count=8 seek=$(($_off)) 2>/dev/null
}

#
# hdd_reg_is_valid
#
hdd_reg_is_valid()
{
	_hdd_obj_off=$1
	_reg_idx=$2
	_val=`ram_read_val_8 $((_hdd_obj_off + HDD_OBJ_FIRST_REG_OBJ_OFFSET + \
		_reg_idx * REG_OBJ_SIZE + 0x50))`
	echo $_val
}

#
# hdd_reg_acl_get_laid
#
hdd_reg_acl_get_laid()
{
	_hdd_obj_off=$1
	_reg_idx=$2
	_acl_idx=$3
	_val=`ram_read_val_64 $((_hdd_obj_off + HDD_OBJ_FIRST_REG_OBJ_OFFSET + \
		_reg_idx * REG_OBJ_SIZE + REG_OBJ_ACL_TABLE_OFFSET + _acl_idx * ACL_ENTRY_SIZE))`
	echo $_val
}

#
# hdd_reg_acl_get_access_rights
#
hdd_reg_acl_get_access_rights()
{
	_hdd_obj_off=$1
	_reg_idx=$2
	_acl_idx=$3
	_val=`ram_read_val_64 $((_hdd_obj_off + HDD_OBJ_FIRST_REG_OBJ_OFFSET + \
		_reg_idx * REG_OBJ_SIZE + REG_OBJ_ACL_TABLE_OFFSET + _acl_idx * ACL_ENTRY_SIZE + 8))`
	echo $_val
}

#
# hdd_reg_acl_set_access_rights
#
hdd_reg_acl_set_access_rights()
{
	_hdd_obj_off=$1
	_reg_idx=$2
	_acl_idx=$3
	_val=$4
	ram_write_val_64 $((_hdd_obj_off + HDD_OBJ_FIRST_REG_OBJ_OFFSET + \
		_reg_idx * REG_OBJ_SIZE + REG_OBJ_ACL_TABLE_OFFSET + _acl_idx * ACL_ENTRY_SIZE + 8)) $_val
}

if [ $# -ne 1 ]; then
	echo "usage: $0 <print|patch|restore>" >&2
	exit 1
fi

case $1 in
	print|patch|restore)
	;;

	*)
		echo "usage: $0 <print|patch|restore>" >&2
		exit 1
	;;
esac

CMD=$1

PS3HVC_DEV=/dev/ps3hvc
PS3HVC_HVCALL=ps3hvc_hvcall

PS3RAM_DEV=/dev/ps3ram

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
RNV_SYS=0x0000000073797300
RNV_FLASH=0x666c617368000000
RNV_EXT=0x6578740000000000

STORAGE_SYS_OFFSET_341=0x348300
STORAGE_SYS_OFFSET_350=0x348350
STORAGE_SYS_OFFSET_355=0x34b3b8

fw_ver=`$PS3HVC_HVCALL $PS3HVC_DEV get_version_info`

case $fw_ver in
	0x0000000300040001)
		STORAGE_SYS_OFFSET=$STORAGE_SYS_OFFSET_341
	;;

	0x0000000300050000)
		STORAGE_SYS_OFFSET=$STORAGE_SYS_OFFSET_350
	;;

	0x0000000300050005)
		STORAGE_SYS_OFFSET=$STORAGE_SYS_OFFSET_355
	;;

	*)
		echo "not supported firmware version $fw_ver" >&2
		exit 1
	;;
esac

STORAGE_SYS_DEV_TABLE_OFFSET=0xee8
HDD_OBJ_FIRST_REG_OBJ_OFFSET=0xb0
REG_OBJ_ACL_TABLE_OFFSET=0x58
NUM_ACL_ENTRIES=8
ACL_ENTRY_SIZE=24
ACL_TABLE_SIZE=$((NUM_ACL_ENTRIES * ACL_ENTRY_SIZE))
REG_OBJ_SIZE=$((REG_OBJ_ACL_TABLE_OFFSET + ACL_TABLE_SIZE))

# check for VFLASH

flag=`$PS3HVC_HVCALL $PS3HVC_DEV get_repo_node_val $LPAR_ID $RNV_SYS $RNV_FLASH $RNV_EXT 0 |
	awk '{ printf $1 }'`

if [ "$flag" = "0x00000000000000fe" ]; then
	# vflash on
	HDD_REG_LIST="2 3"
else
	# vflash off
	HDD_REG_LIST="1 2"
fi

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

# get RAM address of disk storage device object

val=`ram_read_val_64 $STORAGE_SYS_OFFSET`
val=`ram_read_val_64 $val`
hdd_obj_offset=`ram_read_val_64 $((val + $STORAGE_SYS_DEV_TABLE_OFFSET + 8 * dev_id))`

printf "disk storage device object is at address 0x%x\n" $hdd_obj_offset

# print/patch/restore region ACL entries of disk storage device

for reg_idx in $HDD_REG_LIST; do
	valid=`hdd_reg_is_valid $hdd_obj_offset $reg_idx`
	if [ "$valid" = "0x01" ]; then
		echo "region $reg_idx"

		for acl_idx in 0 1 2 3 4 5 6 7; do
			laid=`hdd_reg_acl_get_laid $hdd_obj_offset $reg_idx $acl_idx`
			access_rights=`hdd_reg_acl_get_access_rights $hdd_obj_offset $reg_idx $acl_idx`

			if [ "$laid" = "$LAID" ]; then
				echo "found GameOS ACL entry index $acl_idx"

				if [ "$CMD" = "print" ]; then
					echo "$laid $access_rights"
				elif [ "$CMD" = "patch" ]; then
					echo "patching ..."
					hdd_reg_acl_set_access_rights $hdd_obj_offset $reg_idx $acl_idx '\x00\x00\x00\x00\x00\x00\x00\x02'
				else
					echo "restoring ..."
					hdd_reg_acl_set_access_rights $hdd_obj_offset $reg_idx $acl_idx '\x00\x00\x00\x00\x00\x00\x00\x03'
				fi
			fi
		done
	fi
done
