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
	import flash.display.MovieClip;


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
		private var spriteList:Array;
		private var tileList:Array;
		private var keys:Object;
		private var currentTile:Object;
		private var mouseIsDown:Boolean;
		private var shiftIsDown:Boolean;
		private var ctrlIsDown:Boolean;
		
		private var tileTextBox:MovieClip;
		private var tileSelected:Tile;
		
		private var map1:Array;

		//class constructor function
		public function tileEditor (rootMC:Sprite) {
			r = rootMC;
			r.addEventListener(Event.ENTER_FRAME,updateGame);
			screenY = 450;
			screenX = 450;
			tileX = 40;
			tileY = 40;
			scrollSpeed = 10;
			updateTimer = tileX;
			mouseIsDown = false;
			shiftIsDown = false;
			buildMap();
			GUI();
			buildBorder();
			createKeys();
		}
		public function buildMap() {
			tiles = new Sprite();
			r.addChild(tiles);
			tiles.y = 5;
			tiles.addEventListener(MouseEvent.MOUSE_DOWN,mDown);
			//map1 = [[2],[1],[1],[1],[1],[1],[1],[1],[1],[1],[2]];
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
			
			levelLength = screenX+tileX; //length of level in pixels
			var x1:int = Math.ceil(screenX/tileX)+1; //give the screen a little buffer
			var y1:int = Math.floor(screenY/tileY);
			spriteList = new Array();
			tileList = new Array();
		
			for(var n=0; n<x1;n++) {
				var column:Sprite = new Sprite();
				column.x=n*tileX;
				var a:Array = new Array();
				for(var m=0;m<y1;m++) {
					var tile:Tile = new Tile();
					tile.type = map1[m][n];
					if(tile.type == undefined) {
						if(m==0 || m==(y1-1))
							tile.type = 2;
						else
							tile.type = 1;
					}
					tile.gotoAndStop(tile.type);
					tile.x = 0;
					tile.y = tileY*m;
					tile.xTile=n;
					tile.yTile=m;
					column.addChild(tile);
					a.push(tile);
				}
				//Extra tile for numbering
				tile = new Tile();
				tile.y=tileY*y1;
				tile.xTile=n;
				tile.yTile=y1;
				tile.gotoAndStop(100);
				tile.cellNum.text=n;
				column.addChild(tile);
				///////////////////////////////////
				tiles.addChild(column);
				tiles.cacheAsBitmap = true;
				spriteList.push(column);
				tileList.push(a);
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
			if(keys[Keyboard.RIGHT].down) {
				tiles.x =tiles.x-scrollSpeed;
				updateTimer-=scrollSpeed; //this timer controls when new tiles are created and removed
				if(screenX-tiles.x > levelLength) {
					updateMapRight();
				}
			} else if(keys[Keyboard.LEFT].down) {
				if((tiles.x+=scrollSpeed) > 0) {
					tiles.x=0;
					updateTimer=50;
				} else {
					tiles.x+=scrollSpeed;
					updateTimer+=scrollSpeed; //this timer controls when new tiles are created and removed
				}
			}
		}
		private function updateMapRight() {
			updateTimer+=tileX;
			var a:Array = new Array();
			var curColumn:int = Math.ceil((screenX-tiles.x)/tileX); //calculates the column of tiles to add
			var y:int = Math.floor(screenY/tileY); //how many rows
			var column:Sprite = new Sprite();
			column.x = (curColumn)*tileX;
			for(var i=0;i<y;i++) {
				var tile:Tile = new Tile();
				tile.type = map1[i][curColumn];
				if(tile.type == undefined) {
					if(i==0 || i==(y-1))
						tile.type = 2;
					else
						tile.type = 1;
				}
				tile.gotoAndStop(tile.type);			
				tile.y = tileY*i;
				tile.xTile=curColumn;
				tile.yTile=i;
				column.addChild(tile);
				a.push(tile);
			}
			//Extra tile for numbering
			tile = new Tile();
			tile.y=tileY*y;
			tile.xTile=curColumn;
			tile.yTile=y;
			tile.gotoAndStop(100);
			tile.cellNum.text=""+(curColumn);
			column.addChild(tile);
			///////////////////////////////////
			levelLength+=tileX;
			spriteList.push(column);
			tileList.push(a);
			tiles.addChild(column);
			tiles.cacheAsBitmap = true;
		}
		private function createKeys():void {
			//set up keys object
			keys = new Object();
			//fill the object with arrow keys
			keys[Keyboard.LEFT] = {down:false};
			keys[Keyboard.RIGHT] = {down:false};
			keys[Keyboard.SPACE] = {down:false};
		}
		public function downKeys (ev:KeyboardEvent):void {
			//check if the is arrow key	
			//trace(ev.keyCode);
			if(ev.keyCode==32) {//spacebar
				scrollSpeed=20;
			} else if(ev.keyCode==16) {//LEFT SHIFT
				shiftIsDown=true;
			} else if(ev.keyCode==17) {//LEFT CTRL
				ctrlIsDown=true;
			} else if(ev.keyCode==80) {//P for Print
				printMap();
			} else if(ev.keyCode==83) {//S key
				tileSelected.type++;
				tileTextBox.tileType.text = tileSelected.type;
				tileSelected.gotoAndStop(tileSelected.type);
			} else if(ev.keyCode==65) {//A key
				tileSelected.type--;
				tileTextBox.tileType.text = tileSelected.type;
				tileSelected.gotoAndStop(tileSelected.type);
			} else if(ev.keyCode==81) {//Q key.  Acts just like left press
				keys[Keyboard.LEFT].down = true;
			} else if(ev.keyCode==87) {//W key.  Acts just like right press
				keys[Keyboard.RIGHT].down = true;
			}
			
			if (keys[ev.keyCode] != undefined) {
				//set the key to true
				keys[ev.keyCode].down = true;				
			}
		}
		//this function will detect keys that are being released
		public function upKeys (ev:KeyboardEvent):void {
			
			if(ev.keyCode==32) {//spacebar
				scrollSpeed=10;
			}else if(ev.keyCode==16) {//LEFT SHIFT
				shiftIsDown=false;
			}else if(ev.keyCode==17) {//LEFT CTRL
				ctrlIsDown=false;
			} else if(ev.keyCode==81) {//Q key.  Acts just like left press
				keys[Keyboard.LEFT].down = false;
			} else if(ev.keyCode==87) {//W key.  Acts just like right press
				keys[Keyboard.RIGHT].down = false;
			}
			//check if the is arrow key
			if (keys[ev.keyCode] != undefined) {
				//set the key to false
				keys[ev.keyCode].down = false;
				
			}
		}
		public function mUP(ev:MouseEvent):void {
			if(shiftIsDown) { //CLICK AND DRAG
				var newTile=ev.target;
				if(newTile.xTile == currentTile.xTile) {
					if(newTile.yTile > currentTile.yTile) {
						for(var i=newTile.yTile;i>=currentTile.yTile;i--) {
							tileList[newTile.xTile][i].type=tileSelected.type;
							tileList[newTile.xTile][i].gotoAndStop(tileSelected.type);
						}
					} else {
						for(i=newTile.yTile;i<=currentTile.yTile;i++) {
							tileList[newTile.xTile][i].type=tileSelected.type;
							tileList[newTile.xTile][i].gotoAndStop(tileSelected.type);
						}
					}
					
				} else if(newTile.yTile == currentTile.yTile) {
					if(newTile.xTile > currentTile.xTile) {
						for(i=newTile.xTile;i>=currentTile.xTile;i--) {
							tileList[i][newTile.yTile].type=tileSelected.type;
							tileList[i][newTile.yTile].gotoAndStop(tileSelected.type);
						}
					} else {
						for(i=newTile.xTile;i<=currentTile.xTile;i++) {
							tileList[i][newTile.yTile].type=tileSelected.type;
							tileList[i][newTile.yTile].gotoAndStop(tileSelected.type);
						}
					}
				}
				
				
			} else if(ctrlIsDown) {
				if(currentTile==ev.target) { //GO BACK A TILE
					currentTile=ev.target;
					currentTile.type--;
					currentTile.gotoAndStop(currentTile.type);
				}
			} else {
				if(currentTile==ev.target) { //NORMAL CLICK
					currentTile=ev.target;
					currentTile.type++;
					currentTile.gotoAndStop(currentTile.type);
				}
			}
		}
		public function mDown(ev:MouseEvent):void {
			currentTile=ev.target;			
		}
		private function printMap() {
			//cleanMap();//This will trim off all rows after a solid row of 2's
			var map:String = "[";
			for(var i=0;i<tileList[0].length;i++) {
				map+="\n[";
				for(var j=0;j<tileList.length;j++) {
					map+=""+tileList[j][i].type;
					if(j!=(tileList.length-1))
					   map+=",";
				}
				map+="]"
				if(i != (tileList[0].length-1))
					map+=",";
			}
			map+="\n];";
			trace(map);
		}
		private function cleanMap() {
			var endFound:Boolean = false;
			for(var i=0;i<tileList.length;i++) {
				var allWalls = true;
				for(var j=0;j<tileList[0].length;j++) {
					if(!endFound) {
						if(tileList[i][j].type==1)
							allWalls = false;
					} else {
						for(var k=i;k<spriteList.length;k++) {
							tiles.removeChild(spriteList[k]);
						}
						tileList = tileList.slice(0,j);
						break;
					}
				}
				if(allWalls)
					endFound = true;
			}
			
		}
		private function GUI() {
			tileTextBox = new tileTextMC();
			tileTextBox.x=500;
			tileTextBox.y=549;
			tileTextBox.tileType.text=1;
			r.addChild(tileTextBox);
			
			tileSelected = new Tile();
			tileSelected.x=480;
			tileSelected.y=490;
			tileSelected.type=1;
			tileSelected.gotoAndStop(1);
			r.addChild(tileSelected);
		}
		
	}
}