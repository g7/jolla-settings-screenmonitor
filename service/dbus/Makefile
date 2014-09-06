#
# ScreenMonitor - a simple screen usage monitor for Sailfish OS
# Copyright (C) 2014  Eugenio "g7" Paolantonio
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

DBUS_CONFIGURATION = eu.medesimo.ScreenMonitor.conf
DBUS_SERVICE = eu.medesimo.ScreenMonitor.service
SYSTEMD_UNIT = ScreenMonitor.service

install:
	cp -f $(DBUS_CONFIGURATION) $(DESTDIR)/etc/dbus-1/system.d
	cp -f $(DBUS_SERVICE) $(DESTDIR)/usr/share/dbus-1/system-services
	cp -f $(SYSTEMD_UNIT) $(DESTDIR)/lib/systemd/system

uninstall:
	rm -f $(DESTDIR)/etc/dbus-1/system.d/$(DBUS_CONFIGURATION)
	rm -f $(DESTDIR)/usr/share/dbus/system-services/$(DBUS_SERVICE)
	rm -f $(DESTDIR)/lib/systemd/system/$(SYSTEMD_UNIT)
