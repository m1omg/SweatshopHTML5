package ss.app.screens
{
   import flash.display.MovieClip;
   import org.fatlib.app.Screen;
   import org.fatlib.events.CustomEvent;
   import ss.app.App;
   import ss.app.GlobalUI;
   import ss.app.KarmaMeter;
   import ss.data.KarmaRank;
   import ss.utils.KarmaManager;
   import ss.utils.Utils;
   
   public class EndScreen extends Screen
   {
      
      public function EndScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         var _loc1_:MovieClip = App.instance.resources.instantiateMovieClip("ui","EndScreenSymbol");
         display.addChild(_loc1_);
         var _loc2_:int = App.instance.session.calculateKarma();
         var _loc3_:KarmaRank = App.instance.karma.getRank(_loc2_);
         KarmaMeter.configure(_loc1_["karma"],_loc2_);
         _loc1_["title"].text = _loc3_.title;
         if(KarmaManager.hasGoodEnding(_loc2_))
         {
            _loc1_["good"].visible = true;
            _loc1_["evil"].visible = false;
            App.instance.audio.playMusic("happy");
         }
         else
         {
            _loc1_["good"].visible = false;
            _loc1_["evil"].visible = true;
            App.instance.audio.playMusic("forboding");
         }
         App.instance.globalUI.addEventListener(GlobalUI.ACTION,this.onAction);
         Utils.fadeFromBGColor(_loc1_);
      }
      
      private function onAction(param1:CustomEvent) : void
      {
         if(param1.data.action == "skip")
         {
            gotoScreen(App.END_CREDITS_SCREEN);
         }
      }
      
      override public function handleRemoved() : void
      {
         App.instance.globalUI.removeEventListener(GlobalUI.ACTION,this.onAction);
         App.instance.audio.stopMusic();
      }
   }
}

