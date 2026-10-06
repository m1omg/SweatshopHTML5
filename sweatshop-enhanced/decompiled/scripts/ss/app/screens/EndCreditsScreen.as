package ss.app.screens
{
   import flash.events.Event;
   import org.fatlib.Log;
   import org.fatlib.app.Screen;
   import org.fatlib.events.CustomEvent;
   import ss.app.App;
   import ss.app.GlobalUI;
   import ss.app.NavUtils;
   import ss.utils.AudioUtils;
   
   public class EndCreditsScreen extends Screen
   {
      
      private var _credits:Credits;
      
      public function EndCreditsScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         this._credits = new Credits();
         display.addChild(this._credits);
         this._credits.addEventListener(Event.COMPLETE,this.onComplete);
         App.instance.globalUI.addEventListener(GlobalUI.ACTION,this.onAction);
      }
      
      override public function handleRemoved() : void
      {
         App.instance.globalUI.removeEventListener(GlobalUI.ACTION,this.onAction);
         this._credits.removeEventListener(Event.COMPLETE,this.onComplete);
         this._credits.destroy();
      }
      
      private function onComplete(param1:Event) : void
      {
         this.done();
      }
      
      private function onAction(param1:CustomEvent) : void
      {
         switch(param1.data.action)
         {
            case "skip":
               AudioUtils.uiNav();
               Log.log("[EndCreditsScreen] skip");
               this.done();
         }
      }
      
      private function done() : void
      {
         NavUtils.gotoSelectScreen(false);
      }
   }
}

