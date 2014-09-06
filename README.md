jolla-settings-screenmonitor
============================

jolla-settings-screenmonitor is a jolla-settings (SailfishOS's control center) module
that keeps track of the usage record of the phone's display.

Also, I think this is the first vala-based application for SailfishOS! :)

Features
--------

The module is accessible directly on the control center, just below the "Battery" item.

It displays the total screen usage since the last reset and the percentage of the screen usage
respect to the total uptime (obviously the 'total uptime' is since the last reset as well).

The timers are reset when
  - The user chooses to do so (via the pulley-menu)
  - The phone reboots (of course, I'll add :D)
  - The charger has been removed

How does it work?
-----------------

There is a small DBus service running in the background that reacts to the
display state events from MCE and that keeps track of the timestamps of
the events via a simple timer.

It also subscribes to the usb_moded statuses, so it can react when the
charger has been disconnected.  
The 'natural' and 'best' way to accomplish that would be to use directly
UPower, but it seems that the DBus implementation of SailfishOS does not
fire the PropertyChanged signal, so vala doesn't know when e.g. the battery
gets to the "Discharging" status.

This issue may be workarounded by polling UPower using the standard freedesktop
Get method, but it may end up flooding the bus but it's not worth it for
a single propriety that may change the value just once a day.

In the UI side, a QML page connects to the service and displays the values
to the user.

About the packaging
-------------------

I come from a Debian/debuild/GTK+/geany/nano background and I don't %like
%rpm %packaging %at %all, so apologies in advance for the shit that you may find
in the .pro, .yaml and .spec files.

There are also no 'good' way to integrate vala sources in qmake, so I
may be somewhat justified for the packaging obscenities in this repository :D
