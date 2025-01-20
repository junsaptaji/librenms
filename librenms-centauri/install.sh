#!/bin/sh

# this script is intended to be run on the librenms server to install the required Centauri files
# the librenms application is not required to be running, the script will copy the files in place. 
# the librenms application is not required to be restarted if it is already running. 
# Any Centauri devices discovered or re-discovered after the install will pickup the new configuration
#

# default librenms install directory
LIBRE_INSTALL_DIR=/opt/librenms

Usage ()
{
	echo usage: $0 [-i librenms_install_dir ]
	echo default install directory is $LIBRE_INSTALL_DIR
	exit 1
}


# check that the libernms install directory looks ok enough to copy files to
checkDirs() {
installDir="$1"
dirList="$installDir/html/images/logos $installDir/html/images/os $installDir/includes/definitions $installDir/includes/definitions/discovery $installDir/mibs"
for dir in $dirList
do
	if [ -d $dir -a -w $dir ]
	then
		continue
	else
		echo $dir is not a writeable directory
		echo check the LibreNMS install directory is correct
		exit 1
	fi
done
}

# check argument usage is correct
if [ $# -ne 0 -a $# -ne 2 ]
then
	Usage
fi

if [ $# -eq 2 ]
then
	if [ "$1" != "-i" ]
	then
		Usage
	elif [ -d "$2" ]
	then
		LIBRE_INSTALL_DIR="$2"
	else
		echo "$2" is not a directory
		Usage
	fi
fi
checkDirs $LIBRE_INSTALL_DIR

cp -fv transcelestial.svg ${LIBRE_INSTALL_DIR}/html/images/logos/centauri.svg
chown nobody ${LIBRE_INSTALL_DIR}/html/images/logos/centauri.svg
chgrp nobody ${LIBRE_INSTALL_DIR}/html/images/logos/centauri.svg

cp -fv centauri.svg ${LIBRE_INSTALL_DIR}/html/images/os/centauri.svg
chown nobody ${LIBRE_INSTALL_DIR}/html/images/os/centauri.svg
chgrp nobody ${LIBRE_INSTALL_DIR}/html/images/os/centauri.svg

cp -fv centauri-os.yaml ${LIBRE_INSTALL_DIR}/includes/definitions/centauri.yaml
chown nobody ${LIBRE_INSTALL_DIR}/includes/definitions/centauri.yaml
chgrp nobody ${LIBRE_INSTALL_DIR}/includes/definitions/centauri.yaml

# set up the centauri MIB file
mkdir -pv ${LIBRE_INSTALL_DIR}/mibs/transcelestial
cp -fv TCT-SNMP-MIB.txt ${LIBRE_INSTALL_DIR}/mibs/transcelestial
chown nobody ${LIBRE_INSTALL_DIR}/mibs/transcelestial ${LIBRE_INSTALL_DIR}/mibs/transcelestial/TCT-SNMP-MIB.txt
chgrp nobody ${LIBRE_INSTALL_DIR}/mibs/transcelestial ${LIBRE_INSTALL_DIR}/mibs/transcelestial/TCT-SNMP-MIB.txt

# setup sensor file for reading txpower and rxpower sensors
cp -fv centauri-sensor.yaml ${LIBRE_INSTALL_DIR}/includes/definitions/discovery/centauri.yaml
chown nobody ${LIBRE_INSTALL_DIR}/includes/definitions/discovery/centauri.yaml
chgrp nobody ${LIBRE_INSTALL_DIR}/includes/definitions/discovery/centauri.yaml

# setup the proxy filter used by snmptrapd
cp -fv proxy_filter.sh ${LIBRE_INSTALL_DIR}/scripts/proxy_filter.sh
chown nobody ${LIBRE_INSTALL_DIR}/scripts/proxy_filter.sh
chgrp nobody ${LIBRE_INSTALL_DIR}/scripts/proxy_filter.sh

# install a custom trap handler for TCT events
cp -fv TctLinkDown.php ${LIBRE_INSTALL_DIR}/LibreNMS/Snmptrap/Handlers/TctLinkDown.php
chown nobody ${LIBRE_INSTALL_DIR}/LibreNMS/Snmptrap/Handlers/TctLinkDown.php
chgrp nobody ${LIBRE_INSTALL_DIR}/LibreNMS/Snmptrap/Handlers/TctLinkDown.php

cp -fv TctTrigger.php ${LIBRE_INSTALL_DIR}/LibreNMS/Snmptrap/Handlers/TctTrigger.php
chown nobody ${LIBRE_INSTALL_DIR}/LibreNMS/Snmptrap/Handlers/TctTrigger.php
chgrp nobody ${LIBRE_INSTALL_DIR}/LibreNMS/Snmptrap/Handlers/TctTrigger.php

TRAPS_PHP="${LIBRE_INSTALL_DIR}/config/snmptraps.php"
fgrep 'TCT-SNMP-MIB::' $TRAPS_PHP > /dev/null
if [ $? -ne 0 ]
then
	cp $TRAPS_PHP ${LIBRE_INSTALL_DIR}/config/snmptraps.php.bak
	cp $TRAPS_PHP /tmp/snmptraps.php.$$
	sed -i -e "/'trap_handlers'.*\[/a \\\t'TCT-SNMP-MIB::tctLaserLinkDown' => \\\LibreNMS\\\Snmptrap\\\Handlers\\\TctLinkDown::class,\n        'TCT-SNMP-MIB::tctTrigger' => \\\LibreNMS\\\Snmptrap\\\Handlers\\\TctTrigger::class," $TRAPS_PHP 

	if [ $? -ne 0 ]
	then
		echo Error updating $TRAPS_PHP
		exit 1
	fi
fi
exit 0
