Credits
-------

This service was adapted from this original:

<http://hints.macworld.com/article.php?story=20100927161027611>

Purpose
-------

This is a launchd service that toggles Airport power based on the presence of
wired ethernet. The assumption is that if you have wired ethernet, there is no
need to keep the Aiport interface active.

It can also toggle Bluetooth power, but that is inverse (it turns on when there
is wired ethernet present). See below for more about Bluetooth.

Installation
------------

	cp toggleAirport.sh /Library/Scripts
	chown root:admin /Library/Scripts/toggleAirport.sh
	chmod 0755 /Library/Scripts/toggleAirport.sh
	
	cp com.tangledhelix.toggleairport.plist /Library/LaunchAgents
	chown root:admin /Library/LaunchAgents/com.tangledhelix.toggleairport.plist
	chmod 0644 /Library/LaunchAgents/com.tangledhelix.toggleairport.plist

Configuration
-------------

There are a few settings at the top of `toggleAirport.sh`.

	GROWL="/usr/bin/growlnotify"

Adjust as needed to point to your copy of `growlnotify`.

	AIRPORT="en1"

Change if your airport interface is something other than `en1`.

	BLUETOOTH="no"
	BLUEUTIL="/usr/local/bin/blueutil"

See below for more on the bluetooth options.

Activation
----------

You'll need to activate the service after it's installed.

	launchctl load /Library/LaunchAgents/com.tangledhelix.toggleairport.plist

To deactivate, unload it:

	launchctl unload /Library/LaunchAgents/com.tangledhelix.toggleairport.plist

Bluetooth support
-----------------

If you use a Bluetooth keyboard/mouse or other devices, you can have this service
turn Bluetooth off when you are away from your desk (signaled by the lack of
wired ethernet). In that case, set `BLUETOOTH` to `yes` in `toggleAirport.sh`.

Bluetooth support requires `blueutil`, found here:

<http://www.frederikseiffert.de/blueutil/>

