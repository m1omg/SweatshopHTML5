package ss.game.components
{
   import ss.KeyCodes;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.core.IMessageReceiver;
   import ss.game.entities.Belt;
   
   public class BeltController extends Component implements IMessageReceiver
   {
      
      private var _fastForward:Boolean;
      
      public function BeltController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Commands.TOGGLE_BELT_SPEED,Commands.SLOW_BELT,Commands.STOP_BELT,Messages.FAST_FORWARDED,Messages.PRESS_KEY);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         var _loc3_:Belt = entity as Belt;
         switch(param1)
         {
            case Commands.TOGGLE_BELT_SPEED:
               _loc3_.toggle();
               break;
            case Commands.SLOW_BELT:
               _loc3_.slow();
               break;
            case Commands.STOP_BELT:
               _loc3_.stop();
               break;
            case Messages.FAST_FORWARDED:
               _loc3_.fastForward();
               break;
            case Messages.PRESS_KEY:
               if(!engine.paused && param2.keyCode == KeyCodes.SPACE && (_loc3_.speedSetting == Belt.SLOW || _loc3_.speedSetting == Belt.FAST))
               {
                  Game.messenger.broadcast(Commands.TOGGLE_BELT_SPEED);
               }
         }
      }
   }
}

