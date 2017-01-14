package cn.jiph {
	import com.bit101.components.HBox;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import com.bit101.components.Window;
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.system.Capabilities;

	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="400", height="240")]
	public class ExcelToJSON extends Window {
		private var _text : AdvTextArea;
		// 保存解析的数据
		private var _parser : ExcelParser;
		private var _parsed : Boolean;

		public function ExcelToJSON() {
			// 字体设置为Arial
			Style.fontName = "Arial";
			Style.embedFonts = false;
			Style.fontSize = 12;
			super(null, 0, 0, "ExcelToJson");
			setSize(stage.stageWidth - 2, stage.stageHeight - 2);
			hasCloseButton = true;
			stage.nativeWindow.x = (Capabilities.screenResolutionX - width) >> 1;
			stage.nativeWindow.y = (Capabilities.screenResolutionY - height) * 0.4;
		}

		override protected function addChildren() : void {
			super.addChildren();
			var menu : HBox = new HBox(this, 2, 2);
			menu.spacing = 2;
			new PushButton(menu, 0, 0, "选择EXCEL", selectExcelHandler);
			new PushButton(menu, 0, 0, "导出JSON", convertJsonHandler);
			new PushButton(menu, 0, 0, "清除信息", clearDebugHandler);
			_text = new AdvTextArea(this, 2, 23);
			//
			_parser = new ExcelParser(convertComplete, _text.insert);
		}

		private function clearDebugHandler(event : MouseEvent) : void {
			_text.text = "";
		}

		override public function draw() : void {
			super.draw();
			_text.setSize(width - 3, height - 45);
		}

		private function convertComplete() : void {
			_parsed = true;
			_text.insert(JSON.stringify(_parser.data, null, 4));
		}

		private function convertJsonHandler(event : MouseEvent) : void {
			if (_parsed == false) {
				_text.insert("请先选取Excel");
				stage.nativeWindow.x -= 10;
				TweenMax.to(stage.nativeWindow, 0.06, {x:"+20", ease:Sine.easeInOut, yoyo:true, repeat:4, onComplete:function() : void {
					stage.nativeWindow.x -= 10;
				}});
				return;
			}
			var file : File = new File();
			file.addEventListener(Event.SELECT, saveJsonHandler);
			file.browseForDirectory("保存JSON文件");
		}

		private function saveJsonHandler(event : Event) : void {
			var file : File = event.target as File;
			file = file.resolvePath(_parser.name + ".json");
			var stream : FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(JSON.stringify(_parser.data));
			stream.close();
			_text.insert("file saved == " + file.nativePath + "[" + _parser.getSize(file.size) + "]");
			_parsed = false;
		}

		private function selectExcelHandler(event : MouseEvent) : void {
			var file : File = new File();
			file.addEventListener(Event.SELECT, openExcelHandler);
			file.browseForOpen("选择Excel文件", [new FileFilter("*.xlsx", "*.xlsx")]);
		}

		private function openExcelHandler(event : Event) : void {
			_parsed = false;
			_parser.parse(event.target as File, true);
		}

		override protected function onMouseGoDown(event : MouseEvent) : void {
			stage.nativeWindow.startMove();
			this.alpha = 0.75;
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
		}

		override protected function onMouseGoUp(event : MouseEvent) : void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
			this.alpha = 1;
		}

		override protected function onClose(event : MouseEvent) : void {
			stage.nativeWindow.close();
		}
	}
}
