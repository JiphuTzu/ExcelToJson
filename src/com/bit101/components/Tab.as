package com.bit101.components {
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author JiphuTzu
	 */
	public class Tab extends Component {
		private var _content : Component;
		private var _buttons : Vector.<PushButton>;
		private var _items : Array;
		private var _selectedIndex : int = -1;
		private var _itemChanged : Boolean;

		public function Tab(parent : DisplayObjectContainer = null, xpos : Number = 0, ypos : Number = 0, items : Array = null) {
			_items = items;
			_itemChanged = (_items != null);
			super(parent, xpos, ypos);
		}

		override protected function addChildren() : void {
			super.addChildren();
			_content = new HBox();
			_content["spacing"] = 0;
			super.addChild(_content);
			_buttons = new Vector.<PushButton>();
		}

		public function set items(value : Array) : void {
			_items = value;
			_itemChanged = true;
			invalidate();
		}

		public function get items() : Array {
			return _items;
		}

		override public function draw() : void {
			// dispatchEvent(new Event(Component.DRAW));
			if (_itemChanged == true) {
				_itemChanged = false;
				var i : int = _buttons.length;
				while (--i >= 0) {
					_buttons[i].remove();
				}
				_buttons.length = 0;
				if (_items == null) return;
				for (i = 0;i < _items.length;i++) {
					var item : Object = _items[i];
					if (item is String) {
						var label : String = item as String;
					} else if (item != null && item.hasOwnProperty("label")) {
						label = item.label;
					} else {
						label = String(item);
					}
					var btn : PushButton = new PushButton(_content, 0, 0, label, clickHandler);
					_buttons[_buttons.length] = btn;
					btn.width = 50;
					btn.enabled = i != _selectedIndex;
				}
			}
		}

		private function clickHandler(event : MouseEvent) : void {
			var index : int = _buttons.indexOf(event.currentTarget);
			if (selectedIndex == index) return;
			selectedIndex = index;
		}

		public function get selectedIndex() : int {
			return _selectedIndex >= _buttons.length ? -1 : _selectedIndex;
		}

		public function set selectedIndex(value : int) : void {
			_selectedIndex = value;
			var i : int = _buttons.length;
			while (--i >= 0) {
				_buttons[i].enabled = (i != value);
			}
			dispatchEvent(new Event(Event.SELECT));
		}

		public function get selectedItem() : Object {
			var index : int = selectedIndex;
			if (index < 0) return null;
			return _items[index];
		}
	}
}
