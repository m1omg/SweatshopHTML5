package ss.game.entities
{
   import org.fatlib.utils.ArrayUtils;
   import ss.game.Game;
   import ss.game.Messages;
   
   public class Worker extends Unit
   {
      
      public static const INJURED_STATE:String = "INJURED_STATE";
      
      public static const TIRED_STATE:String = "TIRED_STATE";
      
      public static const EXHAUSTED_STATE:String = "EXHAUSTED_STATE";
      
      public static const DEAD_EXHAUSTION_STATE:String = "DEAD_EXHAUSTION_STATE";
      
      public static const DISMISSED_STATE:String = "DISMISSED_STATE";
      
      public static const LEVEL_DONE_STATE:String = "LEVEL_DONE_STATE";
      
      public static const ON_EFFECTED:String = "ON_EFFECTED";
      
      public var isWorking:Boolean;
      
      public var stamina:Number;
      
      public var skillHat:Number;
      
      public var skillShoes:Number;
      
      public var skillShirt:Number;
      
      public var skillBag:Number;
      
      public var skillPack:Number;
      
      public var canExplode:Boolean;
      
      public var gender:String;
      
      public var skillModifier:Number;
      
      public var staminaModifier:Number;
      
      public var extraRechargeModifier:Number;
      
      public var skillTirednessMultiplier:Number;
      
      public var cashBonusModifier:Number;
      
      public var energy:Number;
      
      public var tirednessStrikes:int;
      
      public var dieFromExhaustionTime:int;
      
      public var beltRef:String;
      
      public var beltInfoRef:String;
      
      public var currentItemRef:String;
      
      public function Worker()
      {
         super();
      }
      
      override public function reset() : void
      {
         super.reset();
         this.changeState(NORMAL_STATE);
         this.energy = 100;
      }
      
      public function adjustEnergy(param1:Number) : void
      {
         this.energy += param1;
         if(this.energy > 100)
         {
            this.energy = 100;
         }
         if(this.energy < 0)
         {
            this.energy = 0;
         }
      }
      
      public function injure() : void
      {
         if(state == NORMAL_STATE && this.isWorking)
         {
            this.changeState(INJURED_STATE);
         }
      }
      
      override public function changeState(param1:String) : void
      {
         switch(param1)
         {
            case TIRED_STATE:
            case NORMAL_STATE:
            case INJURED_STATE:
               selectable = true;
               break;
            default:
               selectable = false;
         }
         super.changeState(param1);
         Game.messenger.broadcast(Messages.WORKER_STATE_CHANGED,{
            "id":id,
            "state":param1,
            "type":type,
            "gender":this.gender
         });
      }
      
      override public function remove() : void
      {
         this.changeState(DISMISSED_STATE);
      }
      
      override public function getCanLevelUpRightNow() : Boolean
      {
         return canLevelUp && ArrayUtils.contains([TIRED_STATE,NORMAL_STATE],state);
      }
   }
}

