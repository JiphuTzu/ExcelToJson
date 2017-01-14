package com.bit101.components {
	import com.bit101.components.Component;

	import flash.display.DisplayObjectContainer;

	/**
	 * @author JiphuTzu
	 */
	public class Spliter extends Component {
		public function Spliter(parent : DisplayObjectContainer = null, xpos : Number = 0, ypos : Number = 0, width : int = 2, height : int = 2) {
			super(parent, xpos, ypos);
			setSize(width, height);
		}

		override protected function addChildren() : void {
			super.addChildren();
			filters = [getShadow(2)];
		}

		override public function draw() : void {
			super.draw();
			graphics.clear();
			graphics.lineStyle(1, 0, 0.1);
			graphics.beginFill(Style.PANEL);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
	}
}
