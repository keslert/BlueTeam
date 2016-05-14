//KESLER
package {
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import Queue;

	//class declaration
	public class tileEngine extends Object {
		//declare variables
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
		private var queue:Queue;
		private var keysPressed = [false, false, false, false];
		private var keyCounters = [0,0,0,0];
		private var guy1up:int = 38;
		private var guy1down:int = 40;
		private var guy2up:int = 65;
		private var guy2down:int = 90;
		private var switchKeys:int = 83;
		public var guy1:Character;
		public var guy2:Character;
		private var map1:Array;

		//class constructor function
		public function tileEngine (rootMC:Sprite) {
			r = rootMC;
			r.addEventListener(Event.ENTER_FRAME,updateGame);
			screenY = 450;
			screenX = 450;
			tileX = 40;
			tileY = 40;
			scrollSpeed = 3;
			updateTimer = tileX;
			buildMap();
			buildBorder();
			buildCharacters();
		}
		public function buildMap() {
			tiles = new Sprite();
			r.addChild(tiles);
			tiles.y = 5;
			map1 = [
			[2,2,7,3,3,3,3,3,5,2,2,2,2,2,7,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,5,2,2,2,2],
			[1,1,6,2,2,2,2,2,4,1,1,1,1,1,8,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,5,2,2,2,7,3,3,3,3,3,3,3,9,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,3,3,3,3,3,3,3,3,3,3,5,2,2,2,2,2,4,1,1,1,6,2,2,2,2,7,3,3,9,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,3,3,3,3,3,3,3,5,2,2,4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,6,2,2,4,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,6,2,2,2,2,2,2,2,4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
			];
			levelLength = (map1[0].length*tileX); //length of level in pixels
			var x1:int = Math.ceil(screenX/tileX)+1; //give the screen a little buffer
			var y1:int = Math.floor(screenY/tileY);
			queue = new Queue();
		
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
				tiles.addChild(column);
				queue.push(column);
			}
		}
		private function buildBorder():void {
			border = new Sprite();
			border.graphics.lineStyle(10, 0x00000);
			border.graphics.drawRect(4, 4, 442, 442);
			border.graphics.endFill();
			r.addChild(border);
		}
		private function buildCharacters(){
			guy1 = new Character();
			guy2 = new Character();
			guy1.x = 70;
			guy1.y = 140;
			guy1.isDead = false;
			guy1.currY = 2;
			guy2.x = 70;
			guy2.y = 380;
			guy2.isDead = false;
			guy2.currY = 8;
			r.addChild(guy1);
			r.addChild(guy2);
		}
		private function updateGame(event:Event):void {
			scrollScreen();
			moveCharacters();
		}
		private function scrollScreen():void {
			if((screenX-tiles.x+tileX) > levelLength) {
			} else {
				tiles.x-=scrollSpeed;
				updateTimer-=scrollSpeed; //this timer controls when new tiles are created and removed
				if(updateTimer < 1) {
					updateMap();
				}
			}
		}
		private function updateMap() {
			updateTimer+=tileX;
			tiles.removeChild(queue.pop());
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
			queue.push(column);
			tiles.addChild(column);
		}
		private function moveCharacters(){
			if(keysPressed[0] && !guy1.isDead){
				if(guy1.y > 100){
						guy1.y -= 4;
						keyCounters[0]+=4;
						if(keyCounters[0] == 40){
							keyCounters[0] = 0;
							keysPressed[0] = false;
							guy1.currY--;
						}
						else{
							keysPressed[0] = true;
						}
					}
			}
			if(keysPressed[1] && !guy1.isDead){
				if(guy1.y < 220){
					guy1.y += 4;
					keyCounters[1]+=4;
						if(keyCounters[1] == 40){
							keyCounters[1] = 0;
							keysPressed[1] = false;
							guy1.currY++;
						}
				}
			}
			if(keysPressed[2]&& !guy2.isDead){
				if(guy2.y > 300){
						guy2.y -= 4;
						keyCounters[2]+=4;
						if(keyCounters[2] == 40){
							keyCounters[2] = 0;
							keysPressed[2] = false;
							guy2.currY--;
						}
					}
			}
			if(keysPressed[3] && !guy2.isDead){
				if(guy2.y < 420){
					guy2.y += 4;
					keyCounters[3]+=4;
						if(keyCounters[3] == 40){
							keyCounters[3] = 0;
							keysPressed[3] = false;
							guy1.currY++;
						}
				}
			}
			
			if(guy1.isDead){
				guy1.x -= 5;
			}
			
			if(guy2.isDead){
				guy2.x -= 5;
			}
			
			checkCurrentTile(guy1);
			checkCurrentTile(guy2);
			
		}
		
		public function checkCurrentTile(guy:Character):void{
			var currX:int = (tiles.x)/(0-tileX);
			//trace("CurrX:  " + currX);
			//trace("Tiles.x: " + tiles.x);
			//trace("tileX:  " + tileX);
			var moveable:int = map1[guy.currY][currX+3];
			trace(moveable);
			if(moveable > 1){
				guy.isDead = true;
			}
			//else if(moveable == 3){
				//switchControls();
			//}
		}
		public function keysDown(event: KeyboardEvent): void{
			if(event.keyCode == guy1up){
					keysPressed[0] = true;
			}
			if(event.keyCode == guy1down){
				keysPressed[1] = true;		
			}
			if(event.keyCode == guy2up){
					keysPressed[2] = true;
			}
			if(event.keyCode == guy2down){
				keysPressed[3] = true;
			}
		}

	}
}