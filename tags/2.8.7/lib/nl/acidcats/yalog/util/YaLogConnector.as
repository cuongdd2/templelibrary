/*
Copyright 2009 Stephan Bezoen, http://stephan.acidcats.nl

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package nl.acidcats.yalog.util 
{
	import nl.acidcats.yalog.Yalog;

	import temple.debug.log.Log;
	import temple.debug.log.LogEvent;
	import temple.debug.log.LogLevel;

	public class YaLogConnector 
	{
		private static var _instance:YaLogConnector;

		/**
		 * @return singleton instance of YaLogConnector
		 */
		public static function getInstance():YaLogConnector 
		{
			if (YaLogConnector._instance == null) YaLogConnector._instance = new YaLogConnector();
			return YaLogConnector._instance;
		}
		
		/**
		 * Connect to the Log.
		 * @param name optional name that is used to identify the connection. The name is displayed in Yalala.
		 */
		public static function connect(name:String = null):void 
		{
			YaLogConnector.getInstance();
			Yalog.connectionName = name;
		}
		
		/**
		 * Indicates if Yalog is already connected.
		 */
		public static function get isConnected():Boolean
		{
			return !!YaLogConnector._instance;
		}

		public function YaLogConnector() 
		{
			Log.addLogListener(this.handleLogEvent);
			Yalog.showTrace = false;
		}

		private function handleLogEvent(event:LogEvent):void 
		{
			switch (event.level) 
			{
				case LogLevel.DEBUG: 
					Yalog.debug(event.data, event.sender, event.objectId, event.stackTrace); 
					break;
				case LogLevel.ERROR: 
					Yalog.error(event.data, event.sender, event.objectId, event.stackTrace); 
					break;
				case LogLevel.FATAL: 
					Yalog.fatal(event.data, event.sender, event.objectId, event.stackTrace); 
					break;
				case LogLevel.INFO: 
					Yalog.info(event.data, event.sender, event.objectId, event.stackTrace); 
					break;
				case LogLevel.STATUS: 
					Yalog.info(event.data, event.sender, event.objectId, event.stackTrace); 
					break;
				case LogLevel.WARN: 
					Yalog.warn(event.data, event.sender, event.objectId, event.stackTrace); 
					break;
			}
		}
	}
}