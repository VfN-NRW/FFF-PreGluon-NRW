#!/bin/bash
# This script is designed to reboot wlan if no gateway is available.
# If the gateway is not available at 5:00am the router will be restarted.
# If the wan-interface is up and internet (8.8.8.8) is reachable the script,
#   will exit without the capability to test wifi.

# Start this script every 10 minutes via cron and it will restart wifi every
# 10 minutes, diff 5 minutes from start, if the gateways are not available.

# Ruben Kelevra cyrond@gmail.com 2013-06
# AGPL v3

shopt -s nullglob

ping -q 8.8.8.8 -c 4 -W 5 >/dev/null 2>&1

GATEWAYS=" \
fda0:747e:ab29:2196::c01 \
fda0:747e:ab29:2196::c02 \
"
 
if test $? -eq 0; then
	result=0

	for GATEWAY in $GATEWAYS
	do
		ping -q $GATEWAY -c 4 -W 5 >/dev/null 2>&1
		if test $? -eq 0; then
			logger "Gateway $GATEWAY not reachable"
		else
			result=1
		fi
	done
	
	if test $result -eq 0; then #no gateway available
		sleep 300 #wait 5 minutes
		result=0

		for GATEWAY in $GATEWAYS
		do
			ping -q $GATEWAY -c 4 -W 5 >/dev/null 2>&1
			if test $? -eq 0; then
				logger "Gateway $GATEWAY not reachable"
			else
				result=1
			fi
		done
		if test $result -eq 0; then
			TIME=`date | awk '{ print $4 }' | sed 's/:/ /g'`
			MINUTE=`echo $TIME | awk '{ print $2 }'`
			HOUR=`echo $TIME | awk '{ print $1 }'`
			if test $HOUR -eq 5; then
				if test $MINUTE -lt 14; then
					logger "reboot now"
					sleep 5
					reboot
					exit 0
				fi
			fi
			logger "restart wifi"
			sleep 5
			wifi
			exit 0
		fi
	fi
	
	logger "gateway(s) available."
	exit 0
	
else #wan is up; internet is reachable
	exit 0
fi