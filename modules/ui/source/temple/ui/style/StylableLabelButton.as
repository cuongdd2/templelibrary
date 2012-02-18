/*
 *	 
 *	Temple Library for ActionScript 3.0
 *	Copyright © 2012 MediaMonks B.V.
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

package temple.ui.style 
{
	import temple.core.errors.TempleArgumentError;
	import temple.core.errors.throwError;
	import temple.ui.buttons.LabelButton;
	import temple.ui.label.IHTMLLabel;
	import temple.ui.label.ITextFieldLabel;
	import temple.ui.label.TextFieldLabelBehavior;
	import temple.utils.types.DisplayObjectContainerUtils;
	import temple.utils.types.StringUtils;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;

	/**
	 * Dispatched after the text in the TextField is changed
	 * Event will also be dispatched from the TextField
	 * @eventType flash.events.Event.CHANGE
	 */
	[Event(name = "change", type = "flash.events.Event")]

	/**
	 * Dispatched after size of the TextField is changed
	 * Event will also be dispatched from the TextField
	 * @eventType flash.events.Event.RESIZE
	 */
	[Event(name = "resize", type = "flash.events.Event")]
	
	/**
	 * A StylableLabelButton is a <code>LabelButton</code> which can be styled using CSS.
	 * 
	 * <p>The Temple knows different kinds of buttons. Check out the 
	 * <a href="http://templelibrary.googlecode.com/svn/trunk/modules/ui/readme.html" target="_blank">button schema</a>
	 * in the UI Module of the Temple for a list of all available buttons which their features. </p>
	 * 
	 * @see temple.ui.buttons.LabelButton
	 * @see temple.ui.style.StyleManager
	 * @see temple.ui.buttons.behaviors.ButtonBehavior
	 * @see ../../../../readme.html
	 * 
	 * @author Thijs Broerse
	 */
	public class StylableLabelButton extends LabelButton implements IStylableLabel
	{
		private var _cssClass:String;
		private var _styleSheetName:String;
		private var _antiAlias:String;
		private var _textTransform:String = TextTransform.NONE;
		
		// indicates if the style should be reset after a label change
		protected var _resetStyle:Boolean;
		
		public function StylableLabelButton()
		{
			super();
		}

		override protected function init(textField:TextField = null):void
		{
			if (!textField) textField = DisplayObjectContainerUtils.findChildOfType(this, TextField) as TextField;
				
			var newTextField:TextField = new TextField();
			
			if (textField)
			{
				// if there was a TextField copy it's values
				var index:uint = this.getChildIndex(textField);
				
				newTextField.multiline = textField.multiline;
				newTextField.selectable = textField.selectable;
				newTextField.sharpness = textField.sharpness;
				newTextField.textColor = textField.textColor;
				newTextField.thickness = textField.thickness;
				newTextField.type = textField.type;
				newTextField.wordWrap = textField.wordWrap;
				newTextField.width = textField.width;
				newTextField.height = textField.height;
				newTextField.x = textField.x;
				newTextField.y = textField.y;
				newTextField.filters = textField.filters;
				
				// hide textField (we can't remove it, it will be back everytime we are on frame 1)
				textField.visible = false;
				textField.text = '';
				textField.width = textField.height = 1;

				this.addChildAt(newTextField, index);
			}
			else
			{
				this.addChild(newTextField);
			}

			this._label = new TextFieldLabelBehavior(newTextField);
			(this._label as IHTMLLabel).html = true;
			(this._label as IEventDispatcher).addEventListener(Event.CHANGE, this.handleLabelChange);
		}

		/**
		 * @inheritDoc
		 */
		public function get cssClass():String
		{
			return this._cssClass;
		}
		
		/**
		 * @inheritDoc
		 */
		[Inspectable(name="CSS Class", type="String")]
		public function set cssClass(value:String):void
		{
			this._cssClass = value;
			StyleManager.getInstance().addTextField((this._label as ITextFieldLabel).textField, this._cssClass, this._styleSheetName);
			StyleManager.getInstance().addObject(this, this._cssClass, this._styleSheetName);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get styleSheetName():String
		{
			return this._styleSheetName;
		}
		
		/**
		 * @inheritDoc
		 */
		[Inspectable(name="StyleSheet name", type="String")]
		public function set styleSheetName(value:String):void
		{
			this._styleSheetName = value;
			StyleManager.getInstance().addTextField((this._label as ITextFieldLabel).textField, this._cssClass, this._styleSheetName);
			StyleManager.getInstance().addObject(this, this._cssClass, this._styleSheetName);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get textTransform():String
		{
			return this._textTransform;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set textTransform(value:String):void
		{
			this._resetStyle = false;
			switch (value)
			{
				case null:
				case TextTransform.NONE:
				{
					this._textTransform = TextTransform.NONE;
					// do nothing
					break;
				}
				case TextTransform.UCFIRST:
				{
					this._textTransform = value;
					this.label = StringUtils.ucFirst(this.label);
					break;
				}
				case TextTransform.LOWERCASE:
				{
					this._textTransform = value;
					this.label = this.label.toLowerCase();
					break;
				}
				case TextTransform.UPPERCASE:
				{
					this._textTransform = value;
					this.label = this.label.toUpperCase();
					break;
				}	
				case TextTransform.CAPITALIZE:
				{
					this._textTransform = value;
					this.label = StringUtils.capitalize(this.label);
					break;
				}
				default:
				{
					throwError(new TempleArgumentError(this, "invalid value for textTransform '" + value + "'"));
					break;
				}
			}
			this._resetStyle = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get antiAlias():String
		{
			return this._antiAlias;
		}
		
		/**
		 * @inheritDoc
		 */
		[Inspectable(name="Anti-alias", type="String", defaultValue="please choose...", enumeration="please choose...,animation,readability")]
		public function set antiAlias(value:String):void
		{
			switch (value)
			{
				case AntiAlias.ANIMATION:
				{
					this._antiAlias = value;
					(this._label as ITextFieldLabel).textField.antiAliasType = AntiAliasType.NORMAL;
					(this._label as ITextFieldLabel).textField.gridFitType = GridFitType.NONE;
					break;
				}
				case AntiAlias.READABILITY:
				{
					this._antiAlias = value;
					
					if ((this._label as ITextFieldLabel).textField.getTextFormat().size >= StyleManager.LARGE_FONT_SIZE)
					{
						(this._label as ITextFieldLabel).textField.antiAliasType = AntiAliasType.NORMAL;
					}
					else
					{
						(this._label as ITextFieldLabel).textField.antiAliasType = AntiAliasType.ADVANCED;
					}
					
					switch ((this._label as ITextFieldLabel).textField.getTextFormat().align)
					{
						case TextFormatAlign.LEFT:
						{
							ITextFieldLabel(this._label).textField.gridFitType = GridFitType.PIXEL;
							break;
						}
						case TextFormatAlign.CENTER:
						case TextFormatAlign.JUSTIFY:
						case TextFormatAlign.RIGHT:
						{
							ITextFieldLabel(this._label).textField.gridFitType = GridFitType.SUBPIXEL;
							break;
						}
					}
					break;
				}
				default:
				{
					throwError(new TempleArgumentError(this, "invalid value for antiAlias: '" + value + "'"));
					break;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get multiline():Boolean
		{
			return (this._label as ITextFieldLabel).textField.multiline;
		}
		
		/**
		 * @inheritDoc
		 */
		[Inspectable(name="Multiline", type="Boolean")]
		public function set multiline(value:Boolean):void
		{
			(this._label as ITextFieldLabel).textField.multiline = value;
		}

		private function handleLabelChange(event:Event):void
		{
			if (this._resetStyle) this.resetStyle();
		}

		protected function resetStyle():void
		{
			this.textTransform = this._textTransform;
		}

		override public function destruct():void
		{
			if (this._label && this._label is IEventDispatcher) (this._label as IEventDispatcher).removeEventListener(Event.CHANGE, this.handleLabelChange);
			
			super.destruct();
		}
	}
}
