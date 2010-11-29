#!/bin/bash
#
# Adapted from http://hints.macworld.com/article.php?story=20100927161027611

# Change to your growlnotify path
GROWL="/usr/bin/growlnotify"

# Adjust to the interface name of your airport card (en1 is correct on
# many Mac laptops)
AIRPORT="en1"

# Set to 'yes' if you want to toggle Bluetooth as well. Requires blueutil.
BLUETOOTH="no"

# Path to blueutil
BLUEUTIL="/usr/local/bin/blueutil"

set_airport() {

	new_status=$1

	if [ $new_status = "On" ]; then
		/usr/sbin/networksetup -setairportpower $AIRPORT on
		if [ "$BLUETOOTH" = "yes" ]; then
			$BLUEUTIL off
		fi
		touch /var/tmp/prev_air_on
	else
		/usr/sbin/networksetup -setairportpower $AIRPORT off
		if [ "$BLUETOOTH" = "yes" ]; then
			$BLUEUTIL on
		fi
		if [ -f "/var/tmp/prev_air_on" ]; then
			rm /var/tmp/prev_air_on
		fi
	fi

}

growl() {

	# Checks whether Growl is installed
	if [ -f $GROWL ]; then
		$GROWL -m "$1" -a "AirPort Utility.app"
	fi

}

# Set default values
prev_eth_status="Off"
prev_air_status="Off"

eth_status="Off"

# Determine previous ethernet status
# If file prev_eth_on exists, ethernet was active last time we checked
if [ -f "/var/tmp/prev_eth_on" ]; then
	prev_eth_status="On"
fi

# Determine same for AirPort status
# File is prev_air_on
if [ -f "/var/tmp/prev_air_on" ]; then
	prev_air_status="On"
fi

# Check actual current ethernet status
if [ "`ifconfig en0 | grep \"status: active\"`" != "" ]; then
	eth_status="On"
fi

# And actual current AirPort status
air_status=`/usr/sbin/networksetup -getairportpower $AIRPORT | awk '{ print $4 }'`

# If any change has occured. Run external script (if it exists)
if [ "$prev_air_status" != "$air_status" ] || [ "$prev_eth_status" != "$eth_status" ]; then
	if [ -f "./statusChanged.sh" ]; then
		"./statusChanged.sh" "$eth_status" "$air_status" &
	fi
fi

# Determine whether ethernet status changed
if [ "$prev_eth_status" != "$eth_status" ]; then

	if [ "$eth_status" = "On" ]; then
		set_airport "Off"
		growl "Wired network detected. Turning AirPort off."
	else
		set_airport "On"
		growl "No wired network detected. Turning AirPort on."
	fi

else

	# Ethernet did not change

	# Check whether AirPort status changed
	# If so it was done manually by user
	if [ "$prev_air_status" != "$air_status" ]; then
		set_airport $air_status

		if [ "$air_status" = "On" ]; then
			growl "AirPort manually turned on."
		else
			growl "AirPort manually turned off."
		fi

	fi

fi

# Update ethernet status
if [ "$eth_status" == "On" ]; then
	touch /var/tmp/prev_eth_on
else
	if [ -f "/var/tmp/prev_eth_on" ]; then
		rm /var/tmp/prev_eth_on
	fi
fi

exit 0

