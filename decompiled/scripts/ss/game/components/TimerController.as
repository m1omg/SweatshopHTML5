package ss.game.components
{
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.core.Component;
   
   public class TimerController extends Component
   {
      
      public function TimerController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Commands.START_TIMER,Commands.STOP_TIMER);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Commands.START_TIMER:
               Game.engine.timer.start();
               break;
            case Commands.STOP_TIMER:
               Game.engine.timer.stop();
         }
      }
   }
}

