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
	
	public class Main : Object {
		/**
		 * The main class.
		*/
		
		private static bool dbus = false;
		
		/* Options */
		private const OptionEntry[] options = {
			/* dbus */
			{ "dbus", 'd', 0, OptionArg.NONE, ref dbus, "Starts the dbus service", null },

			/* The end */
			{ null }
		};
		
		public static int main(string[] args) {
			/**
			 * Everything begins here.
			*/
			
			if (args.length == 1) {
				stdout.puts("You need to specify at least an argument! See -h for more details.\n");
				return 1;
			}
			
			/* Parse arguments */
			try {
				OptionContext optcontext = new OptionContext("- a simple screen usage monitor for Sailfish OS.");
				optcontext.set_help_enabled(true);
				optcontext.set_ignore_unknown_options(false);
				optcontext.add_main_entries(options, null);
				
				optcontext.parse(ref args);
			} catch (OptionError e) {
				stdout.printf("error: %s\n", e.message);
				stdout.puts("Use the -h switch to see the full list of available command line arguments.\n");
				return 1;
			}
			
			if (dbus) {
				/* Start the dbus service */
				Service.StartService();
			}
			
			return 0;
		}
		
	}

}
