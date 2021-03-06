/*
 *	Temple Library for ActionScript 3.0
 *	Copyright © MediaMonks B.V.
 *	All rights reserved.
 *	
 *	Redistribution and use in source and binary forms, with or without
 *	modification, are permitted provided that the following conditions are met:
 *	1. Redistributions of source code must retain the above copyright
 *	   notice, this list of conditions and the following disclaimer.
 *	2. Redistributions in binary form must reproduce the above copyright
 *	   notice, this list of conditions and the following disclaimer in the
 *	   documentation and/or other materials provided with the distribution.
 *	3. All advertising materials mentioning features or use of this software
 *	   must display the following acknowledgement:
 *	   This product includes software developed by MediaMonks B.V.
 *	4. Neither the name of MediaMonks B.V. nor the
 *	   names of its contributors may be used to endorse or promote products
 *	   derived from this software without specific prior written permission.
 *	
 *	THIS SOFTWARE IS PROVIDED BY MEDIAMONKS B.V. ''AS IS'' AND ANY
 *	EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *	DISCLAIMED. IN NO EVENT SHALL MEDIAMONKS B.V. BE LIABLE FOR ANY
 *	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *	
 *	
 *	Note: This license does not apply to 3rd party classes inside the Temple
 *	repository with their own license!
 */
package temple.net.sharedobject
{
	import temple.core.events.ICoreEventDispatcher;

	import flash.net.SharedObject;

	/**
	 * Wrapper class that supports Quick assses to shared object properties.
	 * 
	 * @example
	 * <listing version="3.0">
	 * SharedObjectService.getInstance('projectName').setProperty('muted', true);
	 * SharedObjectService.getInstance('projectName').getProperty('muted');
	 * 
	 * // also:
	 * 
	 * _sharedObjectSite = new SharedObjectService('projectName', '');
	 * _sharedObjectGame = new SharedObjectService('projectName', '/game');
	 * 
	 * // tip: extend and provide typed accessors with prefilled default-values
	 *
	 * dispatches SharedObjectServiceEvent's when flushing (to check if the flushing fails or displays the dialog window)
	 * 
	 * </listing>
	 * 
	 * @author Arjan van Wijk, Bart van der Schoor
	 */
	public interface ISharedObjectService extends ICoreEventDispatcher
	{
		/**
		 * Sets a property on the SharedObject
		 * @param name The name of the property
		 * @param value The value of the property
		 */
		function setProperty(name:String, value:*):void;

		/**
		 * Gets a property of the SharedObject
		 * @param name The name of the property
		 * @param alt Return value if the property is not defined
		 * @return The value of the property
		 */
		function getProperty(name:String, alt:* = null):*;

		/**
		 * Check if a property is defined
		 * @param name The name of the property
		 * @return The value of the property
		 */
		function hasProperty(name:String):*;

		/**
		 * Remove a property on the SharedObject
		 * @param name The name of the property
		 */
		function removeProperty(name:String):void;

		/**
		 * Purges all of the data and deletes the shared object from the disk
		 */
		function clear():void;

		function flush(expectedSize:int = 0):String;

		function get so():SharedObject;

		function data():Object;
	}
}