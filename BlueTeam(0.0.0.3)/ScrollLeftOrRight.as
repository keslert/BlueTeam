package {
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;


	//class declaration
	public class tileEditor extends Object {
		//declare variables
		private var mapW:int;
		private var mapH:int;
		private var screenY:int;
		private var screenX:int;
		private var tileX:int;
		private var tileY:int;
		private var tiles:Sprite;
		private var levelLength:int;
		private var border:Sprite;
		private var r:Sprite;
		private var screen:Sprite;
		private var updateTimer:int;
		private var scrollSpeed:int;
		private var list:Array;
		private var keys:Object;
		
		private var map1:Array;

		//class constructor function
		public function tileEditor (rootMC:Sprite) {
			r = rootMC;
			r.addEventListener(Event.ENTER_FRAME,updateGame);
			screenY = 450;
			screenX = 450;
			tileX = 40;
			tileY = 40;
			scrollSpeed = 5;
			updateTimer = tileX;
			buildMap();
			buildBorder();
			createKeys();
		}
		public function buildMap() {
			tiles = new Sprite();
			r.addChild(tiles);
			tiles.y = 5;
			map1 = [
			[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
			];
			levelLength = (map1[0].length*tileX); //length of level in pixels
			var x1:int = Math.ceil(screenX/tileX)+1; //give the screen a little buffer
			var y1:int = Math.floor(screenY/tileY);
			trace(x1);
			list = new Array();
		
			for(var n=0; n<x1;n++) {
				var column:Sprite = new Sprite();
				column.x=n*tileX;
				for(var m=0;m<y1;m++) {
					var tile:Tile = new Tile();
					tile.type = map1[m][n];
					tile.gotoAndStop(tile.type);
					tile.x = 0;
					tile.y = tileY*m;			
					column.addChild(tile);
				}
				//Extra tile for numbering
				tile = new Tile();
				tile.y=tileY*y1;
				tile.gotoAndStop(100);
				tile.cellNum.text=n;
				column.addChild(tile);
				///////////////////////////////////
				tiles.addChild(column);
				list.push(column);
			}
		}
		private function buildBorder():void {
			border = new Sprite();
			border.graphics.lineStyle(10, 0x00000);
			border.graphics.drawRect(4, 4, 442, 442);
			border.graphics.endFill();
			r.addChild(border);

		}
		private function updateGame(event:Event):void {
			scrollScreen();
		}
		private function scrollScreen():void {
			if(keys[Keyboard.LEFT].down) {
				if((screenX-tiles.x+tileX) > levelLength) {
					trace("end reached");
				} else {
					tiles.x-=scrollSpeed;
					updateTimer-=scrollSpeed; //this timer controls when new tiles are created and removed
					if(updateTimer < 1) {
						//updateMapRight();
					}
				}
			} else if(keys[Keyboard.RIGHT].down) {
				if(tiles.x > 0) {
					trace("end reached");
				} else {
					tiles.x+=scrollSpeed;
					updateTimer+=scrollSpeed; //this timer controls when new tiles are created and removed
					if(updateTimer > 49) {
						//updateMapLeft();
					}
				}
			}
		}
		private function updateMapRight() {
			updateTimer+=tileX;
			tiles.removeChild(list.shift());
			var curColumn:int = Math.ceil((screenX-tiles.x)/tileX)+1; //calculates the column of tiles to add
			var y:int = Math.floor(screenY/tileY); //how many rows
			var column:Sprite = new Sprite();
			column.x = (curColumn-1)*tileX;
			for(var i=0;i<y;i++) {
				var tile:Tile = new Tile();
				tile.type = map1[i][curColumn];
				tile.gotoAndStop(tile.type);
				tile.y = tileY*i;			
				column.addChild(tile);
			}
			//Extra tile for numbering
			tile = new Tile();
			tile.y=tileY*y;
			tile.gotoAndStop(100);
			tile.cellNum.text=""+(curColumn-1);
			column.addChild(tile);
			///////////////////////////////////
			list.push(column);
			tiles.addChild(column);
		}
		private function updateMapLeft() {
			updateTimer-=tileX;
			tiles.removeChild(list.pop());
			var curColumn:int = Math.ceil((0-tiles.x)/tileX); //calculates the column of tiles to add
			var y:int = Math.floor(screenY/tileY); //how many rows
			var column:Sprite = new Sprite();
			column.x = (curColumn)*tileX;
			for(var i=0;i<y;i++) {
				var tile:Tile = new Tile();
				tile.type = map1[i][curColumn];
				tile.gotoAndStop(tile.type);
				tile.y = tileY*i;			
				column.addChild(tile);
			}
			//Extra tile for numbering
			tile = new Tile();
			tile.y=tileY*y;
			tile.gotoAndStop(100);
			tile.cellNum.text=""+curColumn;
			column.addChild(tile);
			///////////////////////////////////
			
			list.unshift(column);
			tiles.addChild(column);
		}
		private function createKeys():void {
			//set up keys object
			keys = new Object();
			//fill the object with arrow keys
			keys[Keyboard.LEFT] = {down:false};
			keys[Keyboard.RIGHT] = {down:false};
		}
		public function downKeys (ev:KeyboardEvent):void {
			//check if the is arrow key
			if (keys[ev.keyCode] != undefined) {
				//set the key to true
				trace(ev.keyCode);
				
				keys[ev.keyCode].down = true;
			}
		}
		//this function will detect keys that are being released
		public function upKeys (ev:KeyboardEvent):void {
			//check if the is arrow key
			if (keys[ev.keyCode] != undefined) {
				//set the key to false
				keys[ev.keyCode].down = false;
			}
		}
	}
}