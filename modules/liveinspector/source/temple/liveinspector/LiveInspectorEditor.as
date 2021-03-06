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

package temple.liveinspector
{
	import temple.utils.DefinitionProvider;
	import temple.utils.Enum;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;

	/**
	 * @author	Mark Knol [mediamonks]
	 */
	internal class LiveInspectorEditor extends TextField
	{
		private static const _propertyClassTypeMappings:Object = 
		{
			"flash.display.Stage":
			{
				"quality":"flash.display.StageQuality", 
				"align":"flash.display.StageAlign",
				"scaleMode":"flash.display.StageScaleMode",
				"displayState":"flash.display.StageDisplayState"
			},
			"flash.display.DisplayObject":
			{
				"blendMode":"flash.display.BlendMode"
			},
			"flash.text.TextField":
			{
				"autoSize":"flash.text.TextFieldAutoSize",
				"antiAliasType":"flash.text.AntiAliasType",
				"type":"flash.text.TextFieldType",
				"gridFitType":"flash.text.GridFitType"
			}
		};
		
		private var _scope:Object;
		private var _propertyName:*;
		private var _typeOfProperty:String;

		public function LiveInspectorEditor(scope:Object, propertyName:*, typeOfProperty:String, color:uint)
		{
			_typeOfProperty = typeOfProperty;
			_propertyName = propertyName;
			_scope = scope;
			
			type = TextFieldType.INPUT;
			defaultTextFormat = LiveInspector.THEME_EDITOR_TEXTFORMAT;
			filters = [new GlowFilter(color, .1, 5, 5, 2, 3)];
			
			background = true;
			backgroundColor = LiveInspector.THEME_BACKGROUND_COLOR;

			border = true;
			borderColor = LiveInspector.THEME_BORDER_COLOR;
			
			addEventListener(Event.CHANGE, handleValueChange, false, 0, true);
			addEventListener(KeyboardEvent.KEY_DOWN, handleKeyPress, false, 0, true);
			addEventListener(MouseEvent.MOUSE_WHEEL, handleScrollWheel, false, 0, true);
			
			switch (_typeOfProperty)
			{
				case 'int':
				{
					restrict = "0-9-";
					break;
				}
				case 'uint':
				{
					restrict = "0-9";
					break;
				}
				case 'Number':
				{
					restrict = "0-9-.";
					break;
				}
				case 'Boolean':
				{
					restrict = "falsetru";
					break;
				}
			}
		}
		
		private function handleScrollWheel(event:MouseEvent):void
		{
			var value:* = _scope[_propertyName];
			
			try
			{
				switch (_typeOfProperty)
				{
					case 'Number':
					{
						if (_scope[_propertyName] < 1 && _scope[_propertyName] > -1)
						{
							_scope[_propertyName] += event.delta > 0 ? .1 : -.1;
						}
						else
						{
							_scope[_propertyName] += event.delta;
						}
						break;
					}
					case 'int':
					case 'uint':
					{
						_scope[_propertyName] += event.delta;
						break;
					}
					case 'Boolean':
					{
						_scope[_propertyName] = !value;
						break;
					}
					case 'String':
					{
						_scope[_propertyName] = getSpecialStringValue(event.delta > 0 ? 1 : -1, value);
						break;
					}
				}
			}
			catch(e:Error)
			{
			}
		}
		
		private function handleKeyPress(event:KeyboardEvent):void
		{
			var value:* = _scope[_propertyName];
			
			if (event.keyCode === Keyboard.UP || event.keyCode === Keyboard.DOWN)
			{
				try
				{
					var amount:Number = (event.keyCode === Keyboard.UP) ? 1 : -1;
					switch (_typeOfProperty)
					{
						case 'Number':
						{
							if (_scope[_propertyName] < 1 && _scope[_propertyName] > -1)
							{
								_scope[_propertyName] += amount * .1;
							}
							else
							{
								_scope[_propertyName] += amount;
							}
							break;
						}
						case 'int':
						case 'uint':
						{
							_scope[_propertyName] += amount;
							break;
						}
						case 'Boolean':
						{
							_scope[_propertyName] = !value;
							break;
						}
						case 'String':
						{
							_scope[_propertyName] = getSpecialStringValue(amount, value);
							break;
						}
					}
				}
				catch(e:Error)
				{
				}
			}
		}

		private function handleValueChange(event:Event):void
		{
			var scope:* = _scope;
			
			if (scope && "isDestructed" in scope && scope.isDestructed)
			{
				scope = null;
			}
			
			if (scope && _propertyName in scope) 
			{
				try
				{
					var text:String = TextField(event.currentTarget).text;
					switch (_typeOfProperty)
					{
						case 'Number':
						{
							scope[_propertyName] = Number(text);
							break;
						}
						case 'uint':
						{
							scope[_propertyName] = uint(text);
							break;
						}
						case 'int':
						{
							scope[_propertyName] = int(text);
							break;
						}
						case 'Boolean':
						{
							scope[_propertyName] = (text === "true");
							break;
						}
						case 'String':
						{
							scope[_propertyName] = text;
							break;
						}
					}
				}
				catch(e:Error)
				{
				}
			}
		}
		
		private function getSpecialStringValue(amount:int, value:String):String
		{
			for (var key:String in _propertyClassTypeMappings)
			{
				var classPropertyNames:Object = _propertyClassTypeMappings[key];
				if (DefinitionProvider.hasDefinition(key))
				{
					if (_propertyName in classPropertyNames)
					{
						var mappedClassName:String = classPropertyNames[_propertyName];
						if (DefinitionProvider.hasDefinition(mappedClassName))
						{
							return iterateOnClassType(amount, DefinitionProvider.getDefinition(mappedClassName), value);
						}
					}
				}
			}
			return value;
		}
		
		private function iterateOnClassType(amount:int, ClassName:Class, value:String):String
		{
			var list:Array = Enum.getArray(ClassName);
			var currentIndex:int = list.indexOf(value);
			var nextIndex:int = currentIndex + amount;
			
			if (nextIndex < 0) nextIndex = list.length - 1;
			else if (nextIndex >= list.length) nextIndex = 0;
			return list[nextIndex];
		}
	}
}
