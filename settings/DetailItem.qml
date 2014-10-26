/*
 * ScreenMonitor - a simple screen usage monitor for Sailfish OS
 * Copyright (C) 2014  Eugenio "g7" Paolantonio
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
*/

/*
 * In Uitukka (update9; 1.1.0.38/39) the private and jolla-settings specific
 * AboutItem widget has been renamed and moved directly in Silica, using the
 * name DetailItem.
 *
 * This fake widget is here only to maintain compatibility with previous
 * SailfishOS releases by loading the AboutItem widget.
 * If it isn't available, QML's Loader will fail silently.
 *
 * The import order in jolla-settings-screenmonitor.qml will ensure that
 * Silica gets imported just after this module, so that in Uitukka (and above)
 * the real DetailItem will take over this.
*/

import QtQuick 2.0

Loader {
	id: _loader

	property string value
	property string label

	Component.onCompleted: {
		_loader.setSource(
			"/usr/lib/qt5/qml/com/jolla/settings/system/AboutItem.qml",
			{ "value" : value, "label" : label }
		)
	}
}
