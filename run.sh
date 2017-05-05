#!/bin/bash
# run WUDS
#  -- uses first wireless interface if IFACE isn't set in config

if [ "$EUID" -ne 0 ]
  then echo "Please run as root."
  exit 1
fi


if [ ! -f config.py ]; then
    echo 'Copying config.py.sample to config.py'
    #copy with user, not root
    sudo -u "$SUDO_USER" cp "config.py.sample" "config.py"
fi

IFACE=$(grep IFACE config.py | cut -d'=' -f 2 | sed "s/['\" ]//g")

if [ "$IFACE" == "" ]; then
	IFACE=$(iwconfig 2>&1 | grep IEEE | cut -d" " -f 1)
fi

if ( ifconfig "$IFACE" down >/dev/null 2>&1 ) ; then
	echo "$IFACE downed."
fi

if ( iwconfig "$IFACE" mode mon) ; then
	echo "$IFACE entered Monitor-Mode"
	if ( ifconfig "$IFACE" up >/dev/null 2>&1) ; then
		echo "$IFACE upped  ; running core.py ; Ctrl-C once to stop."
		python ./core.py
	else
		echo "Could not up $IFACE"
	fi
fi
if ( ifconfig "$IFACE" down >/dev/null 2>&1 ) ; then
	echo "$IFACE downed."
fi
