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

import QtQuick 2.0
import "."
import Sailfish.Silica 1.0
import org.freedesktop.contextkit 1.0
import Nemo.DBus 2.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0

Page {
   id: self

   property string screenActive: qsTr("No data")
   property string last_reset_cause: ""
   property int percentage: 0
   property int brightness: 0

   function return_text_from_cause(cause) {
	   if (cause === "user") {
		   return qsTr("Since last reset");
	   } else if (cause === "boot") {
		   return qsTr("Since the phone start-up");
	   } else {
		   return qsTr("Since the disconnection from the charger")
	   }
   }

   function update() {
	   screenMonitor.call('GetSeconds', [], function(result) {
		   result = Math.abs(Math.round(result));

		   var minutes = Math.floor(result / 60);
		   var hours = Math.floor(minutes / 60);
		   var days = Math.floor(hours / 24);

		   minutes -= hours*60
		   hours -= days*24

		   screenActive = ("%1%2%3")
		   .arg(
				(days > 0) ? (
					(days == 1) ? qsTr("%1 day, ").arg(days) : qsTr("%1 days, ").arg(days)
				) : ""
			)
		   .arg(
				(hours > 0) ? (
					(hours == 1) ? qsTr("%1 hour, ").arg(hours) : qsTr("%1 hours, ").arg(hours)
				) : ""
			)
		   .arg(
				(minutes == 1) ? qsTr("%1 minute").arg(minutes) : qsTr("%1 minutes").arg(minutes)
			)

		   screenMonitor.call('GetChargeUptimeSeconds', [], function(uptime) {
			   percentage = Math.min(Math.abs((100*result)/uptime), 100);
		   });
	   });

	   screenMonitor.call('GetBrightness', [], function(result) {
		   brightness = result;
	   });

	   screenMonitor.call('GetLastResetCause', [], function(result) {
		   last_reset_cause = return_text_from_cause(result);
	   });
   }

   ContextProperty {
	   id: batteryPercentage
	   key: "Battery.ChargePercentage"
	   value: 0
   }

   DBusInterface {
	   id: screenMonitor
	   bus: DBus.SystemBus
	   service: 'eu.medesimo.ScreenMonitor'
	   path: '/eu/medesimo/ScreenMonitor'
	   iface: 'eu.medesimo.ScreenMonitor'

	   Component.onCompleted: update()
   }

   Timer {
	   interval: 60 * 1000
	   running: true;
	   repeat: true;
	   onTriggered: update()
   }

   SilicaFlickable {

	   anchors.fill: parent
	   contentHeight: content.height

	   PullDownMenu {
		   MenuItem {
			   text: qsTr("Reset")
			   onClicked: {
				   screenMonitor.call('ResetTimers', ["user"]);
				   screenActive = qsTr("%1 minutes").arg(0);
				   percentage = 100;
				   last_reset_cause = return_text_from_cause("user");
			   }
		   }
	   }

	   Column {
		   id: content

		   width: parent.width
		   spacing: Theme.paddingMedium

		   anchors {
			   left: parent.left
			   right: parent.right
			   fill: parent
		   }

		   PageHeader {
			   title: qsTr("Screen usage")
		   }

		   Column {

			   width: parent.width / 3;
			   anchors.horizontalCenter: parent.horizontalCenter
			   spacing: Theme.paddingMedium

			   ProgressCircleBase {
				   width: parent.width
				   height: width
				   value: percentage / 100
				   borderWidth: 2
				   progressColor: Theme.highlightColor

				   Text {
					   width: parent.width
					   anchors.centerIn: parent
					   color: Theme.highlightColor
					   font.pixelSize: Theme.fontSizeHuge
					   horizontalAlignment: Text.AlignHCenter
					   verticalAlignment: Text.AlignVCenter
                       text: qsTrId("%1%").arg(percentage)
				   }
			   }

			   Label {
				   width: parent.width * 1.5
				   anchors.horizontalCenter: parent.horizontalCenter
				   text: last_reset_cause;
				   font.pixelSize: Theme.fontSizeExtraSmall
				   wrapMode: Text.Wrap
				   horizontalAlignment: Text.AlignHCenter
				   color: Theme.highlightColor
				   opacity: 0.6
			   }

		   }

		   DetailItem {
			   width: parent.width
			   label: qsTr("Screen usage")
			   value: screenActive
		   }

		   DetailItem {
			   width: parent.width
			   label: qsTr("Battery")
               value: qsTrId("%1%").arg(batteryPercentage.value)
		   }

		   DetailItem {
			   width: parent.width
			   label: qsTr("Brightness")
               value: qsTrId("%1%").arg(brightness)
		   }

	   }
   }

}



