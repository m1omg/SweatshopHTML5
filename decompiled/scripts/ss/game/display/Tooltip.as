package ss.game.display
{
   import flash.display.Sprite;
   import org.fatlib.interfaces.IDestroyable;
   import ss.game.core.IMessageReceiver;
   
   public class Tooltip extends Sprite implements IDestroyable, IMessageReceiver
   {
      
      public function Tooltip()
      {
         super();
      }
      
      public function destroy() : void
      {
      }
      
      public function receiveMessage(param1:String, param2:Object) : void
      {
      }
   }
}

