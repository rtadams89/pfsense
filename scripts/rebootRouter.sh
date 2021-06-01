#!/bin/bash

# rebootRouter
# Version 1.0
#
# Copyright (c) 2021 Ryan Adams
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Set the three variables as appropriate below
# Run this script from a system with network access to the pfSense web interface

PFSENSE_URL="https://<IP Address>"
PFSENSE_USERNAME="admin"
PFSENSE_PASSWORD="<password>"

if [ -f cookies.txt ]; then
		rm cookies.txt
fi

if [ -f csrf.txt ]; then
		rm csrf.txt
fi

echo "Getting CRSF tokens..."
wget -qO- --keep-session-cookies --save-cookies cookies.txt --no-check-certificate ${PFSENSE_URL}/diag_backup.php | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > csrf.txt

echo "Logging in..."
wget -qO- --keep-session-cookies --load-cookies cookies.txt --no-check-certificate --save-cookies cookies.txt --post-data "login=Login&usernamefld=${PFSENSE_USERNAME}&passwordfld=${PFSENSE_PASSWORD}&__csrf_magic=$(cat csrf.txt)" ${PFSENSE_URL}/diag_reboot.php | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > csrf2.txt

echo "Rebooting..."
wget --quiet --keep-session-cookies --load-cookies cookies.txt --no-check-certificate --post-data "rebootmode=Reboot&Submit=Submit&__csrf_magic=$(head -n 1 csrf2.txt)" ${PFSENSE_URL}/diag_reboot.php

echo "Deleting files..."
rm csrf*.txt
rm cookies.txt
