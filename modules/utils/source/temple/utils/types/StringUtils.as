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

package temple.utils.types 
{
	import temple.core.debug.log.Log;
	import temple.core.debug.objectToString;
	import temple.core.errors.TempleArgumentError;
	import temple.core.errors.throwError;

	/**
	 * This class contains some functions for Strings.
	 * 
	 * @author Arjan van Wijk, Thijs Broerse
	 */
	public final class StringUtils 
	{
		/**
		 * Repeats a string
		 * @param string the string to repeat
		 * @param amount how many times the string should be repeated
		 * 
		 * @example
		 * <listing version="3.0">
		 * var string:String = "abc";
		 * var result:String = StringUtils.repeat(string, 3);
		 * trace(result); // abcabcabc
		 * </listing>
		 */
		public static function repeat(string:String, amount:int):String
		{
			var ret:String = '';
			for (var i:int = 0;i < amount;i++)
			{
				ret += string;
			}
			return ret;
		}

		/**
		 * Add a character to the left of a string till it has a specified length
		 * @param string the original string
		 * @param length the length of the result string
		 * @param fillChar the character that need the be attached to the left of string
		 * 
		 * @example
		 * <listing version="3.0">
		 * var string:String = "1";
		 * var result:String = StringUtils.padLeft(string, 3, "0");
		 * trace(result); // 001
		 * </listing>
		 */
		public static function padLeft(string:String, length:int, fillChar:String = ' '):String
		{
			if (fillChar == null || fillChar.length == 0) throwError(new TempleArgumentError(StringUtils, "invalid value for fillChar: '" + fillChar + "'"));
			
			if (string.length < length)
			{
				var lim:int = length - string.length;
				for (var i:int = 0; i < lim;i++)
				{
					string = fillChar + string;
				}
			}
			return string;
		}

		/**
		 * Add a character to the right of a string till it has a specified length
		 * @param string the original string
		 * @param length the length of the result string
		 * @param fillChar the character that need the be attached to the right of string
		 * 
		 * @example
		 * <listing version="3.0">
		 * var string:String = "1";
		 * var result:String = StringUtils.padRight(string, 3, "0");
		 * trace(result); // 100
		 * </listing>
		 */
		public static function padRight(string:String, length:int, fillChar:String = ' '):String
		{
			if (string.length < length)
			{
				var lim:int = length - string.length;
				for (var i:int = 0; i < lim;i++)
				{
					string += fillChar;
				}
			}
			return string;
		}

		/**
		 * replaces all tabs, newlines spaces to just one space
		 * Works the same as ignore whitespace for XML 
		 */
		public static function ignoreWhiteSpace(string:String):String
		{
			return string.replace(/[\t\r\n]|\s\s/g, "");
		}

		/**
		 * Does a case insensitive compare or two strings and returns true if they are equal.
		 * @param string1 The first string to compare.
		 * @param s2 The second string to compare.
		 * @param An optional boolean indicating if the equal is case sensitive. Default is true.
		 * @return A boolean value indicating whether the strings' values are equal in a case sensitive compare.	
		 */			
		public static function stringsAreEqual(string1:String, string2:String, caseSensitive:Boolean = true):Boolean
		{
			if (caseSensitive)
			{
				return (string1 == string2);
			}
			else
			{
				return (string1.toUpperCase() == string2.toUpperCase());
			}
		}

		/**
		 * Removes whitespace from the front and the end of the specified string.
		 * @param string The String whose beginning and ending whitespace will be removed.
		 * @return A String with whitespace removed from the begining and end	
		 */			
		public static function trim(string:String):String
		{
			return StringUtils.ltrim(StringUtils.rtrim(string));
		}

		/**
		 * Removes whitespace from the front of the specified string.
		 * @param string The String whose beginning whitespace will will be removed.
		 * @return A String with whitespace removed from the begining	
		 */	
		public static function ltrim(string:String):String
		{
			var size:int = string.length;
			for (var i:int = 0;i < size;i++)
			{
				if (string.charCodeAt(i) > 32)
				{
					return string.substring(i);
				}
			}
			return "";
		}

		/**
		 * Removes whitespace from the end of the specified string.
		 * @param string The String whose ending whitespace will will be removed.
		 * @return A String with whitespace removed from the end	
		 */	
		public static function rtrim(string:String):String
		{
			var size:int = string.length;
			for (var i:int = size;i > 0;i--)
			{
				if (string.charCodeAt(i - 1) > 32)
				{
					return string.substring(0, i);
				}
			}

			return "";
		}

		/**
		 * Determines whether the specified string begins with the spcified prefix.
		 * @param string The string that the prefix will be checked against.
		 * @param prefix The prefix that will be tested against the string.
		 * @return true if the string starts with the prefix, false if it does not.
		 */	
		public static function beginsWith(string:String, prefix:String):Boolean
		{			
			return (prefix == string.substring(0, prefix.length));
		}	

		/**
		 * Determines whether the specified string ends with the spcified suffix.
		 * @param string The string that the suffic will be checked against.
		 * @param prefix The suffic that will be tested against the string.
		 * @return true if the string ends with the suffix, false if it does not.
		 */	
		public static function endsWith(string:String, suffix:String):Boolean
		{
			return (suffix == string.substring(string.length - suffix.length));
		}	

		/**
		 * Removes all instances of the remove string in the input string.
		 * @param string The string that will be checked for instances of remove
		 * @param remove The string that will be removed from the input string.
		 * @param caseSensitive An optional boolean indicating if the replace is case sensitive. Default is true.
		 */
		public static function remove(string:String, remove:String, caseSensitive:Boolean = true):String
		{
			if (string == null) return '';
			var rem:String = StringUtils.escapePattern(remove);
			var flags:String = (!caseSensitive) ? 'ig' : 'g';
			return string.replace(new RegExp(rem, flags), '');
		}

		private static function escapePattern(pattern:String):String 
		{
			return pattern.replace(/(\]|\[|\{|\}|\(|\)|\*|\+|\?|\.|\\)/g, '\\$1');
		}
		
		/**
		 * Escapes a UTF-8 string to unicode; e.g. "é" -> "\u00e9"
		 * @param input The string to be escaped
		 * @return An escaped UTF-8 String
		 */
		public static function escapeToUnicode(input:String):String
		{
			var inputCopy:String = input;
			var escapedInput:String;
			for (var i:int=0; i<inputCopy.length; i++)
			{
				escapedInput += StringUtils.escapeToUnicodeChar(inputCopy.substr(i,1));
			}
			return escapedInput;
		}
		
		/**
		 * Escapes a UTF-8 character to unicode; e.g. "é" -> "\u00e9"
		 * @param inputChar The character to be escaped
		 * @return An escaped UTF-8 String
		 */
		public static function escapeToUnicodeChar(inputChar:String):String
		{
			if (inputChar < ' ' || inputChar > '}')
			{
				// get the hex digit(s) of the character (either 1 or 2 digits)
				var hexCode:String = inputChar.charCodeAt(0).toString(16);
				
				// ensure that there are 4 digits by adjusting
				// the # of zeros accordingly.
				while (hexCode.length < 4) hexCode = "0" + hexCode;
				
				// create the unicode escape sequence with 4 hex digits
				return "\\u" + hexCode;
			}
			else
			{
				return inputChar;
			}
		}
		
		/**
		 * Replaces all instances of the replace string in the input string with the replaceWith string.
		 * @param string The string that instances of replace string will be replaces with removeWith string.
		 * @param replace The string that will be replaced by instances of the replaceWith string.
		 * @param replaceWith The string that will replace instances of replace string.
		 * @return A new String with the replace string replaced with the replaceWith string.
		 */
		public static function replace(string:String, replace:String, replaceWith:String):String
		{
			var sb:String = new String();
			var found:Boolean = false;

			var sLen:Number = string.length;
			var rLen:Number = replace.length;

			for (var i:Number = 0;i < sLen;i++)
			{
				if (string.charAt(i) == replace.charAt(0))
				{   
					found = true;
					for (var j:Number = 0;j < rLen;j++)
					{
						if (!(string.charAt(i + j) == replace.charAt(j)))
						{
							found = false;
							break;
						}
					}

					if (found)
					{
						sb += replaceWith;
						i = i + (rLen - 1);
						continue;
					}
				}
				sb += string.charAt(i);
			}
			return sb;
		}

		/**
		 * Replaces vars in a String. Vars defined between {}: '{var}'. The var can be prefix with an (optional) $.
		 * Searches for a value in de object with the same name as the var.
		 * 
		 * @param string the String containing variable which must be replaced
		 * @param object an object containing all the properties for the replacement (as name-value pair)
		 * @param keepIrreplaceableVars a Boolean which indicates if variables which can not be replaced should be
		 * removed (false) or should be kept (true) in the string
		 * @param debug if set true the replacement will not be executed in a try-catch statement.
		 * 
		 * @example
		 * <listing version="3.0">
		 * trace(StringUtils.replaceVars("hi, my name is {name}", {name:'Thijs'})); // hi, my name is Thijs
		 * </listing>
		 * 
		 * @example Since the '$' prefix is optional, the following example will have the same result
		 * <listing version="3.0">
		 * trace(StringUtils.replaceVars("hi, my name is ${name}", {name:'Thijs'})); // hi, my name is Thijs
		 * </listing>
		 */
		public static function replaceVars(string:String, object:Object, keepIrreplaceableVars:Boolean = true, debug:Boolean = false):String
		{
			if (string == null) throwError(new TempleArgumentError(StringUtils, "String can not be null"));
			if (object == null) throwError(new TempleArgumentError(StringUtils, "Object can not be null"));
			
			return string.replace(/\$?\{([@#$%&\w]*)(\((.*?)\))?\}/gi, function ():String
			{
				var prop:String = arguments[1];
				if (object != null && prop in object)
				{
					if (object[prop] is Function && arguments[2])
					{
						if (arguments[3])
						{
							var args:Array = String(arguments[3]).split(",");
							for (var i:int = 0, leni:int = args.length; i < leni; i++) args[i] = StringUtils.replaceVars(args[i], object);
						}
												
						if (debug)
						{
							return (object[prop] as Function).apply(null, args);
						}
						else
						{
							try
							{
								return (object[prop] as Function).apply(null, args);
							}
							catch (error:Error)
							{
								Log.error("Unable to replace var " + arguments[0] + ": " + error.message, StringUtils);
							}
						}
					}
					else return object[prop];
				}
				if (keepIrreplaceableVars) return "{" + prop + "}";
				if (debug) return '*VALUE \'' + prop + '\' NOT FOUND*';
				return '';
			});
		}

		/**
		 * Returns everything after the first occurrence of the provided character in the string.
		 */
		public static function afterFirst(string:String, character:String):String 
		{
			if (string == null) 
			{ 
				return ''; 
			}
			var idx:int = string.indexOf(character);
			if (idx == -1) 
			{ 
				return ''; 
			}
			idx += character.length;
			return string.substr(idx);
		}

		/**
		 * Returns everything after the last occurence of the provided character in source.
		 */
		public static function afterLast(string:String, character:String):String 
		{
			if (string == null) 
			{ 
				return ''; 
			}
			var idx:int = string.lastIndexOf(character);
			if (idx == -1) 
			{ 
				return ''; 
			}
			idx += character.length;
			return string.substr(idx);
		}

		/**
		 * Returns everything before the first occurrence of the provided character in the string.
		 */
		public static function beforeFirst(string:String, character:String):String 
		{
			if (string == null) 
			{ 
				return ''; 
			}
			var characterIndex:int = string.indexOf(character);
			if (characterIndex == -1) 
			{ 
				return ''; 
			}
			return string.substr(0, characterIndex);
		}

		/**
		 * Returns everything before the last occurrence of the provided character in the string.
		 */
		public static function beforeLast(string:String, character:String):String 
		{
			if (string == null) 
			{ 
				return ''; 
			}
			var characterIndex:int = string.lastIndexOf(character);
			if (characterIndex == -1) 
			{ 
				return ''; 
			}
			return string.substr(0, characterIndex);
		}

		/**
		 * Returns everything after the first occurance of start and before the first occurrence of end in the given string.
		 */
		public static function between(string:String, start:String, end:String):String 
		{
			var str:String = '';
			if (string == null) 
			{ 
				return str; 
			}
			var startIdx:int = string.indexOf(start);
			if (startIdx != -1) 
			{
				startIdx += start.length; 
				
				var endIdx:int = string.indexOf(end, startIdx);
				if (endIdx != -1) 
				{ 
					str = string.substr(startIdx, endIdx - startIdx); 
				}
			}
			return str;
		}

		/**
		 * Utility method that intelligently breaks up your string, allowing you to create blocks of readable text.
		 * This method returns you the closest possible match to the delim paramater, while keeping the text length within the len paramter.
		 * If a match can't be found in your specified length an  '...' is added to that block, and the blocking continues untill all the text is broken apart.
		 * @param string The string to break up.
		 * @param length Maximum length of each block of text.
		 * @param delimiter delimiter to end text blocks on, default = '.'
		 */
		public static function block(string:String, length:uint, delimiter:String = "."):Array
		{
			var array:Array = new Array();
			if (string == null || !contains(string, delimiter)) return array;
			
			var chrIndex:uint = 0;
			var strLen:uint = string.length;
			var replPatt:RegExp = new RegExp("[^" + escapePattern(delimiter) + "]+$");
			while (chrIndex < strLen)
			{
				var subString:String = string.substr(chrIndex, length);
				if (!contains(subString, delimiter))
				{
					array.push(truncate(subString, subString.length));
					chrIndex += subString.length;
				}
				subString = subString.replace(replPatt, '');
				array.push(subString);
				chrIndex += subString.length;
			}
			return array;
		}

		/**
		 * Capitallizes all words in a string
		 * @param string The string.
		 * 
		 * @example
		 * <listing version="3.0">
		 * trace(StringUtils.capitalize("all words should be capitalized")); // All Words Should Be Capitalized
		 * </listing>
		 */
		public static function capitalize(string:String):String
		{
			return StringUtils.ltrim(string).replace(/^[^\s:,.\-'"]|(?<=[\s:,.\-'"])[^\s:,.\-'"]/g, function (string:String, ...args):String{ return string.toUpperCase();});
		}

		/**
		 * Returns a string with the first character of source capitalized, if that character is alphabetic.
		 */
		public static function ucFirst(string:String):String
		{
			return string ? string.substr(0, 1).toUpperCase() + string.substr(1) : null;
		}

		/**
		 * Determines whether the specified string contains any instances of char.
		 */
		public static function contains(source:String, char:String):Boolean
		{
			return source ? source.indexOf(char) != -1 : false;
		}

		/**
		 * Determines the number of times a charactor or sub-string appears within the string.
		 * @param string The string.
		 * @param char The character or sub-string to count.
		 * @param caseSensitive (optional, default is true) A boolean flag to indicate if the search is case sensitive.
		 */
		public static function countOf(string:String, char:String, caseSensitive:Boolean = true):uint 
		{
			if (string == null) 
			{ 
				return 0; 
			}
			char = escapePattern(char);
			var flags:String = (!caseSensitive) ? 'ig' : 'g';
			return string.match(new RegExp(char, flags)).length;
		}

		/**
		 * Counts the total amount of words in a text
		 * NOTE: does only work correctly for English texts
		 */
		public static function countWords(string:String):uint
		{
			if (string == null) return 0;
			return string.match(/\b\w+\b/g).length;
		}

		/**
		 * Levenshtein distance (editDistance) is a measure of the similarity between two strings. The distance is the number of deletions, insertions, or substitutions required to transform source into target.
		 */
		public static function editDistance(string:String, target:String):uint 
		{
			var i:uint;

			if (string == null) string = '';
			if (target == null) target = '';

			if (string == target) return 0;

			var d:Array = new Array();
			var cost:uint;
			var n:uint = string.length;
			var m:uint = target.length;
			var j:uint;

			if (n == 0) return m;
			if (m == 0) return n;

			for (i = 0;i <= n;i++) d[i] = new Array();
			for (i = 0;i <= n;i++) d[i][0] = i;
			for (j = 0;j <= m;j++) d[0][j] = j;

			for (i = 1;i <= n;i++)
			{
				var s_i:String = string.charAt(i - 1);
				for (j = 1;j <= m;j++) 
				{

					var t_j:String = target.charAt(j - 1);

					if (s_i == t_j) 
					{ 
						cost = 0; 
					}
					else 
					{ 
						cost = 1; 
					}

					d[i][j] = Math.min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost);
				}
			}
			return d[n][m];
		}

		/**
		 * Determines whether the specified string contains text.
		 */
		public static function hasText(string:String):Boolean
		{
			return string && StringUtils.removeExtraWhitespace(string).length;
		}

		/**
		 * Determines whether the specified string contains any characters.
		 */
		public static function isEmpty(string:String):Boolean
		{
			return !string;
		}

		/**
		 * Determines whether the specified string is numeric.
		 */
		public static function isNumeric(string:String):Boolean
		{
			if (string == null) return false;
			var regx:RegExp = /^[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?$/;
			return regx.test(string);
		}

		/**
		 * Replaces invalid HTML (for Flash) to Flash HTML
		 */
		public static function replaceHTML(string:String):String
		{
			return string.replace(/<.*?>/g, StringUtils.replaceTag);
		}

		private static function replaceTag(tag:String, ...args):String
		{
			// check tag
			switch (String(tag.match(/(?<=\<|\<\/)\w+/g)[0]).toLowerCase())
			{
				// allowed tags
				case "a":
				case "b":
				case "br":
				case "font":
				case "img":
				case "i":
				case "li":
				case "p":
				case "span":
				case "textformat":
				case "ul":
					return tag;
				
				// tags to be replaced
				case "strong":
					return tag.replace("strong", "b");
				case "em":
					return tag.replace("em", "i");
			}
			
			return '';
		}

		/**
		 * Properly cases' the string in "sentence format".
		 */
		public static function properCase(string:String):String
		{
			if (string == null) 
			{ 
				return ''; 
			}
			var str:String = string.toLowerCase().replace(/\b([^.?;!]+)/, capitalize);
			return str.replace(/\b[i]\b/, "I");
		}

		/**
		 * Escapes all of the characters in a string to create a friendly "quotable" sting
		 */
		public static function quote(string:String):String
		{
			var regx:RegExp = /[\\"\r\n]/g;
			return '"' + string.replace(regx, _quote) + '"'; //"
		}

		private static function _quote(source:String, ...args):String
		{
			switch (source)
			{
				case "\\":
					return "\\\\";
				case "\r":
					return "\\r";
				case "\n":
					return "\\n";
				case '"':
					return '\\"';
				default:
					return '';
			}
		}

		/**
		 * Removes extraneous whitespace (extra spaces, tabs, line breaks, etc) from the specified string.
		 */
		public static function removeExtraWhitespace(string:String):String
		{
			if (string == null) return '';
			var str:String = trim(string);
			return str.replace(/\s+/g, ' ');
		}

		/**
		 * Returns the specified string in reverse character order.
		 */
		public static function reverse(string:String):String
		{
			if (string == null) return '';
			return string.split('').reverse().join('');
		}

		/**
		 * Returns the specified string in reverse word order.
		 */
		public static function reverseWords(string:String):String
		{
			if (string == null) return '';
			return string.split(/\s+/).reverse().join('');
		}

		/**
		 * Determines the percentage of similarity, based on editDistance
		 */
		public static function similarity(string:String, target:String):Number 
		{
			var ed:uint = editDistance(string, target);
			var maxLen:uint = Math.max(string.length, target.length);
			if (maxLen == 0)
			{
				return 100;
			}
			else
			{
				return (1 - ed / maxLen) * 100;
			}
		}

		/**
		 * Removes all &lt; and &gt; based tags from a string
		 */
		public static function stripTags(string:String):String
		{
			if (string == null) 
			{ 
				return ''; 
			}
			return string.replace(/<\/?[^>]+>/igm, '');
		}

		/**
		 * Swaps the casing of a string.
		 */
		public static function swapCase(string:String):String
		{
			if (string == null) return '';
			return string.replace(/(\w)/, _swapCase);
		}

		private static function _swapCase(char:String, ...args):String
		{
			var lowChar:String = char.toLowerCase();
			var upChar:String = char.toUpperCase();
			switch (char) 
			{
				case lowChar:
					return upChar;
				case upChar:
					return lowChar;
				default:
					return char;
			}
		}

		/**
		 * Returns a string truncated to a specified length with optional suffix
		 * @param string The string.
		 * @param len The length the string should be shortend to
		 * @param suffix (optional, default=...) The string to append to the end of the truncated string.
		 */
		public static function truncate(string:String, len:uint, suffix:String = "..."):String 
		{
			if (string == null) return '';
			len -= suffix.length;
			var trunc:String = string;
			if (trunc.length > len)
			{
				trunc = trunc.substr(0, len);
				if ((/[^\s]/ as RegExp).test(string.charAt(len)))
				{
					trunc = StringUtils.rtrim(trunc.replace(/\w+$|\s+$/, ''));
				}
				trunc += suffix;
			}
			return trunc;
		}

		/**
		 * Removes all instances of word in string.
		 * @param string the original string.
		 * @param word the word to remove from string.
		 * @param caseSensitive indicates in removing is case sensative.
		 * @return the string without the word
		 */
		public static function removeWord(string:String, word:String, caseSensitive:Boolean = true):String 
		{
			return string.replace(new RegExp("^" + word + "(\\W)|(\\W)" + word + "$|\\W" + word + "(?=\\W)", "g" + (caseSensitive ? "" : "i")), "");
		}

		/**
		 * Removes all instances of all words in string
		 * @param string the original string
		 * @param word the word to remove from string
		 * @param caseSensitive indicates in removing is case sensative.
		 * @return the string without the word
		 */
		public static function removeWords(string:String, words:Array, caseSensitive:Boolean = true):String 
		{
			var leni:int = words.length;
			for (var i:int = 0; i < leni; i++)
			{
				string = StringUtils.removeWord(string, words[i], caseSensitive);
			}
			return string;
		}

		/**
		 * Split a string on multiple seperators
		 * @param string The string.
		 * @param seperators Array with the seperators to split on
		 * @param reappendSeperator (optional) Re-append the seperator after each part
		 * @return a single-dimension array with the parts
		 */
		public static function splitMultiSeperator(string:String, seperators:Array, reappendSeperator:Boolean = false):Array
		{
			var ret:Array = [string];
			for each(var seperator:String in seperators)
			{
				ret = StringUtils.splitElements(ret, seperator, reappendSeperator);
			}
			return ret;
		}
		/**
		 * Split multiple strings on a seperator
		 * @param string Array with the strings
		 * @param seperators The seperator to split on
		 * @param reappendSeperator (optional) Re-append the seperator after each part
		 * @return a single-dimension array with the parts
		 */
		public static function splitElements(strings:Array, seperator:String, reappendSeperator:Boolean = false):Array
		{
			var ret:Array = [];
			for(var i:int = 0;i < strings.length;i++)
			{
				var split:Array = String(strings[i]).split(seperator);
				for(var j:int = 0;j < split.length;j++)
				{
					var p:String = StringUtils.trim(split[j]);
					if(p != '')
					{
						ret.push(reappendSeperator && j < split.length - 1 ? p + seperator : p);
					}
				}
			}
			return ret;
		}
		/**
		 * Trim all elements in an Array (in place)
		 * @param string Array with the strings
		 * @param seperators The seperator to split on
		 * @param reappendSeperator (optional) Re-append the seperator after each part
		 * @return the modified input array
		 */
		public static function trimAll(array:Array):Array
		{
			for(var i:int = 0;i < array.length;i++)
			{
				array[i] = StringUtils.ltrim(StringUtils.rtrim(array[i]));
			}
			return array;
		}

		/**
		 * Trim all elements in an Array, and after trimming remove any empty (== '') elements
		 * @param string Array with the strings
		 * @param seperators The seperator to split on
		 * @param reappendSeperator (optional) Re-append the seperator after each part
		 * @return a new array with the parts
		 */
		public static function trimAllFilter(array:Array):Array
		{
			var ret:Array = [];

			for(var i:int = 0;i < array.length;i++)
			{
				var tmp:String = StringUtils.ltrim(StringUtils.rtrim(array[i]));
				if(tmp != '')
				{
					ret.push(tmp);
				}
			}
			return ret;
		}
		
		public static function cleanSpecialChars(string:String):String
		{
			var validString:String = "";
			var len:int = string.length;
			//
			for (var i:int = 0; i < len; i++)
			{
				var charCode:int = string.charCodeAt(i);
				if ((charCode < 47) || (charCode > 57 && charCode < 65) || charCode == 95) validString += "-";
				else if ((charCode > 90 && charCode < 97) || (charCode > 122 && charCode < 128)) validString += "-";
				else if (charCode > 127)
				{
					if ((charCode > 130 && charCode < 135) || charCode == 142 || charCode == 143 || charCode == 145 || charCode == 146 || charCode == 160 || charCode == 193 || charCode == 225) validString += "a";
					else if (charCode == 128 || charCode == 135) validString += "c";
					else if (charCode == 130 || (charCode > 135 && charCode < 139) || charCode == 144 || charCode == 201 || charCode == 233) validString += "e";
					else if ((charCode > 138 && charCode < 142) || charCode == 161 || charCode == 205 || charCode == 237) validString += "i";
					else if (charCode == 164 || charCode == 165) validString += "n";
					else if ((charCode > 146 && charCode < 150) || charCode == 153 || charCode == 162 || charCode == 211 || charCode == 214 || charCode == 243 || charCode == 246 || charCode == 336 || charCode == 337) validString += "o";
					else if (charCode == 129 || charCode == 150 || charCode == 151 || charCode == 154 || charCode == 163 || charCode == 218 || charCode == 220 || charCode == 250 || charCode == 252 || charCode == 368 || charCode == 369) validString += "u";
				}
				else
				{
					validString += string.charAt(i);
				}
			}
			validString = validString.replace(/\-+/g, "-").replace(/\-*$/, "");
			return validString.toLowerCase();
		}
		
		/**
		 * Searches for a hyperlink in a string and returns HTML text with clickable link
		 * @param string the string to parse
		 * @param target the target to open the link
		 * @return HTML text
		 * @example
		 * <listing version="3.0">
		 * var parsedText:String = StringUtils.parseHyperlinks('Check out the TempleLibrary on http://code.google.com/p/templelibrary/');
		 * trace(parsedText) // Check out the TempleLibrary on <a href='http://code.google.com/p/templelibrary/' target='_blank'>http://code.google.com/p/templelibrary/</a>
		 * </listing>
		 */
		public static function parseHyperlinks(string:String, target:String = '_blank'):String
		{
			var urlPattern:RegExp = new RegExp("(((f|ht){1}tp|[s]://)[-a-zA-Z0-9@:%_\+.~#!?&//=]+)", "g");
			return string.replace(urlPattern, "<a href='$1' target='" + target + "'>$1</a>");
		}
		
		/**
		 * @private
		 */
		public static function toString():String
		{
			return objectToString(StringUtils);
		}
	}
}