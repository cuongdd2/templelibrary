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

package temple.mediaplayers.video.cuepoints 
{
	import temple.core.debug.IDebuggable;
	import temple.core.behaviors.AbstractBehavior;
	import temple.mediaplayers.players.IPlayer;
	import temple.mediaplayers.players.PlayerStatus;
	import temple.utils.types.VectorUtils;

	import flash.events.Event;
	import flash.utils.getTimer;

	/**
	 * Class for adding cuepoints in a VideoPlayer at runtime.
	 * 
	 * @includeExample RuntimeCuePointsBehaviorExample.as
	 * 
	 * @author Thijs Broerse
	 */
	public class RuntimeCuePointsBehavior extends AbstractBehavior implements IDebuggable
	{
		private var _cuepoints:Vector.<VideoCuePoint>;
		private var _previousPlayTime:Number;
		private var _previousCheckTime:Number;
		private var _debug:Boolean;

		public function RuntimeCuePointsBehavior(target:IPlayer)
		{
			super(target);
			
			_cuepoints = new Vector.<VideoCuePoint>();
			
			target.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}

		/**
		 * Returns a reference to the player
		 */
		public function get videoPlayer():IPlayer 
		{
			return target as IPlayer;
		}

		/**
		 * Add a runtime CuePoint.
		 */
		public function addCuePoint(cuepoint:VideoCuePoint):void 
		{
			_cuepoints.push(cuepoint);
			VectorUtils.sortOn(_cuepoints, 'time', Array.NUMERIC);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get debug():Boolean
		{
			return _debug;
		}

		/**
		 * @inheritDoc
		 */
		public function set debug(value:Boolean):void
		{
			_debug = value;
		}

		private function handleEnterFrame(event:Event):void 
		{
			var playTime:Number = videoPlayer.currentPlayTime;
			var checkTime:Number = getTimer() * .001;
			if (videoPlayer.status == PlayerStatus.PLAYING)
			{
				if (_previousPlayTime > playTime || isNaN(_previousPlayTime)) _previousPlayTime = 0;
				
				if (playTime != _previousPlayTime && playTime - _previousPlayTime <= checkTime - _previousCheckTime + .1)
				{
					var leni:int = _cuepoints.length;
					var cuepoint:VideoCuePoint;
					for (var i:int = 0; i < leni; i++)
					{
						cuepoint = VideoCuePoint(_cuepoints[i]);
						if (cuepoint.time > playTime)
						{
							break;
						}
						else if (cuepoint.time > _previousPlayTime || _previousPlayTime == 0)
						{
							videoPlayer.dispatchEvent(new CuePointEvent(CuePointEvent.CUEPOINT, cuepoint));
						}
					}
				}
			}
			_previousPlayTime = playTime;
			_previousCheckTime = checkTime;
		}

		/**
		 * @inheritDoc
		 */
		override public function destruct():void 
		{
			if (videoPlayer)
			{
				videoPlayer.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
			_cuepoints = null;
			
			super.destruct();
		}
	}
}
