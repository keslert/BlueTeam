package  {
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	public class Music extends Sound {
	    private var currentSong:Sound;
		private var myChannel:SoundChannel;
		private var myTransform:SoundTransform;
		private var currentSound:Sound;
		private var mySoundChannel:SoundChannel;
		private var myVolume:Number;
		public function Music() {
			myChannel = new SoundChannel();
			myTransform = new SoundTransform();
			myChannel.soundTransform = myTransform;
			mySoundChannel = new SoundChannel();
			mySoundChannel.soundTransform = myTransform;
			myVolume = 1;
		}
		public function startSong(song:String):void {
			currentSong = null;
			myChannel.stop();
			if(song=="song1") {
				currentSong = new Song2();
			} else if(song=="song2") {
				currentSong = new Song1();
			}
			myChannel = currentSong.play();
			myTransform.volume = myVolume;
			myChannel.soundTransform = myTransform;
   		}
		public function stopSong():void {
			myChannel.stop();
		}
		public function startSound(song:String):void {
			currentSound = null;
			mySoundChannel.stop();
			if(song=="sound1") {
				currentSound = new soundEffect1();
			} else if(song=="sound2") {
				currentSound = new soundEffect2();
			}
			mySoundChannel = currentSound.play();
			mySoundChannel.soundTransform = myTransform;
		}
		public function switchVolume() {
			if(myTransform.volume==0) {
				myVolume = 1;
				myTransform.volume = 1;
				myChannel.soundTransform = myTransform;
				mySoundChannel.soundTransform = myTransform;
			} else {
				myVolume = 0;
				myTransform.volume = 0;
				myChannel.soundTransform = myTransform;
				mySoundChannel.soundTransform = myTransform;
			}
		}
	}
}
