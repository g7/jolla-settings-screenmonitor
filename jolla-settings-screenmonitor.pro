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

screenmonitor-systemd.path = /usr/lib/systemd/system
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

TRANSLATIONS += $$files(translations/$${TARGET}-*.ts)
TS_FILE = $${_PRO_FILE_PWD_}/translations/$${TARGET}*.ts
HAVE_TRANSLATIONS = 0

TRANSLATION_SOURCES += $$_PRO_FILE_PWD_/settings/

# prefix all TRANSLATIONS with the src dir
# the qm files are generated from the ts files copied to out dir
for(t, TRANSLATIONS) {
    TRANSLATIONS_IN  += $${_PRO_FILE_PWD_}/$$t
    TRANSLATIONS_OUT += $${OUT_PWD}/$$t
    HAVE_TRANSLATIONS = 1
}

qm.files = $$replace(TRANSLATIONS_OUT, \.ts, .qm)
qm.path = /usr/share/translations
qm.CONFIG += no_check_exist

# update the ts files in the src dir and then copy them to the out dir
qm.commands += lupdate -noobsolete $${TRANSLATION_SOURCES} -ts $${TS_FILE} && \
    mkdir -p translations && \
    [ \"$${OUT_PWD}\" != \"$${_PRO_FILE_PWD_}\" -a $$HAVE_TRANSLATIONS -eq 1 ] && \
    cp -af $${TRANSLATIONS_IN} $${OUT_PWD}/translations || :

# create the qm files
qm.commands += ; [ $$HAVE_TRANSLATIONS -eq 1 ] && lrelease -nounfinished $${TRANSLATIONS_OUT} || :

# special case: as TS_FILE serves as both source file as well as
# the English translation source, create the en qm file from it:
qm.files += $$replace(TS_FILE, \.ts, -en.qm)
qm.commands += lrelease -nounfinished $$TS_FILE -qm $$replace(TS_FILE, \.ts, -en.qm)

INSTALLS += qm

OTHER_FILES += $$TRANSLATIONS

# This is needed to compile the DBus service
screenmonitor-service.target = ScreenMonitor
screenmonitor-service.commands = make -C $$PWD/service
QMAKE_EXTRA_TARGETS += screenmonitor-service
PRE_TARGETDEPS += ScreenMonitor

# Hm, is there a way to call make -C $$PWD/service clean?
QMAKE_CLEAN += $$PWD/service/ScreenMonitor
