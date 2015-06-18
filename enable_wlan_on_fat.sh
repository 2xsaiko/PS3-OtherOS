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
# First, you have to compile your PS3 gelic driver as module.
# Before running this script, unload the driver on Linux,
# run the script and then load the PS3 gelic driver again.
# After that you should be able to use WLAN network device
# on Linux but only on FAT models.
#

PS3HVC_DEV=/dev/ps3hvc
PS3HVC_HVCALL=ps3hvc_hvcall

LPAR_ID=1

RNV_IOS=0x00000000696f7300
RNV_NET=0x6e65740000000000
RNV_EURUS=0x6575727573000000
RNV_LPAR=0x6c70617200000000

echo "old value of repository node 'ios.net.eurus.lpar'"

$PS3HVC_HVCALL $PS3HVC_DEV get_repo_node_val $LPAR_ID $RNV_IOS $RNV_NET $RNV_EURUS $RNV_LPAR

# disable gelic control interface

$PS3HVC_HVCALL $PS3HVC_DEV modify_repo_node_val $LPAR_ID $RNV_IOS $RNV_NET $RNV_EURUS $RNV_LPAR 0 0

echo "new value of repository node 'ios.net.eurus.lpar'"

$PS3HVC_HVCALL $PS3HVC_DEV get_repo_node_val $LPAR_ID $RNV_IOS $RNV_NET $RNV_EURUS $RNV_LPAR
