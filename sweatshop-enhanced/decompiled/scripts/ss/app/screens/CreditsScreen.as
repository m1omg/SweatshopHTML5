package ss.app.screens
{
   import flash.events.Event;
   import ss.app.App;
   
   public class CreditsScreen extends BasePopup
   {
      
      private var _credits:Credits;
      
      private var _prevMusic:String;
      
      public function CreditsScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         this._prevMusic = App.instance.audio.currentMusicTrack;
         App.instance.audio.stopMusic();
         this._credits = new Credits();
         display.addChild(this._credits);
         this._credits.addEventListener(Event.COMPLETE,this.onComplete);
      }
      
      private function onComplete(param1:Event) : void
      {
         App.instance.popups.close();
      }
      
      override public function handleRemoved() : void
      {
         this._credits.removeEventListener(Event.COMPLETE,this.onComplete);
         this._credits.destroy();
         if(this._prevMusic)
         {
            App.instance.audio.playMusic(this._prevMusic);
         }
      }
   }
}

