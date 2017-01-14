package cn.jiph {
	import com.bit101.components.TextArea;

	import flash.display.DisplayObjectContainer;

	/**
	 * @author JiphuTZu
	 * @QQ     10464925
	 */
	public class AdvTextArea extends TextArea {
		public function AdvTextArea(parent : DisplayObjectContainer = null, xpos : Number = 0, ypos : Number = 0, text : String = "") {
			super(parent, xpos, ypos, text);
			this.editable = false;
			this.html = true;
		}

		public function insert(str : String) : void {
			trace(str);
			this.text = str + "\n" + text;
		}

		public function error(str : String) : void {
			this.text = "<font color='#DD0000'>Error:" + str + "</font>\n" + text;
		}
	}
}
