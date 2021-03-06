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

package temple.facebook.data.vo
{
	import temple.core.CoreObject;
	import temple.facebook.data.enum.FacebookConnection;
	import temple.facebook.data.enum.FacebookFieldAlias;
	import temple.facebook.data.facebook;
	import temple.facebook.service.IFacebookService;

	/**
	 * @private
	 * 
	 * @author Thijs Broerse
	 */
	public class FacebookPhotoTagData extends CoreObject implements IFacebookPhotoTagData
	{
		public static function register(facebook:IFacebookService):void
		{
			facebook.registerVO(FacebookConnection.TAGS, FacebookPhotoData);
		}

		facebook var id:String;
		facebook var name:String;
		facebook var x:Number;
		facebook var y:Number;
		facebook var created_time:Date;
		facebook var photo:IFacebookPhotoData;
		facebook var category:String;
		
		private var _service:IFacebookService;
		private var _user:IFacebookUserData;
		
		public function FacebookPhotoTagData(service:IFacebookService)
		{
			super();
			_service = service;
			toStringProps.push("name", "x", "y");
		}

		/**
		 * @inheritDoc
		 */
		public function get user():IFacebookUserData
		{
			return facebook::id ? _user ||= _service.parser.parse({id: facebook::id, name: facebook::name}, FacebookUserData, FacebookFieldAlias.GRAPH) as IFacebookUserData : null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get name():String
		{
			return facebook::name;
		}

		/**
		 * @inheritDoc
		 */
		public function get x():Number
		{
			return facebook::x * .01;
		}

		/**
		 * @inheritDoc
		 */
		public function get y():Number
		{
			return facebook::y * .01;
		}

		/**
		 * @inheritDoc
		 */
		public function get created():Date
		{
			return facebook::created_time;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get photo():IFacebookPhotoData
		{
			return facebook::photo;
		}
	}
}
