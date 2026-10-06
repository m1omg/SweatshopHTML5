package ss.app.screens
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.utils.MovieClipListener;
   import ss.app.App;
   
   public class Credits extends Sprite implements IDestroyable
   {
      
      private var _mcl:MovieClipListener;
      
      private var _prevMusic:String;
      
      public function Credits()
      {
         super();
         var _loc1_:MovieClip = App.instance.resources.instantiateMovieClip("credits","CreditsScreenSymbol");
         this._mcl = new MovieClipListener(_loc1_["credits"]);
         this._mcl.addEventListener(Event.CHANGE,this.onChange);
         this._mcl.addEventListener(Event.COMPLETE,this.onComplete);
         App.instance.stage.frameRate = 30;
         addChild(_loc1_);
      }
      
      private function onComplete(param1:Event) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onChange(param1:Event) : void
      {
         if(this._mcl.currentLabel == "music")
         {
            App.instance.audio.playMusic("credits");
         }
      }
      
      public function destroy() : void
      {
         App.instance.audio.stopMusic();
         App.instance.stage.frameRate = 25;
         this._mcl.removeEventListener(Event.CHANGE,this.onChange);
         this._mcl.removeEventListener(Event.COMPLETE,this.onComplete);
         this._mcl.destroy();
      }
   }
}

