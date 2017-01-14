package cn.jiph {
	import mx.utils.StringUtil;

	import deng.fzip.FZip;
	import deng.fzip.FZipFile;

	import com.greensock.TweenLite;

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	/**
	 * @author Administrator
	 */
	public class ExcelParser {
		private var _complete : Function;
		private var _debug : Function;
		private var _zip : FZip;
		private var _sharedList : Vector.<String>;
		private var _name : String;
		private var _data : Array;
		private var _advance : Boolean;

		public function ExcelParser(complete : Function, debug : Function) {
			_complete = complete;
			_debug = debug;
			_zip = new FZip();
			_zip.addEventListener(Event.COMPLETE, completeHandler);
		}

		public function get data() : Array {
			return _data;
		}

		public function get name() : String {
			return _name;
		}

		public function parse(file : File, advance : Boolean = false) : void {
			_name = String(file.name).split(".")[0];
			_debug("start parse " + _name + "[" + file.nativePath + "]");

			_advance = advance;
			//
			var bytes : ByteArray = new ByteArray();
			var stream : FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			stream.readBytes(bytes);
			stream.close();
			//
			_zip.loadBytes(bytes);
		}

		public function getSize(size : int) : String {
			if (size >= 1024 * 1024) {
				return (size / 1024 / 1024).toFixed(2) + "MB";
			} else if (size >= 1024) {
				return (size / 1024).toFixed(2) + "KB";
			} else {
				return size + "B";
			}
		}

		private function completeHandler(event : Event) : void {
			_debug("excel loaded.");
			TweenLite.delayedCall(0.3, parseSharedStrings);
		}

		/**
		 *解析数据 
		 * @return 
		 * 
		 */
		private function parseSharedStrings() : void {
			_debug("parse shared string of 'xl/sharedStrings.xml'");
			var file : FZipFile = _zip.getFileByName("xl/sharedStrings.xml");
			var xml : XML = new XML(file.content);
			var ns : Namespace = xml.namespace();
			var sst : XMLList = xml.ns::si;
			var len : int = sst.length();
			_sharedList = new Vector.<String>(len);
			var si : XML;
			for (var i : int = 0; i < len; i++) {
				si = sst[i];
				ns = si.namespace();
				_sharedList[i] = si.ns::t;
			}
			TweenLite.delayedCall(0.3, parseWorkbook);
		}

		private function parseWorkbook() : void {
			_debug("parse workbook of 'xl/workbook.xml'");
			var file : FZipFile = _zip.getFileByName("xl/workbook.xml");
			var workbook : XML = new XML(file.content);
			var ns : Namespace = workbook.namespace();
			var sheets : XML = workbook.ns::sheets[0];
			ns = sheets.namespace();
			var sheetsList : XMLList = sheets.ns::sheet;
			var len : int = sheetsList.length();
			_data = [];
			for (var i : int = 0; i < len; i++) {
				parseSheet("xl/worksheets/sheet" + (i + 1) + ".xml");
			}
			TweenLite.delayedCall(0.3, _complete);
		}

		private function parseSheet(fileName : String) : void {
			var file : FZipFile = _zip.getFileByName(fileName);
			_debug("parse worksheet of '" + fileName + "'");

			var worksheet : XML = new XML(file.content);
			var ns : Namespace = worksheet.namespace();
			var sheetdata : XML = worksheet.ns::sheetData[0];
			ns = sheetdata.namespace();
			var rowList : XMLList = sheetdata.ns::row;
			var len : int = rowList.length();
			if (len > 2) {
				var title : Object = parseRowTitle(rowList[1]);
				_keyType = parseRowType(rowList[2], title);
				var n : int = 3;
				while (n < len) {
					_data.push(praseRow(rowList[n], title));
					n++;
				}
			}
		}

		public function get primaryKey() : String {
			return _primaryKey;
		}

		public function get keyType() : Object {
			return _keyType;
		}

		private var _primaryKey : String;
		private var _keyType : Object;

		private function parseRowTitle(xml : XML) : Object {
			var ns : Namespace = xml.namespace();
			var cells : XMLList = xml.ns::c;
			var len : int = cells.length();
			var title : Object = {};
			var i : int = 0;
			while (i < len) {
				var cell : XML = cells[i];
				ns = cell.namespace();
				var r : String = cell.@r;
				r = r.replace(/\d/g, "");
				var t : String = cell.@t;
				if (t == "s") {
					title[r] = _sharedList[int(cell.ns::v)];
					if (i == 0) _primaryKey = title[r];
				} else {
					// title[r] = parseFloat(cell.ns::v);
				}
				i++;
			}
			return title;
		}

		private function parseRowType(xml : XML, title : Object) : Object {
			var ns : Namespace = xml.namespace();
			var cells : XMLList = xml.ns::c;
			var len : int = cells.length();
			var types : Object = {};
			for (var i : int = 0; i < len; i++) {
				var cell : XML = cells[i];
				ns = cell.namespace();
				var r : String = cell.@r;
				r = r.replace(/\d/g, "");
				r = title[r];
				if (r == null || r == "") continue;
				var t : String = cell.@t;
				if (t == "s") {
					types[r] = _sharedList[int(cell.ns::v)];
				} else {
				}
			}
			return types;
		}

		private function praseRow(row : XML, title : Object) : Object {
			var ns : Namespace = row.namespace();
			var cells : XMLList = row.ns::c;
			var len : int = cells.length();
			var res : Object = {};
			for (var i : int = 0; i < len; i++) {
				var cell : XML = cells[i];
				ns = cell.namespace();
				var r : String = cell.@r;
				r = r.replace(/\d/g, "");
				r = title[r];
				if (r == null || r == "") continue;
				var t : String = cell.@t;
				if (_advance == false) {
					if (t == "s") {
						res[r] = _sharedList[int(cell.ns::v)];
					} else {
						var v : Number = parseFloat(cell.ns::v);
						if (isNaN(v) == true) v = 0;
						res[r] = v;
					}
				} else {
					if (t == "s") {
						res[r] = formatValue(_sharedList[int(cell.ns::v)], _keyType[r]);
					} else {
						res[r] = formatValue(cell.ns::v, _keyType[r]);
					}
				}
			}
			// for (var s:String in res) {
			// trace(s + ":::" + res[s])
			// }
			return res;
		}

		private function formatValue(value : *, type : String) : * {
			if (type == "bool") {
				return formatBoolean(value);
			} else if (type == "int") {
				return formatInt(value);
			} else if (type == "number") {
				return formatNumber(value);
			} else if (type == "string") {
				return formatString(value);
			} else if (type.indexOf("array<") == 0 && type.lastIndexOf(">") == type.length - 1) {
				return formatArray(value, type);
			}
			return null;
		}

		private function formatArray(value : String, type : String) : Array {
			value = StringUtil.trim(value);
			if (value == "" || value == null) return null;
			var res : Array = [];
			var spliter : String = type.charAt(type.length - 2);
			type = type.substr(6, type.length - 8);
			if (value.lastIndexOf(spliter) == value.length - 1) {
				value = value.substr(0, value.length - 1);
			}
			if (value == "" || value == "0") return res;
			var arr : Array = value.split(spliter);
			for (var i : int = 0,len : int = arr.length;i < len;i++) {
				var child : * = formatValue(arr[i], type);
				if (child != null) {
					res.push(child);
				}
			}
			return res;
		}

		private function formatBoolean(value : int) : Boolean {
			return value == 1;
		}

		private function formatString(value : String) : String {
			return value;
		}

		private function formatNumber(value : Number) : Number {
			if (isNaN(value) == true) value = 0;
			return value;
		}

		private function formatInt(value : int) : int {
			return value;
		}
	}
}
