#!/bin/bash
# run WUDS
#  -- uses first wireless interface if IFACE isn't set in config

if [ "$EUID" -ne 0 ]
  then echo "Please run as root."
  exit
fi

IFACE=`grep IFACE config.py | cut -d'=' -f 2 | sed "s/['\" ]//g"`

if [ "$IFACE" == "" ]; then
	IFACE=`iwconfig 2>&1 | grep IEEE | cut -d" " -f 1`;
fi

if ( ifconfig "$IFACE" down ) ; then
	echo "$IFACE downed."
fi

#iw dev $IFACE interface add $IFACE type monitor

if ( iwconfig "$IFACE" mode mon ) ; then
	echo "$IFACE entered Monitor-Mode"
	if ( ifconfig "$IFACE" up ) ; then
		echo "$IFACE upped  ; running core.py ; Ctrl-C once to stop."
		python ./core.py
	fi
fi
if ( ifconfig "$IFACE" down ) ; then
	echo "$IFACE downed."
fi

#iw dev $IFACE del
