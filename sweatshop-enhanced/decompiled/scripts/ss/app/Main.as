package ss.app
{
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class Main extends Sprite
   {
      
      private var _app:App;
      
      public function Main()
      {
         super();
         if(stage)
         {
            this.init();
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,this.init);
         }
      }
      
      private function init(param1:Event = null) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.init);
         this._app = new App(stage);
      }
   }
}

