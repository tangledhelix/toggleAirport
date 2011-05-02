Credits
-------

toggleAirport is based on this post:

<http://hints.macworld.com/article.php?story=20100927161027611>

Purpose
-------

toggleAirport is a launchd service that toggles Airport power based on the
presence of a wired ethernet signal. The assumption is that if you have wired
ethernet connected, there is no need to keep the Aiport interface active.

It can also toggle Bluetooth power, but the logic is inverted (Bluetooth turns
on when wired ethernet is present). See below for more about Bluetooth.

Installation
------------

    sudo cp toggleAirport.sh /Library/Scripts
    sudo chown root:wheel /Library/Scripts/toggleAirport.sh
    sudo chmod 0755 /Library/Scripts/toggleAirport.sh
    
    sudo cp com.tangledhelix.toggleairport.plist /Library/LaunchDaemons
    sudo chown root:wheel /Library/LaunchDaemons/com.tangledhelix.toggleairport.plist
    sudo chmod 0644 /Library/LaunchDaemons/com.tangledhelix.toggleairport.plist

Configuration
-------------

There are a few settings at the top of `toggleAirport.sh`.

Adjust `GROWL` as needed to point to your copy of `growlnotify`.

    GROWL="/usr/bin/growlnotify"

Change if your interfaces differ from these defaults. These are already
correct for all of the MacBooks I have had in recent years.

    ETHERNET="en0"
    AIRPORT="en1"

See below for more on the bluetooth options.

    BLUETOOTH="no"
    BLUEUTIL="/usr/local/bin/blueutil"

Activation
----------

You'll need to activate the service after it's installed.

    sudo launchctl load /Library/LaunchDaemons/com.tangledhelix.toggleairport.plist

To deactivate, unload it.

    sudo launchctl unload /Library/LaunchDaemons/com.tangledhelix.toggleairport.plist

To deactivate it permanently, first unload, then delete the two files we
installed above.

Bluetooth support
-----------------

If you use a Bluetooth keyboard/mouse or other devices, you can have this service
turn Bluetooth off when you are away from your desk (signaled by the lack of
wired ethernet). In that case, set `BLUETOOTH` to `yes` in `toggleAirport.sh`.

Bluetooth support requires `blueutil`, found here:

<http://www.frederikseiffert.de/blueutil/>

