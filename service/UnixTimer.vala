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

	public class UnixTimer : Object {
		
		/**
		 * A simple Timer that uses the Unix time.
		 * 
		 * It's inspired by glib's (G)Timer(), even if it is not
		 * a full drop-in replacement.
		 * 
		 * Some differences:
		 *  - After the instantiation, the timer is not started
		 *    automatically (you must use the start() method)
		 *  - There is no reset() method (which is useless on the original
		 *    Timer too, because start() resets the timer as well)
		 *  - The start() method accepts a boolean variable, remove_offset
		 *    (defaults to true). If false, the offset is not removed.
		 *    Usually you won't need to modify the default value.
		 *  - The elapsed() method does not return milliseconds with the
		 *    (normal) seconds.
		*/
		
		/* true = timer active, false = timer stopped */
		public bool active { get; private set; }
		
		private int64 _start = 0;
		private int64 _end = 0;
		private int64 _offset = 0;

		public UnixTimer() {
			/**
			 * Constructs the UnixTimer.
			*/
			
			this.active = false;
		}

		private int64 retrieve_time() {
			/**
			 * Returns the current Unix time.
			*/
			
			return new DateTime.now_utc().to_unix();
		}
		
		public void start(bool remove_offset = true) {
			/**
			 * Starts (or resets) the timer.
			*/
			
			this._start = this.retrieve_time();
			if (remove_offset)
				this._offset = 0;
			
			this.active = true;
			
		}
		
		public int64 elapsed() {
			/**
			 * Returns the elapsed time between start and now.
			*/
			
			if (this.active)
				return (this.retrieve_time() - this._start) + this._offset;
			else
				return (this._end - this._start) + this._offset;
			
		}
		
		public void stop() {
			/**
			 * Stops the timer.
			*/
			
			this._end = this.retrieve_time();
			
			this.active = false;
		}

		public void continue() {
			/**
			 * Restarts a previously stopped timer, without resetting
			 * it.
			*/

			this._offset = this.elapsed();

			this.start(false);

		}

	}
	
}
