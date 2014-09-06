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

namespace ScreenMonitor {

	[DBus (name = "com.nokia.mce.signal")]
	public interface MceInterface : Object {
		/**
		 * Interface to MCE signals
		*/

		[DBus (name = "display_status_ind")]
		public abstract signal void display_status_ind(string display_state);
	}

	[DBus (name = "com.nokia.mce.request")]
	public interface MceRequestInterface : Object {
		/**
		 * Interface to MCE requests
		*/

		[DBus (name = "get_display_status")]
		public abstract string get_display_status() throws IOError;

		[DBus (name = "get_config")]
		public abstract Variant get_config(string key) throws IOError;

	}

	[DBus (name = "com.meego.usb_moded")]
	public interface UsbModed : Object {
		/**
		 * Interface to usb_moded
		*/
		
		[DBus (name = "sig_usb_state_ind")]
		public abstract signal void sig_usb_state_ind(string state);
		
	}

}
