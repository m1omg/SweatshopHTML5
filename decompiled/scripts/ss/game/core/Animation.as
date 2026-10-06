package ss.game.core
{
   import ss.game.Game;
   
   public class Animation extends Renderer
   {
      
      public function Animation()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Engine.ENGINE_PAUSED,Engine.ENGINE_UNPAUSED);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Engine.ENGINE_PAUSED:
               this.handlePaused();
               break;
            case Engine.ENGINE_UNPAUSED:
               this.handleUnpaused();
         }
      }
      
      protected function handlePaused() : void
      {
      }
      
      protected function handleUnpaused() : void
      {
      }
   }
}

