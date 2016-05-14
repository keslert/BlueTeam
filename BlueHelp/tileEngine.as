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
	import flash.text.StaticText;
	import flash.system.*;

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
		private var level:int;
		private var levelLength:int;
		private var border:Sprite;
		private var r:Sprite;
		private var screen:Sprite;
		private var cover:Cover;
		private var updateTimer:Number;
		private var scrollSpeed:Number;
		private var gamePaused:Boolean;
		private var queue:Queue;
		private var keysPressed = [false, false, false, false];
		private var keyCounters = [0,0,0,0];
		private var guy1up:int = 65;
		private var guy1down:int = 90;
		private var wall:int = 8;
		private var levelPassedDelay:int;
		public var guy1:Character;
		public var lastKeyChange:String;
		public var gui:GUI;
		private var map:Array;
		private var stats:Stats;
		//class constructor function
		public function tileEngine (rootMC:Sprite) {
			r = rootMC;
			screenY = 450;
			screenX = 450;
			tileX = 40;
			tileY = 40;
			level = 1;
			setupLevel();
		}
		private function setupLevel():void {
			r.addEventListener(Event.ENTER_FRAME,updateGame);
			gamePaused = false;
			scrollSpeed = 3;
			levelPassedDelay = 0;
			updateTimer = tileX;
			buildMap();
			buildBorder();
			buildGUI();
			buildCharacters();
			stats=new Stats();
			r.addChild(stats);
		}
		public function buildMap():void {
			tiles = new Sprite();
			r.addChild(tiles);
			tiles.y = 5;
			map = Maps.getMap(level);
			levelLength = (map[0].length*tileX-300); //length of level in pixels
			var x1:int = Math.ceil(screenX/tileX)+1; //give the screen a little buffer
			var y1:int = Math.floor(screenY/tileY);
			queue = new Queue();
			for(var n=0; n<x1;n++) {
				var column:Sprite = new Sprite();
				column.x=n*tileX;
				for(var m=0;m<y1;m++) {
					var tile:Tile = new Tile();
					tile.type = map[m][n];
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
		private function buildGUI():void {
			gui = new GUI();
			gui.key1.gotoAndStop(3);
			gui.key2.gotoAndStop(4);
			r.addChild(gui);
		}
		private function buildCharacters(){
			guy1up = 65;
			guy1down = 90;
			guy1 = new Character();
			guy1.isDead = false;
			guy1.ID = "guy1";
			guy1.claimedPos = Maps.getCharPos(level)[0];
			guy1.x = 70;
			guy1.y = guy1.claimedPos*tileY+guy1.radius;
			guy1.keyUP = 1;
			guy1.keyDOWN = 2;
			r.addChild(guy1);
		}
		private function updateGame(event:Event):void {
			if(!gamePaused) {
				scrollScreen();
				moveCharacters();
			} else {
				levelPassed();
			}
		}
		private function levelPassed() {
			if(levelPassedDelay==0) {
				cover = new Cover();
				r.addChild(cover);
			} 
			if(levelPassedDelay < 120) {
				guy1.x+=guy1.speed;
				levelPassedDelay++;
			} else {
				level++;
				cleanup();
				setupLevel();
			}
		}
		private function cleanup() {			
			r.removeChild(cover);
			r.removeChild(tiles);
			r.removeChild(guy1);
			r.removeChild(gui);
			r.removeChild(border);
			r.removeChild(stats);
			queue = null;
			
			r.removeEventListener(Event.ENTER_FRAME,updateGame);
			flash.system.System.gc();
			flash.system.System.gc();
		}
		private function scrollScreen():void {
			if((screenX-tiles.x+tileX) > levelLength) {
				gamePaused = true;
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
				tile.type = map[i][curColumn];
				tile.gotoAndStop(tile.type);
				tile.y = tileY*i;			
				column.addChild(tile);
			}
			queue.push(column);
			tiles.addChild(column);
		}
		private function moveCharacters(){
			if(guy1.isDead) {
				hitWall();
			}
			if(!guy1.isDead) {
				var updatedPos = Math.floor((guy1.claimedPos*tileY-guy1.y+guy1.radius)/guy1.speed);
				if(updatedPos < 0) {
					guy1.y-=guy1.speed;
				} else if(updatedPos > 0) {
					guy1.y+=guy1.speed;
				}
			} else
				guy1.x-=scrollSpeed;
			checkCurrentTile(guy1);
		}
		
		public function checkCurrentTile(guy:Character):void{
			var xTile = Math.floor((-1*(tiles.x-guy.x+(guy.radius*2)))/tileX)+2;
			var yTile = Math.floor(guy.y/tileY);
			var tile_type = map[yTile][xTile];
			if(tile_type > wall) {//WALL
				guy.isDead = true;
			}
		}
		private function hitWall():void {
			if(levelPassedDelay==0) {
				updateTimer+=1000;
				scrollSpeed=.2;
				cover = new Cover();
				r.addChild(cover);
			} 
			if(levelPassedDelay < 120) {
				levelPassedDelay++;
			} else {
				cleanup();
				setupLevel();
			}
		}
		private function checkWall(guy:Character,dir:String) {
			if(dir == "up") {
				var addition = -1;
			} else {
				var addition = 1;
			}
			var xTile = Math.floor((-1*(tiles.x-guy.x+(guy.radius*2)))/tileX)+2;
			var yTile = guy.claimedPos+addition;
			var leftTile = map[yTile][xTile-1];
			var middleTile = map[yTile][xTile];
			var rightTile = map[yTile][xTile+1];
			if(leftTile > wall && middleTile > wall && rightTile > wall)
				return false;
			return true;
		}
		public function keysDown(event: KeyboardEvent): void{
			if(event.keyCode == guy1up){
				if(guy1.claimedPos > 1)
					if(checkWall(guy1,"up"))
						guy1.claimedPos--;
			}
			if(event.keyCode == guy1down){
				if(guy1.claimedPos < 10)
					if(checkWall(guy1,"down"))
						guy1.claimedPos++;
			}
		}
	}
}