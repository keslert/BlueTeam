//KESLER
package {
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import Queue;
	import flash.text.StaticText;
	import flash.system.*;
	import flash.media.Sound;
	import flash.net.*;
	
	public class tileEngine extends Object {
		private var screenY:int;
		private var screenX:int;
		private var tileX:int;
		private var tileY:int;
		private var tiles:Sprite;
		private var level:int;
		private var levelLength:int;
		private var border:Sprite;
		private var r:Sprite;
		private var cover:Cover;
		private var updateTimer:Number;
		private var scrollSpeed:Number;
		private var gamePaused:Boolean;
		private var queue:Queue;
		private var guy1up:int = 65;
		private var guy1down:int = 90;
		private var guy2up:int = 38;
		private var guy2down:int = 40;
		private var wall:int = 8;
		private var levelPassedDelay:int;
		public var guy1:Character;
		public var guy2:Character;
		public var lastKeyChange:String;
		public var gui:GUI;
		private var levelChooserGUI:LevelChooserGUI;
		private var map:Array;
		private var stats:Stats;
		private var music:Music;
		private var sounds:Music;
		
		private var sendAndLoad:SendAndLoad;
		//class constructor function
		public function tileEngine (rootMC:Sprite) {
			r = rootMC;
			screenY = 550;
			screenX = 560;
			tileX = 50;
			tileY = 50;
			level = 5;
			r.addEventListener(Event.ENTER_FRAME,updateGame);
			setupOnce();
			setupLevel();
			//sendAndLoad = new SendAndLoad();
			//var vars:URLVariables = new URLVariables();
			//vars.request = "list";
			//vars.password = "kokomo";
			//sendAndLoad.sendData("http://www.keslert.com/blueteam.php",vars);
		}
		private function advanceLevel():void {
			r.removeChild(levelChooserGUI);
			levelChooserGUI = null;
			setupLevel();
			music.startSong("song1");
		}
		private function setupOnce():void {
			tiles = new Sprite();
			r.addChild(tiles);
			buildBorder();
			buildGUI();
			buildCharacters();
			buildMap();
			stats= new Stats();
			r.addChild(stats);
			music = new Music();
			music.startSong("song1");
			sounds = new Music();
		}
		private function setupLevel():void {
			gamePaused = false;
			scrollSpeed = 3;
			levelPassedDelay = 0;
			updateTimer = tileX;
			resetMap();
			resetCharacters();
		}
		public function buildMap():void {
			tiles.x=0;
			tiles.y = 5;
			map = Maps.getMap(level);
			levelLength = (map[0].length*tileX-200); //length of level in pixels
			var x1:int = Math.ceil(screenX/tileX)+1; //give the screen a little buffer
			var y1:int = Math.floor(screenY/tileY);
			queue = new Queue();
			for(var n=0; n<x1;n++) {
				var column:Array = new Array();
				for(var m=0;m<y1;m++) {
					var tile:Tile = new Tile();
					tile.type = map[m][n];
					tile.gotoAndStop(tile.type);
					tile.x = tileX*n;
					tile.y = tileY*m;			
					tiles.addChild(tile);
					column[m] = tile;
				}
				queue.push(column);
			}
		}
		private function resetMap() {
			tiles.x=0;
			var x1:int = Math.ceil(screenX/tileX)+1; //give the screen a little buffer
			var y1:int = Math.floor(screenY/tileY);
			map = Maps.getMap(level);
			levelLength = (map[0].length*tileX-200); //length of level in pixels
			for(var n=0;n<x1;n++) {
				var column = queue.pop();
				for(var m=0;m<y1;m++) {
					var tile = column[m];
					tile.type = map[m][n];
					tile.gotoAndStop(tile.type);
					tile.x = tileX*n;
					tile.y = tileY*m;			
				}
				queue.push(column);
			}
		}
		private function buildBorder():void {
			border = new Sprite();
			border.graphics.lineStyle(10, 0x00000);
			border.graphics.drawRect(4, 4, 552, 552);
			border.graphics.endFill();
			r.addChild(border);
		}
		private function buildGUI():void {
			gui = new GUI();
			gui.key1.gotoAndStop(3);
			gui.key2.gotoAndStop(4);
			gui.key3.gotoAndStop(1);
			gui.key4.gotoAndStop(2);
			gui.sound_controller.addEventListener(MouseEvent.CLICK, soundClicked);
			r.addChild(gui);
		}
		private function buildCharacters(){
			guy1 = new Character();
			guy2 = new Character();
			guy1.ID = "guy1";
			guy2.ID = "guy2";
			r.addChild(guy1);
			r.addChild(guy2);
		}
		private function resetCharacters():void {
			guy1up = 65;
			guy1down = 90;
			guy2up = 38;
			guy2down = 40;
			guy1.isDead = false;
			guy1.claimedPos = Maps.getCharPos(level)[0];
			guy1.x = 70;
			guy1.y = guy1.claimedPos*tileY+guy1.radius;
			guy1.keyUP = 3;
			guy1.keyDOWN = 4;
			guy2.isDead = false;
			guy2.claimedPos = Maps.getCharPos(level)[1];
			guy2.x = 70;
			guy2.y = guy2.claimedPos*tileY+guy2.radius;
			guy2.keyUP = 1;
			guy2.keyDOWN = 2;
		}
		private function updateGame(event:Event):void {
			if(!gamePaused) {
				scrollScreen();
				moveCharacters();
			} else {
				levelTransition();
			}
		}
		private function levelTransition() {
			if(levelPassedDelay==0) {
				if(!guy1.isDead && !guy2.isDead)
					music.startSong("song2");
				cover = new Cover();
				r.addChild(cover);
			} 
			levelPassedDelay++;
			if(guy1.isDead || guy2.isDead) {
				scrollSpeed*=.96;
				scrollScreen();
				if(guy1.isDead) guy1.x-=scrollSpeed;
				if(guy2.isDead) guy2.x-=scrollSpeed;
			} else {
				guy1.x+=guy1.speed;
				guy2.x+=guy2.speed;
			}
			if(levelPassedDelay > 120) {
				cleanup();
				if(!guy1.isDead && !guy2.isDead) {
					level++;
					levelChooserGUI = new LevelChooserGUI();
					r.addChild(levelChooserGUI);
				} else
					setupLevel();
			}
		}
		private function cleanup() {			
			r.removeChild(cover);
			cover=null;
			map=null;
			//r.removeEventListener(Event.ENTER_FRAME,updateGame);
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
			var column = queue.pop();
			var curColumn:int = Math.ceil((screenX-tiles.x)/tileX)+1; //calculates the column of tiles to add
			var y:int = Math.floor(screenY/tileY); //how many rows
			var x = (curColumn-1)*tileX;
			for(var i=0;i<y;i++) {
				var tile = column[i];
				tile.type = map[i][curColumn];
				tile.gotoAndStop(tile.type);
				tile.x = x;
			}
			queue.push(column);
			//NECESSARY TO CLEAR THE KEY CHANGES
			guy1.keyChangeDelay();
			guy2.keyChangeDelay();
		}
		private function moveCharacters(){
			var updatedPos = Math.floor((guy1.claimedPos*tileY-guy1.y+guy1.radius)/guy1.speed);
			if(updatedPos < 0) {
				guy1.y-=guy1.speed;
			} else if(updatedPos > 0) {
				guy1.y+=guy1.speed;
			}
		
			var updatedPos = Math.floor((guy2.claimedPos*tileY-guy2.y+guy2.radius)/guy2.speed);
			if(updatedPos < 0) {
				guy2.y-=guy2.speed;
			} else if(updatedPos > 0) {
				guy2.y+=guy2.speed;
			}			
			checkCurrentTile(guy1);
			checkCurrentTile(guy2);
		}
		
		public function checkCurrentTile(guy:Character):void{
			var xTile = Math.floor((-1*(tiles.x-guy.x+(guy.radius*2)))/tileX)+2;
			var yTile = Math.floor(guy.y/tileY);
			var tile_type = map[yTile][xTile];
			if(tile_type > wall) {//WALL
				gamePaused = true;
				guy.isDead = true;
				music.startSound("sound1");
			}
			else if(tile_type > 4) //KEYCHANGE TILE
				keyChange(guy,tile_type);
		}
		
		public function keyChange(guy:Character,type:int) {
			if(type==8) {
				if(guy.lastKeyChange != "bottomSwap") {
					guy1.lastKeyChange = "bottomSwap";
					guy2.lastKeyChange = "bottomSwap";
					var temp1 = guy1down;
					guy1down = guy2down;
					guy2down = temp1;
					guy1.keyChangeCounter=2;
					guy2.keyChangeCounter=2;

					temp1 = guy1.keyDOWN;
					guy1.keyDOWN = guy2.keyDOWN;
					guy2.keyDOWN = temp1;
					updateGUIKeys();
				}
			}else if(type==7) {
				if(guy.lastKeyChange != "topSwap") {
					guy1.lastKeyChange = "topSwap";
					guy2.lastKeyChange = "topSwap";
					var temp1 = guy1up;
					guy1up = guy2up;
					guy2up = temp1;
					guy1.keyChangeCounter=2;
					guy2.keyChangeCounter=2;
					
					temp1 = guy1.keyUP;
					guy1.keyUP = guy2.keyUP;
					guy2.keyUP = temp1;
					updateGUIKeys();
				}
			} else if(type==6) {
				if(guy.lastKeyChange != "swap") {
					guy1.lastKeyChange = "swap";
					guy2.lastKeyChange = "swap";
					var temp1 = guy1up;
					var temp2 = guy1down;
					guy1up = guy2up;
					guy1down = guy2down;
					guy2up = temp1;
					guy2down = temp2;
					guy1.keyChangeCounter=2;
					guy2.keyChangeCounter=2;
					
					temp1 = guy1.keyUP;
					temp2 = guy1.keyDOWN;
					guy1.keyUP = guy2.keyUP;
					guy1.keyDOWN = guy2.keyDOWN;
					guy2.keyUP = temp1;
					guy2.keyDOWN = temp2;
					updateGUIKeys();
				}
			} else if(guy.ID == "guy1") {
				if(type==5) {
					if(guy.lastKeyChange != "reverse") {
						guy.lastKeyChange = "reverse";
						var temp = guy1up;
						guy1up = guy1down;
						guy1down = temp;
						guy.keyChangeCounter=2;
						
						temp = guy.keyUP;
						guy.keyUP = guy.keyDOWN;
						guy.keyDOWN = temp;
						updateGUIKeys();
					}
				}
			} else if(guy.ID =="guy2") {
				if(type==5) {
					if(guy.lastKeyChange != "reverse") {
						guy.lastKeyChange = "reverse";
						var temp = guy2up;
						guy2up = guy2down;
						guy2down = temp;
						guy.keyChangeCounter=2;
						
						temp = guy.keyUP;
						guy.keyUP = guy.keyDOWN;
						guy.keyDOWN = temp;
						updateGUIKeys();
					}
				}
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
			if(middleTile > wall && (rightTile > wall || leftTile > wall))
				return false;
			return true;
		}
		private function updateGUIKeys():void {
			gui.key1.gotoAndStop(guy1.keyUP);
			gui.key2.gotoAndStop(guy1.keyDOWN);
			gui.key3.gotoAndStop(guy2.keyUP);
			gui.key4.gotoAndStop(guy2.keyDOWN);
		}
		public function keysDown(event: KeyboardEvent): void{
			if(event.keyCode==32 && levelChooserGUI != null) {
				advanceLevel();
			}
			if(event.keyCode == guy1up){
				if(guy1.claimedPos > 1)
					if(checkWall(guy1,"up"))
						guy1.claimedPos--;
			}
			if(event.keyCode == guy1down){
				if(guy1.claimedPos < (guy2.claimedPos-1))
					if(checkWall(guy1,"down"))
						guy1.claimedPos++;
			}
			if(event.keyCode == guy2up){
				if(guy2.claimedPos > (guy1.claimedPos+1))
					if(checkWall(guy2,"up"))
						guy2.claimedPos--;
			}
			if(event.keyCode == guy2down){
				if(guy2.claimedPos < 9)
					if(checkWall(guy2,"down"))
						guy2.claimedPos++;
			}
		}
		public function soundClicked(ev:MouseEvent) {
			gui.sound_controller.gotoAndStop((gui.sound_controller.currentFrame)%2+1);
			music.switchVolume();
		}
	}
}