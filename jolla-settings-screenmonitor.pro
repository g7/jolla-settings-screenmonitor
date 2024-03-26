# Note: apologies for the shit you may find here, I come from a
# Debian/debuild/GTK+/geany/nano background and I don't %like
# %rpm %packaging %at %all so this .pro file alongside the .yaml
# and the .spec are a bit (??) messy.
#
# I also don't think there is a way to correctly integrate vala
# sources from qmake/Qt Creator (well, vala is GObject/GTK+ oriented
# after all :D) so the TEMPLATE here is set to aux and the ScreenMonitor
# target will call make on the vala sources.

TEMPLATE = aux

TARGET = jolla-settings-screenmonitor
jolla-settings-screenmonitor.depends += ScreenMonitor
screenmonitor-executable.CONFIG += no_check_exist

#CONFIG += sailfishapp

screenmonitor-entry.path = /usr/share/jolla-settings/entries
screenmonitor-entry.files = settings/screenmonitor.json

screenmonitor-qml.path = /usr/share/jolla-settings/pages/screenmonitor
screenmonitor-qml.files = settings/jolla-settings-screenmonitor.qml settings/DetailItem.qml settings/icon.png

screenmonitor-executable.path = /usr/bin
screenmonitor-executable.files = service/ScreenMonitor

screenmonitor-dbus-configuration.path = /etc/dbus-1/system.d
screenmonitor-dbus-configuration.files = service/dbus/eu.medesimo.ScreenMonitor.conf

screenmonitor-dbus-service.path = /usr/share/dbus-1/system-services
screenmonitor-dbus-service.files = service/dbus/eu.medesimo.ScreenMonitor.service

screenmonitor-systemd.path = $$PREFIX/lib/systemd/system
screenmonitor-systemd.files = service/dbus/ScreenMonitor.service

INSTALLS += \
	screenmonitor-entry \
	screenmonitor-qml \
	screenmonitor-executable \
	screenmonitor-dbus-configuration \
	screenmonitor-dbus-service \
	screenmonitor-systemd

OTHER_FILES += \
    rpm/jolla-settings-screenmonitor.spec \
    rpm/jolla-settings-screenmonitor.yaml \
	service/dbus_interface.vala \
	service/ScreenMonitor.vala \
	service/ScreenMonitor \
	service/UnixTimer.vala \
	service/service.vala \
	service/Makefile \
	service/dbus/eu.medesimo.ScreenMonitor.service \
	service/dbus/eu.medesimo.ScreenMonitor.conf \
	service/dbus/Makefile \
    service/UnixTimer.vala \
    settings/DetailItem.qml \
    rpm/jolla-settings-screenmonitor.changes \
    service/FileWatcher.vala

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/jolla-settings-screenmonitor-de.ts

# This is needed to compile the DBus service
screenmonitor-service.target = ScreenMonitor
screenmonitor-service.commands = make -C $$PWD/service
QMAKE_EXTRA_TARGETS += screenmonitor-service
PRE_TARGETDEPS += ScreenMonitor

# Hm, is there a way to call make -C $$PWD/service clean?
QMAKE_CLEAN += $$PWD/service/ScreenMonitor
