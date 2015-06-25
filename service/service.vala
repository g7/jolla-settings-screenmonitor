/*
 * ScreenMonitor - a simple screen usage monitor for Sailfish OS
 * Copyright (C) 2014-2015  Eugenio "g7" Paolantonio
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

	[DBus (name = "eu.medesimo.ScreenMonitor")]
	public class Service : Object {
		/**
		 * This is the main DBus service for ScreenMonitor.
		 * 
		 * It will own the eu.medesimo.ScreenMonitor name on
		 * the SystemBus.
		*/
				
		private MainLoop main_loop;
		
		private MceInterface mce;
		private MceRequestInterface mce_request;
		private UsbModed usb_moded;

		private bool is_display_on;
		private string last_reset_cause = "boot";
		
		private UnixTimer timer;
		private UnixTimer charge_uptime_timer;

		public Service() {
			/**
			 * Constructs the service.
			*/
			
			/* Create timers */
			this.timer = new UnixTimer();
			
			this.charge_uptime_timer = new UnixTimer();
			
			/* Start the timer when the system has been fully initialized */
			FileWatcher watcher = new FileWatcher("/run/systemd/boot-status/init-done");
			watcher.created.connect(
				(trigger) => {
					/* Activate the timers */
					this.charge_uptime_timer.start();
					this.timer.start();

					/* Is the display already active? If not, stop the timer */
					if (this.GetDisplayState() == "off")
                                            this.timer.stop();

					watcher.cancel();
				}
			);
			
			/* Connect to UsbModed */
			this.usb_moded = Bus.get_proxy_sync(
				BusType.SYSTEM,
				"com.meego.usb_moded",
				"/com/meego/usb_moded"
			);
			this.usb_moded.sig_usb_state_ind.connect(this.on_battery_state_changed);
			
			/* Connect to MCE (signal)*/
			this.mce = Bus.get_proxy_sync(
				BusType.SYSTEM,
				"com.nokia.mce",
				"/com/nokia/mce/signal"
			);
			this.mce.display_status_ind.connect(this.on_display_status_changed);

			/* Connect to MCE (request) */
			this.mce_request = Bus.get_proxy_sync(
				BusType.SYSTEM,
				"com.nokia.mce",
				"/com/nokia/mce/request"
			);

			/* Start watcher monitor */
			watcher.start_monitor();
		}

		public void Quit() {
			/**
			 * Closes the connection and exits the mainloop.
			*/
			
			Timeout.add_seconds(
				2,
				() => {
					this.main_loop.quit();
					
					return false;
				}
			);
		}
		
		public double GetSeconds() {
			/**
			 * Returns the screen usage, in seconds.
			*/
			
			return this.timer.elapsed();
			
		}
		
		public double GetChargeUptimeSeconds() {
			/**
			 * Returns the total phone usage (since the last reset).
			*/
			
			return this.charge_uptime_timer.elapsed();
			
		}

		public int32 GetBrightness() {
			/**
			 * Returns the current display brightness.
			*/

			return this.mce_request.get_config("/system/osso/dsm/display/display_brightness").get_int32();

		}

		public void ResetTimers(string cause) {
			/**
			 * Resets the timers.
			*/

			if (cause != "boot" && cause != "user" && cause != "charger")
				cause = "user";

			this.charge_uptime_timer.start();
			this.timer.start();
			if (!this.is_display_on)
				this.timer.stop();

			this.last_reset_cause = cause;

		}

		public string GetLastResetCause() {
			/**
			 * Returns a string containing the 'Last Reset Cause',
			 * the cause of the last reset. (duh!)
			 *
			 * It may be one of "user", "boot", "charger"
			*/

			return this.last_reset_cause;
		}

		private string GetDisplayState() {
			/**
			 * Returns the current display status from MCE.
			*/

			return this.mce_request.get_display_status();

		}
		
		private void on_display_status_changed(string status) {
			/**
			 * Fired when the status of the display has been changed.
			*/

			if (status == "on") {
				/* Display is now on, restart the timer */
				this.is_display_on = true;
				this.timer.continue();
			} else if (status == "off" ) {
				/* Display is off, stop the timer */
				this.is_display_on = false;
				this.timer.stop();
			}
			
		}
		
		private void on_battery_state_changed(string state) {
			/**
			 * Fired when the usb_moded status has been changed.
			 * 
			 * The method name is pretty misleading because it can react
			 * too to other states (SDK mode, PC mode, etc.).
			 * Obiviously the timers are reset *only* on the "USB disconnected"
			 * or "charger_disconnected" states.
			 * 
			 * The reason we're not using UPower here is because the DBus implementation
			 * in Sailfish doesn't fire (or at least it seems so) the PropertyChanged
			 * signal when a property has been changed.
			 * Without it, we can't know when the battery went into the "Discharging"
			 * mode, because vala will always return a cached property value
			 * if it doesn't know that the property changed.
			 * 
			 * We can workaround that by polling UPower via the standard
			 * freedesktop.org Proprietes interface, but it then may flood
			 * the bus with property requests every time UPower's Changed()
			 * signal has been fired (which it may be for something unuseful
			 * for us like capacity/charge drop and the like).
			 * 
			 * Thus, we hook on usb_moded's signals here.
			*/
			
			if (state == "USB disconnected" || state == "charger_disconnected") {
				/* Reset timers */
				this.ResetTimers("charger");
			}
			
		}
		
		[DBus (visible = false)]
		public void start_mainloop() {
			/**
			 * Creates and starts the mainloop.
			*/
			
			this.main_loop = new MainLoop();
			this.main_loop.run();
		}
		
		[DBus (visible = false)]
		public static void StartService() {
			/**
			 * Starts the service.
			*/
			
			Service service = new Service();
			
			DBusConnection connection = null;
			uint identifier;
					
			identifier = Bus.own_name(
				BusType.SYSTEM,
				"eu.medesimo.ScreenMonitor",
				BusNameOwnerFlags.NONE,
				(conn) => {
					/* Register the object */
					connection = conn;
					
					try {
						conn.register_object("/eu/medesimo/ScreenMonitor", service);
					} catch (IOError e) {
						error("Couldn't register service: %s", e.message);
					}
				},
				() => {},
				(conn, name) => error("Unable to acquire bus %s", name)
			);
			
			/* Start the timeout and the MainLoop */
			service.start_mainloop();
			
			/* When we get here, we can cleanup... */
			connection.close_sync();
			Bus.unown_name(identifier);
		}
		
	}
	
}
