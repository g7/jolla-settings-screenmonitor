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

	public class FileWatcher : Object {

		/**
		 * A simple file watcher.
		*/

		public string path { get; construct set; }

		private File file_object;
		private FileMonitor file_monitor;

		/* "created" signal */
		public signal void created (File trigger);

		/* "changed" signal */
		public signal void changed (File trigger, FileMonitorEvent event);

		public FileWatcher(string path) {
			/**
			 * Initializes the watcher.
			 *
			 * path is the file path to watch.
			*/

			this.path = path;
			this.file_object = File.new_for_path(this.path);

		}

		public void start_monitor(bool created_if_existing = true, bool trigger_create_on_error = true) {
			/**
			 * Starts the File monitor.
			*/

			try {
				this.file_monitor = this.file_object.monitor(FileMonitorFlags.NONE, null);

				/* If file already exists, fire the "created" signal if needed */
				if (this.file_object.query_exists() && created_if_existing)
					this.created(this.file_object);

				this.file_monitor.changed.connect(
					(trigger, other_file, event) => {

						if (event == FileMonitorEvent.CREATED) {
							/* Trigger "created" signal */
							this.created(trigger);
						} else if (
							(event == FileMonitorEvent.CHANGED) ||
							(event == FileMonitorEvent.DELETED) ||
							(event == FileMonitorEvent.MOVED)
						) {
							/* Fire the "changed" signal */
							this.changed(trigger, event);
						}
					 }
				);
			} catch (Error e) {
				if (trigger_create_on_error)
					this.created(this.file_object);

				warning("Unable to monitor file %s", this.path);
			}
		}

		public void cancel() {
			/**
			 * Cancels the monitor operation.
			*/

			if (!this.file_monitor.is_cancelled())
				this.file_monitor.cancel();

		}
	}
}
