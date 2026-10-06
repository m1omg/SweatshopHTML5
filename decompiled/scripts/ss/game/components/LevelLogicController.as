package ss.game.components
{
   import org.fatlib.Log;
   import ss.Constants;
   import ss.Values;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.core.IMessageReceiver;
   import ss.game.entities.Sequence;
   import ss.utils.Utils;
   
   public class LevelLogicController extends Component implements IMessageReceiver
   {
      
      public var levelEnded:Boolean = false;
      
      public var fastForwardTriggered:Boolean = false;
      
      public function LevelLogicController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Messages.ITEM_DELIVERED,Messages.ITEM_REJECTED,Messages.ITEM_COMPLETED,Messages.BELT_LENGTH_CALCULATED,Messages.PRESS_KEY);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Messages.BELT_LENGTH_CALCULATED:
               this.calculateAllowedTime(param2.length);
               break;
            case Messages.ITEM_DELIVERED:
               ++Game.user.delivered;
               Log.log("[LevelLogicController] deliveries=" + Game.user.delivered);
               this.checkEnd();
               break;
            case Messages.ITEM_REJECTED:
               ++Game.user.rejected;
               Log.log("[LevelLogicController] rejected=" + Game.user.rejected);
               this.checkEnd();
               break;
            case Messages.ITEM_COMPLETED:
               ++Game.user.completed;
               Log.log("[LevelLogicController] completed=" + Game.user.completed);
               this.checkEnd();
               break;
            case Messages.PRESS_KEY:
               if(Values.DEBUG_MODE && param2.keyCode == 87)
               {
                  Game.messenger.broadcast(Commands.SKIP_DIALOG);
                  this.endLevel(true);
               }
         }
      }
      
      public function calculateAllowedTime(param1:int) : void
      {
         if(Game.level.slowestTime > 0)
         {
            return;
         }
         var _loc2_:Sequence = Game.engine.find("sequence") as Sequence;
         var _loc3_:Number = Math.ceil(_loc2_.getLastItemTime() + Game.level.extraTime + param1 / Values.FAST_BELT_SPEED);
         Game.level.slowestTime = _loc3_;
         Game.level.fastestTime = Math.ceil(_loc3_ * (Values.SLOW_BELT_SPEED / Values.FAST_BELT_SPEED));
         Log.log("[LevelLogicController] Game.level.slowestTime=" + Game.level.slowestTime);
         Log.log("[LevelLogicController] Game.level.slowestTime=" + Game.level.fastestTime);
      }
      
      private function checkEnd() : void
      {
         if(this.levelEnded)
         {
            return;
         }
         if(!this.fastForwardTriggered && Game.user.numDeadItems >= Game.level.numItems)
         {
            this.fastforwardLevel();
         }
         Log.log("[LevelLogicController] checkend delivered=" + Game.user.delivered + " rejected=" + Game.user.rejected + " complete=" + Game.user.completed + " numitems=" + Game.level.numItems + " del+rej=" + (Game.user.delivered + Game.user.rejected));
         if(Game.user.rejected >= Game.level.allowedRejections)
         {
            this.endLevel(false,Constants.TOO_MANY_REJECTIONS);
         }
         else if(Game.user.delivered + Game.user.rejected >= Game.level.numItems)
         {
            this.endLevel(true);
         }
      }
      
      override public function update(param1:Number) : void
      {
         if(Game.level.extraTime < 0 && !this.levelEnded && engine.timer.elapsed > Game.level.slowestTime)
         {
            this.endLevel(false,Constants.TIME_UP);
         }
      }
      
      private function fastforwardLevel() : void
      {
         Log.log("[LevelLogicController] FAST FORWARD!");
         this.fastForwardTriggered = true;
         Game.engine.timeScale = 5;
         Game.messenger.broadcast(Messages.FAST_FORWARDED);
      }
      
      private function endLevel(param1:Boolean, param2:String = null) : void
      {
         this.levelEnded = true;
         if(param1)
         {
            this.markWon();
         }
         else
         {
            Game.result.markLost(param2);
         }
         Game.messenger.broadcast(Messages.LEVEL_END,{"won":param1});
      }
      
      private function markWon() : void
      {
         var _loc1_:Number = Game.level.slowestTime - Game.level.fastestTime;
         var _loc2_:Number = Game.level.fastestTime + _loc1_ * (1 - Game.level.scoreFastFraction);
         var _loc3_:Number = engine.timer.elapsed - _loc2_;
         var _loc4_:Number = Game.level.slowestTime - _loc2_;
         var _loc5_:Number = 1 - _loc3_ / _loc4_;
         var _loc6_:Number = Game.user.cash / (Game.level.scoreProfitFraction * Game.level.startingCash);
         var _loc7_:Number = Game.user.completed / Game.level.numItems;
         _loc5_ = Utils.clamp(_loc5_,0,1);
         _loc6_ = Utils.clamp(_loc6_,0,1);
         _loc7_ = Utils.clamp(_loc7_,0,1);
         Game.result.markWon(_loc5_,_loc6_,_loc7_);
      }
   }
}

