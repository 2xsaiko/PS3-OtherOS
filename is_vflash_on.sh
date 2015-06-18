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

LPAR_ID=1

RNV_SYS=0x0000000073797300
RNV_FLASH=0x666c617368000000
RNV_EXT=0x6578740000000000

flag=`$PS3HVC_HVCALL $PS3HVC_DEV get_repo_node_val $LPAR_ID $RNV_SYS $RNV_FLASH $RNV_EXT 0 |
	awk '{ printf $1 }'`

echo "flag $flag"

if [ "$flag" = "0x00000000000000fe" ]; then
	echo "vflash is on"
else
	echo "vflash is off"
fi
