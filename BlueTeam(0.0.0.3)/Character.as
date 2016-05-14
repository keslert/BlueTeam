package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flashx.textLayout.formats.Float;

	public class Character extends MovieClip {
		public var isDead:Boolean;
		
		public var radius:int;
		public var currentPos:int;
		public var desiredPos:int;
		public var claimedPos:int;
		public var speed:Number;
		public var ID:String;
		public var lastKeyChange:String;
		public var keyChangeCounter:int;
		public var keyUP:int;
		public var keyDOWN:int;
		public function Character() {
			isDead = false;
			radius = 15;
			speed = 3;
			keyChangeCounter=1;
		}
		public function keyChangeDelay() {
			keyChangeCounter--;
			if(keyChangeCounter==0)
				lastKeyChange="";
		}
	}
}