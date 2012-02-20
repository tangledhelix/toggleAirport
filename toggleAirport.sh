#!/bin/bash
#
# Adapted from http://hints.macworld.com/article.php?story=20100927161027611

# ----- START CONFIGURATION ----- #

# Change to your growlnotify path
GROWL="/usr/bin/growlnotify"

# Adjust to use the interface names on your system. On many Macs, these
# defaults are correct.
ETHERNET="en0"
AIRPORT="en1"

# Set to 'yes' if you want to toggle Bluetooth as well. Requires blueutil.
BLUETOOTH="no"

# Path to blueutil
BLUEUTIL="/usr/local/bin/blueutil"

# ----- END CONFIGURATION ----- #

# You probably shouldn't change anything past this point.

_nsetup="/usr/sbin/networksetup"
_flag_air="/tmp/prev_air_on"
_flag_eth="/tmp/prev_eth_on"

set_airport() {

    new_status=$1

    if [ $new_status = "On" ]; then
        $_nsetup -setairportpower $AIRPORT on
        if [ "$BLUETOOTH" = "yes" ]; then
            $BLUEUTIL off
        fi
        touch $_flag_air
    else
        $_nsetup -setairportpower $AIRPORT off
        if [ "$BLUETOOTH" = "yes" ]; then
            $BLUEUTIL on
        fi
        if [ -f "$_flag_air" ]; then
            rm $_flag_air
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
# If eth flag file exists, ethernet was active last time we checked
if [ -f "$_flag_eth" ]; then
    prev_eth_status="On"
fi

# Determine same for AirPort status
if [ -f "$_flag_air" ]; then
    prev_air_status="On"
fi

# Check actual current ethernet status
if [ "`ifconfig $ETHERNET | grep \"status: active\"`" != "" ]; then
    eth_status="On"
fi

# And actual current AirPort status
air_status=`$_nsetup -getairportpower $AIRPORT | awk '{ print $4 }'`

# If any change has occured. Run external script (if it exists)
if [ "$prev_air_status" != "$air_status" ] || [ "$prev_eth_status" != "$eth_status" ]; then
    if [ -f "./statusChanged.sh" ]; then
        ./statusChanged.sh "$eth_status" "$air_status" &
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
if [ "$eth_status" = "On" ]; then
    touch $_flag_eth
else
    if [ -f "$_flag_eth" ]; then
        rm $_flag_eth
    fi
fi

exit 0

