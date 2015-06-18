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
# ram_write_val_32
#
ram_write_val_32()
{
	_off=$1
	_val=$2
	printf $_val | dd of=$PS3RAM_DEV bs=1 count=4 seek=$(($_off)) 2>/dev/null
}

PS3HVC_DEV=/dev/ps3hvc
PS3HVC_HVCALL=ps3hvc_hvcall

PS3RAM_DEV=/dev/ps3ram

# 3.41 offsets

DISPMGR_SET_LAID_OFFSET_341=0x16F3BC
DISPMGR_SS_ID_OFFSET_341=0x16F3E0
DISPMGR_SEND_SPM_REQ_OFFSET_341=0x16F458

# 3.55 offsets

DISPMGR_SET_LAID_OFFSET_355=0x16F3BC
DISPMGR_SS_ID_OFFSET_355=0x16F3E0
DISPMGR_SEND_SPM_REQ_OFFSET_355=0x16F458

fw_ver=`$PS3HVC_HVCALL $PS3HVC_DEV get_version_info`

case $fw_ver in
	0x0000000300040001)
		DISPMGR_SET_LAID_OFFSET=$DISPMGR_SET_LAID_OFFSET_341
		DISPMGR_SS_ID_OFFSET=$DISPMGR_SS_ID_OFFSET_341
		DISPMGR_SEND_SPM_REQ_OFFSET=$DISPMGR_SEND_SPM_REQ_OFFSET_341
	;;

	0x0000000300050005)
		DISPMGR_SET_LAID_OFFSET=$DISPMGR_SET_LAID_OFFSET_355
		DISPMGR_SS_ID_OFFSET=$DISPMGR_SS_ID_OFFSET_355
		DISPMGR_SEND_SPM_REQ_OFFSET=$DISPMGR_SEND_SPM_REQ_OFFSET_355
	;;

	*)
		echo "not supported firmware version $fw_ver" >&2
		exit 1
	;;
esac

# disable overwriting of LAID

ram_write_val_32 $DISPMGR_SET_LAID_OFFSET '\x60\x00\x00\x00'

# disable SS ID check

ram_write_val_32 $DISPMGR_SS_ID_OFFSET '\x38\x60\x00\x01'

# disable SPM (Security Policy Manager) check

ram_write_val_32 $DISPMGR_SEND_SPM_REQ_OFFSET '\x3B\xE0\x00\x01'
ram_write_val_32 $((DISPMGR_SEND_SPM_REQ_OFFSET + 4)) '\x9B\xE1\x00\x70'
ram_write_val_32 $((DISPMGR_SEND_SPM_REQ_OFFSET + 8)) '\x38\x60\x00\x00'

