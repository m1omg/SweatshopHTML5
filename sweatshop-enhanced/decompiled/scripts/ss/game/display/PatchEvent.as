package ss.game.display
{
   import flash.events.Event;
   
   public class PatchEvent extends Event
   {
      
      public static const ROLL_OUT:String = "onRollOut";
      
      public static const ROLL_OVER:String = "onRollOver";
      
      public static const CLICK:String = "onClick";
      
      public function PatchEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

