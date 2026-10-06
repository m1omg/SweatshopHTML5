package ss.game.entities
{
   public class Unit extends MapEntity
   {
      
      public static const NORMAL_STATE:String = "NORMAL_STATE";
      
      public static const ON_RESET:String = "ON_RESET";
      
      public var level:int;
      
      public var canLevelUp:Boolean;
      
      public function Unit()
      {
         super();
      }
      
      public function reset() : void
      {
         broadcastLocalMessage(ON_RESET);
         changeState(NORMAL_STATE);
      }
      
      public function getCanLevelUpRightNow() : Boolean
      {
         return this.canLevelUp;
      }
   }
}

