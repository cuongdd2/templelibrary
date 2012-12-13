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

package temple.net.multipart
{
	import temple.core.errors.throwError;
	import temple.core.events.CoreEventDispatcher;
	import temple.core.net.CoreURLLoader;
	import temple.utils.TimeOut;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;

	/**
	 * Multipart URL Loader
	 *
	 * Original idea by Marston Development Studio - http://marstonstudio.com/?p=36
	 *
	 * History
	 * 2009.01.15 version 1.0
	 * Initial release
	 *
	 * 2009.01.19 version 1.1
	 * Added options for MIME-types (default is application/octet-stream)
	 *
	 * 2009.01.20 version 1.2
	 * Added clearVariables and clearFiles methods
	 * Small code refactoring
	 * Public methods documentaion
	 *
	 * 2009.02.09 version 1.2.1
	 * Changed 'useWeakReference' to false (thanx to zlatko)
	 * It appears that on some servers setting 'useWeakReference' to true
	 * completely disables this event
	 *
	 * 2009.03.05 version 1.3
	 * Added Async property. Now you can prepare data asynchronous before sending it.
	 * It will prevent flash player from freezing while constructing request data.
	 * You can specify the amount of bytes to write per iteration through BLOCK_SIZE static property.
	 * Added events for asynchronous method.
	 * Added dataFormat property for returned server data.
	 * Removed 'Cache-Control' from headers and added custom requestHeaders array property.
	 * Added getter for the URLLoader class used to send data.
	 *
	 * 2010.02.23
	 * Fixed issue 2 (loading failed if not directly dispatched from mouse event)
	 * problem and fix reported by gbradley@rocket.co.uk
	 *
	 * @author Eugene Zatepyakin
	 * @version 1.3
	 * @link http://blog.inspirit.ru/
	 */
	public class MultipartURLLoader extends CoreEventDispatcher
	{
		public static var BLOCK_SIZE:uint = 64 * 1024;
		
		public var requestHeaders:Array;
		
		private var _loader:CoreURLLoader;
		private var _boundary:String;
		private var _variableNames:Array;
		private var _fileNames:Array;
		private var _variables:Dictionary;
		private var _files:Dictionary;
		private var _async:Boolean = false;
		private var _path:String;
		private var _data:ByteArray;
		private var _prepared:Boolean = false;
		private var _asyncWriteTimeoutId:TimeOut;
		private var _asyncFilePointer:uint = 0;
		private var totalFilesSize:uint = 0;
		private var _writtenBytes:uint = 0;
		private var _urlRequestMethod:String = URLRequestMethod.POST;

		public function MultipartURLLoader()
		{
			this._fileNames = new Array();
			this._files = new Dictionary();
			this._variableNames = new Array();
			this._variables = new Dictionary();
			this._loader = new CoreURLLoader(null, URLLoaderDataFormat.TEXT, false);
			this.requestHeaders = new Array();
		}

		/**
		 * Start uploading data to specified path
		 *
		 * @param path The server script path
		 * @param async Set to true if you are uploading huge amount of data
		 */
		public function load(path:String, async:Boolean = false):void
		{
			if (path == null || path == '')
			{
				throwError(new IllegalOperationError('You cant load without specifing PATH'));
				return;
			}

			this._path = path;
			this._async = async;

			if (this._async)
			{
				if (!this._prepared)
				{
					this.constructPostDataAsync();
				}
				else
				{
					this.doSend();
				}
			}
			else
			{
				this._data = constructPostData();
				this.doSend();
			}
		}

		/**
		 * Start uploading data after async prepare
		 */
		public function startLoad():void
		{
			if (this._path == null || this._path == '' || this._async == false )
			{
				throwError(new IllegalOperationError('You can use this method only if loading asynchronous.'));
				return;
			}
			if (!this._prepared && this._async )
			{
				throwError(new IllegalOperationError('You should prepare data before sending when using asynchronous.'));
				return;
			}

			this.doSend();
		}

		/**
		 * Prepare data before sending (only if you use asynchronous)
		 */
		public function prepareData():void
		{
			this.constructPostDataAsync();
		}

		/**
		 * Stop loader action
		 */
		public function close():void
		{
			try
			{
				this._loader.close();
			}
			catch( e:Error )
			{
			}
		}

		/**
		 * Add string variable to loader
		 * If you have already added variable with the same name it will be overwritten
		 *
		 * @param name Variable name
		 * @param value Variable value
		 */
		public function addVariable(name:String, value:* = '', contentType:String = ''):void
		{
			if (_variableNames.indexOf(name) == -1)
			{
				_variableNames.push(name);
				_variables[name] = new VariablePart(name, String(value), contentType);
			}
			else
			{
				var v:VariablePart =_variables[name] as VariablePart;
				v.value = value;
				v.contentType = contentType;
			}
			
			_prepared = false;
		}

		/**
		 * Add file part to loader
		 * If you have already added file with the same fileName it will be overwritten
		 *
		 * @param	fileContent	File content encoded to ByteArray
		 * @param	fileName	Name of the file
		 * @param	dataField	Name of the field containg file data
		 * @param	contentType	MIME type of the uploading file
		 */
		public function addFile(fileContent:ByteArray, fileName:String, dataField:String = 'Filedata', contentType:String = 'application/octet-stream'):void
		{
			if (_fileNames.indexOf(fileName) == -1)
			{
				_fileNames.push(fileName);
				_files[fileName] = new FilePart(fileContent, fileName, dataField, contentType);
				totalFilesSize += fileContent.length;
			}
			else
			{
				var f:FilePart = _files[fileName] as FilePart;
				totalFilesSize -= f.fileContent.length;
				f.fileContent = fileContent;
				f.fileName = fileName;
				f.dataField = dataField;
				f.contentType = contentType;
				totalFilesSize += fileContent.length;
			}

			_prepared = false;
		}

		/**
		 * Remove all variable parts
		 */
		public function clearVariables():void
		{
			_variableNames = new Array();
			_variables = new Dictionary();
			_prepared = false;
		}

		/**
		 * Remove all file parts
		 */
		public function clearFiles():void
		{
			for each (var name:String in _fileNames)
			{
				(_files[name] as FilePart).dispose();
			}
			_fileNames = new Array();
			_files = new Dictionary();
			totalFilesSize = 0;
			_prepared = false;
		}

		/**
		 * Generate random boundary
		 * @return	Random boundary
		 */
		public function getBoundary():String
		{
			if (_boundary == null)
			{
				_boundary = '';
				for (var i:int = 0; i < 0x20; i++ )
				{
					_boundary += String.fromCharCode(int(97 + Math.random() * 25));
				}
			}
			return _boundary;
		}

		public function get ASYNC():Boolean
		{
			return _async;
		}

		public function get PREPARED():Boolean
		{
			return _prepared;
		}

		public function get dataFormat():String
		{
			return _loader.dataFormat;
		}

		public function set dataFormat(format:String):void
		{
			if (format != URLLoaderDataFormat.BINARY && format != URLLoaderDataFormat.TEXT && format != URLLoaderDataFormat.VARIABLES)
			{
				throwError(new IllegalOperationError('Illegal URLLoader Data Format'));
				return;
			}
			this._loader.dataFormat = format;
		}

		public function get loader():URLLoader
		{
			return this._loader;
		}
		
		public function get urlRequestMethod():String
		{
			return this._urlRequestMethod;
		}

		public function set urlRequestMethod(value:String):void
		{
			this._urlRequestMethod = value;
		}

		private function doSend():void
		{
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.url = this._path;
			urlRequest.method = this._urlRequestMethod;
			urlRequest.data = this._data;

			urlRequest.requestHeaders.push(new URLRequestHeader('Content-type', 'multipart/form-data; boundary=' + this.getBoundary()));

			if (requestHeaders.length)
			{
				urlRequest.requestHeaders = urlRequest.requestHeaders.concat(this.requestHeaders);
			}

			this.addListener();

			this._loader.load(urlRequest);
		}

		private function constructPostDataAsync():void
		{
			if (this._asyncWriteTimeoutId)
			{
				this._asyncWriteTimeoutId.destruct();
				this._asyncWriteTimeoutId = null;
			}

			_data = new ByteArray();
			_data.endian = Endian.BIG_ENDIAN;

			_data = constructVariablesPart(_data);

			_asyncFilePointer = 0;
			_writtenBytes = 0;
			_prepared = false;
			if (_fileNames.length)
			{
				nextAsyncLoop();
			}
			else
			{
				_data = closeDataObject(_data);
				_prepared = true;
				dispatchEvent(new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_COMPLETE));
			}
		}

		private function constructPostData():ByteArray
		{
			var postData:ByteArray = new ByteArray();
			postData.endian = Endian.BIG_ENDIAN;

			postData = constructVariablesPart(postData);
			postData = constructFilesPart(postData);

			postData = closeDataObject(postData);

			return postData;
		}

		private function closeDataObject(postData:ByteArray):ByteArray
		{
			postData = BOUNDARY(postData);
			postData = DOUBLEDASH(postData);
			return postData;
		}

		private function constructVariablesPart(postData:ByteArray):ByteArray
		{
			var i:uint;
			var bytes:String;

			for each (var name:String in this._variableNames)
			{
				postData = BOUNDARY(postData);
				postData = LINEBREAK(postData);
				bytes = 'Content-Disposition: form-data; name="' + name + '"';
				for ( i = 0; i < bytes.length; i++ )
				{
					postData.writeByte(bytes.charCodeAt(i));
				}
				if (VariablePart(this._variables[name]).contentType != '' && VariablePart(this._variables[name]).contentType != null)
				{
					postData = LINEBREAK(postData);
					bytes = 'Content-Type: ' + VariablePart(this._variables[name]).contentType;
					for ( i = 0; i < bytes.length; i++ )
					{
						postData.writeByte(bytes.charCodeAt(i));
					}
				}
				postData = LINEBREAK(postData);
				postData = LINEBREAK(postData);
				postData.writeUTFBytes(VariablePart(this._variables[name]).value || "");
				postData = LINEBREAK(postData);
			}

			return postData;
		}

		private function constructFilesPart(postData:ByteArray):ByteArray
		{
			var i:uint;

			if (this._fileNames.length)
			{
				for each (var name:String in this._fileNames)
				{
					postData = getFilePartHeader(postData, this._files[name] as FilePart);
					postData = getFilePartData(postData, this._files[name] as FilePart);

					if (i != this._fileNames.length - 1)
					{
						postData = LINEBREAK(postData);
					}
					i++;
				}
				postData = closeFilePartsData(postData);
			}

			return postData;
		}

		private function closeFilePartsData(postData:ByteArray):ByteArray
		{
			var i:uint;
			var bytes:String;

			postData = LINEBREAK(postData);
			postData = BOUNDARY(postData);
			postData = LINEBREAK(postData);
			bytes = 'Content-Disposition: form-data; name="Upload"';
			for ( i = 0; i < bytes.length; i++ )
			{
				postData.writeByte(bytes.charCodeAt(i));
			}
			postData = LINEBREAK(postData);
			postData = LINEBREAK(postData);
			bytes = 'Submit Query';
			for ( i = 0; i < bytes.length; i++ )
			{
				postData.writeByte(bytes.charCodeAt(i));
			}
			postData = LINEBREAK(postData);

			return postData;
		}

		private function getFilePartHeader(postData:ByteArray, part:FilePart):ByteArray
		{
			var i:uint;
			var bytes:String;

			postData = BOUNDARY(postData);
			postData = LINEBREAK(postData);
			bytes = 'Content-Disposition: form-data; name="Filename"';
			for ( i = 0; i < bytes.length; i++ )
			{
				postData.writeByte(bytes.charCodeAt(i));
			}
			postData = LINEBREAK(postData);
			postData = LINEBREAK(postData);
			postData.writeUTFBytes(part.fileName);
			postData = LINEBREAK(postData);

			postData = BOUNDARY(postData);
			postData = LINEBREAK(postData);
			bytes = 'Content-Disposition: form-data; name="' + part.dataField + '"; filename="';
			for ( i = 0; i < bytes.length; i++ )
			{
				postData.writeByte(bytes.charCodeAt(i));
			}
			postData.writeUTFBytes(part.fileName);
			postData = QUOTATIONMARK(postData);
			postData = LINEBREAK(postData);
			bytes = 'Content-Type: ' + part.contentType;
			for ( i = 0; i < bytes.length; i++ )
			{
				postData.writeByte(bytes.charCodeAt(i));
			}
			postData = LINEBREAK(postData);
			postData = LINEBREAK(postData);

			return postData;
		}

		private function getFilePartData(postData:ByteArray, part:FilePart):ByteArray
		{
			postData.writeBytes(part.fileContent, 0, part.fileContent.length);

			return postData;
		}

		private function handleProgress(event:ProgressEvent):void
		{
			this.dispatchEvent(event);
		}

		private function handleComplete(event:Event):void
		{
			this.removeListener();
			this.dispatchEvent(event);
		}

		private function handleIOError(event:IOErrorEvent):void
		{
			this.removeListener();
			this.dispatchEvent(event);
		}

		private function handleSecurityError(event:SecurityErrorEvent):void
		{
			this.removeListener();
			this.dispatchEvent(event);
		}

		private function handleHTTPStatus(event:HTTPStatusEvent):void
		{
			this.dispatchEvent(event);
		}

		private function addListener():void
		{
			this._loader.addEventListener(Event.COMPLETE, this.handleComplete);
			this._loader.addEventListener(ProgressEvent.PROGRESS, this.handleProgress);
			this._loader.addEventListener(IOErrorEvent.IO_ERROR, this.handleIOError);
			this._loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.handleHTTPStatus);
			this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleSecurityError);
		}

		private function removeListener():void
		{
			this._loader.removeEventListener(Event.COMPLETE, this.handleComplete);
			this._loader.removeEventListener(ProgressEvent.PROGRESS, this.handleProgress);
			this._loader.removeEventListener(IOErrorEvent.IO_ERROR, this.handleIOError);
			this._loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, this.handleHTTPStatus);
			this._loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleSecurityError);
		}

		private function BOUNDARY(p:ByteArray):ByteArray
		{
			var l:int = getBoundary().length;
			p = DOUBLEDASH(p);
			for (var i:int = 0; i < l; i++ )
			{
				p.writeByte(_boundary.charCodeAt(i));
			}
			return p;
		}

		private function LINEBREAK(p:ByteArray):ByteArray
		{
			p.writeShort(0x0d0a);
			return p;
		}

		private function QUOTATIONMARK(p:ByteArray):ByteArray
		{
			p.writeByte(0x22);
			return p;
		}

		private function DOUBLEDASH(p:ByteArray):ByteArray
		{
			p.writeShort(0x2d2d);
			return p;
		}

		private function nextAsyncLoop():void
		{
			var fp:FilePart;

			if (this._asyncFilePointer < this._fileNames.length)
			{
				fp = this._files[this._fileNames[this._asyncFilePointer]] as FilePart;
				this._data = this.getFilePartHeader(this._data, fp);

				this._asyncWriteTimeoutId = new TimeOut(writeChunkLoop, 10, [this._data, fp.fileContent, 0]);

				this._asyncFilePointer++;
			}
			else
			{
				this._data = this.closeFilePartsData(this._data);
				this._data = this.closeDataObject(this._data);

				this._prepared = true;

				this.dispatchEvent(new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_PROGRESS, this.totalFilesSize, this.totalFilesSize));
				this.dispatchEvent(new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_COMPLETE));
			}
		}

		private function writeChunkLoop(dest:ByteArray, data:ByteArray, p:uint = 0):void
		{
			var len:uint = Math.min(BLOCK_SIZE, data.length - p);
			dest.writeBytes(data, p, len);

			if (len < BLOCK_SIZE || p + len >= data.length)
			{
				// Finished writing file bytearray
				dest = LINEBREAK(dest);
				this.nextAsyncLoop();
				return;
			}

			p += len;
			this._writtenBytes += len;
			if (this._writtenBytes % BLOCK_SIZE * 2 == 0 )
			{
				this.dispatchEvent(new MultipartURLLoaderEvent(MultipartURLLoaderEvent.DATA_PREPARE_PROGRESS, _writtenBytes, totalFilesSize));
			}

			this._asyncWriteTimeoutId = new TimeOut(writeChunkLoop, 10, [dest, data, p]);
		}

		override public function destruct():void
		{
			if (this._asyncWriteTimeoutId)
			{
				this._asyncWriteTimeoutId.destruct();
				this._asyncWriteTimeoutId = null;
			}

			this.close();

			if (this._loader)
			{
				this._loader.destruct();
				this._loader = null;
			}

			this._boundary = null;
			this._variableNames = null;
			this._variables = null;
			this._fileNames = null;
			this._files = null;
			this.requestHeaders = null;
			this._data = null;

			super.destruct();
		}
	}
}
import flash.utils.ByteArray;

internal class FilePart
{
	public var fileContent:flash.utils.ByteArray;
	public var fileName:String;
	public var dataField:String;
	public var contentType:String;

	public function FilePart(fileContent:flash.utils.ByteArray, fileName:String, dataField:String = 'Filedata', contentType:String = 'application/octet-stream')
	{
		this.fileContent = fileContent;
		this.fileName = fileName;
		this.dataField = dataField;
		this.contentType = contentType;
	}

	public function dispose():void
	{
		this.fileContent = null;
		this.fileName = null;
		this.dataField = null;
		this.contentType = null;
	}
}
internal class VariablePart
{
	public var name:String;
	public var value:*;
	public var contentType:String;

	public function VariablePart(name:String, value:*, contentType:String = '')
	{
		this.name = name;
		this.value = value;
		this.contentType = contentType;
	}

	public function dispose():void
	{
		this.name = null;
		this.value = null;
		this.contentType = null;
	}
}