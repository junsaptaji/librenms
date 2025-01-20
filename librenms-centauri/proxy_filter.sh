#!/bin/sh
# This is an snmptrapd script to extract hostname from the payload and use it as the source hostname for the trap
# This is useful where an snmp proxy is being used to forward traps and the orignal source device ip is lost during the snmp forward
# It requires the source trap event snmpd process to be configured to add the source hostname to the trap payload. This is done through a monitor statement.
# OID 1.3.6.1.2.1.1.5 (sysName) is added to the trap payload.

if [ $# -ne 1 ]
then
	echo Usage: $0 traphandle_program
	exit 1
fi
if [ ! -x "$1" ]
then
	echo $1: not executable
	exit 1
fi
traphandler=$1
shift

read host
read ip

while read oid val
do
	echo $oid $val >> /tmp/pxy.$$
	if [ "$oid" = "SNMPv2-MIB::sysName.0" ]
	then
		host=$val
	fi
done
(echo $host ; echo "$ip" ;
	while read oid val
	do
		echo $oid "$val"
	done  < /tmp/pxy.$$
) | $traphandler $@
rm -f /tmp/pxy.$$
