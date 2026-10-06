package ss.app.screens
{
   import flash.display.MovieClip;
   import org.fatlib.Log;
   import org.fatlib.app.Screen;
   import org.fatlib.events.CustomEvent;
   import ss.app.App;
   import ss.app.GlobalUI;
   import ss.utils.AudioUtils;
   import ss.utils.Utils;
   
   public class MovieScreen extends Screen
   {
      
      private var _mc:MovieClip;
      
      private var _movieID:String;
      
      public function MovieScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         Log.log("[MovieScreen] handleAdded");
         App.instance.globalUI.addEventListener(GlobalUI.ACTION,this.onAction);
         this._mc = App.instance.resources.instantiateMovieClip("movie","MovieScreenSymbol");
         display.addChild(this._mc);
         Utils.fadeFromBGColor(display);
      }
      
      override protected function handleFrame() : void
      {
         if(this._mc["flv"])
         {
            if((this._mc["flv"] as MovieClip).currentFrameLabel == "done")
            {
               this._mc["flv"].stop();
               this.done();
            }
         }
      }
      
      override public function handleRemoved() : void
      {
         App.instance.globalUI.removeEventListener(GlobalUI.ACTION,this.onAction);
         Log.log("[MovieScreen] handleRemoved");
      }
      
      private function onAction(param1:CustomEvent) : void
      {
         switch(param1.data.action)
         {
            case "skip":
               AudioUtils.uiNav();
               Log.log("[MovieScreen] skip");
               this.done();
         }
      }
      
      private function done() : void
      {
         var _loc1_:String = App.SELECT_SCREEN;
         if(_launchVars["next"])
         {
            _loc1_ = _launchVars["next"];
         }
         gotoScreen(_loc1_);
      }
   }
}

