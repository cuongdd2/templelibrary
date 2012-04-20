/*
 *	 
 *	Temple Library for ActionScript 3.0
 *	Copyright © 2010 MediaMonks B.V.
 *	All rights reserved.
 *	
 *	http://code.google.com/p/templelibrary/
 *	
 *	Redistribution and use in source and binary forms, with or without
 *	modification, are permitted provided that the following conditions are met:
 *	
 *	- Redistributions of source code must retain the above copyright notice,
 *	this list of conditions and the following disclaimer.
 *	
 *	- Redistributions in binary form must reproduce the above copyright notice,
 *	this list of conditions and the following disclaimer in the documentation
 *	and/or other materials provided with the distribution.
 *	
 *	- Neither the name of the Temple Library nor the names of its contributors
 *	may be used to endorse or promote products derived from this software
 *	without specific prior written permission.
 *	
 *	
 *	Temple Library is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU Lesser General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *	
 *	Temple Library is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU Lesser General Public License for more details.
 *	
 *	You should have received a copy of the GNU Lesser General Public License
 *	along with Temple Library.  If not, see <http://www.gnu.org/licenses/>.
 *	
 *	
 *	Note: This license does not apply to 3rd party classes inside the Temple
 *	repository with their own license!
 *	
 */
 
package temple.ui.scroll 
{
	import flash.events.Event;

	/**
	 * @author Thijs Broerse
	 */
	public class ScrollEvent extends Event 
	{
		/**
		 * Dispatched when the scrollable object is scrolled
		 */
		public static var SCROLL:String = "ScrollEvent.scroll";
		
		/**
		 * Dispatched by the scroll bar to scroll up one step
		 */
		public static var SCROLL_UP:String = "ScrollEvent.scrollUp";
		
		/**
		 * Dispatched by the scroll bar to scroll down one step
		 */
		public static var SCROLL_DOWN:String = "ScrollEvent.scrollDown";
		
		private var _scrollH:Number;
		private var _scrollV:Number;
		private var _maxScrollH:Number;
		private var _maxScrollV:Number;

		function ScrollEvent(type:String, scrollH:Number, scrollV:Number, maxScrollH:Number, maxScrollV:Number) 
		{
			super(type);
			
			this._scrollH = scrollH;
			this._scrollV = scrollV;
			this._maxScrollH = maxScrollH;
			this._maxScrollV = maxScrollV;
		}
		
		public function get scrollH():Number
		{
			return this._scrollH;
		}
		
		public function get scrollV():Number
		{
			return this._scrollV;
		}
		
		public function get maxScrollH():Number
		{
			return this._maxScrollH;
		}
		
		public function get maxScrollV():Number
		{
			return this._maxScrollV;
		}

		override public function clone():Event
		{
			return new ScrollEvent(this.type, this.scrollH, this.scrollV, this.maxScrollH, this.maxScrollV);
		}
	}
}