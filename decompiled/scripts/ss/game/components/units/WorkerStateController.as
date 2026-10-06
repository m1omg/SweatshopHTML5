package ss.game.components.units
{
   import org.fatlib.utils.ArrayUtils;
   import ss.Values;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Entity;
   import ss.game.core.ThinkingComponent;
   import ss.game.entities.Environment;
   import ss.game.entities.MapEntity;
   import ss.game.entities.Unit;
   import ss.game.entities.Worker;
   
   public class WorkerStateController extends ThinkingComponent
   {
      
      private var _removeTime:int = -1;
      
      public function WorkerStateController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         interval = 0.25;
         this.updateState();
         this.updateEnvironmentModifiers();
         Game.messenger.register(this,Messages.ENVIRONMENT_CHANGED,Messages.FEATURE_ACTIVATED,Messages.FAST_FORWARDED);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         var _loc3_:Array = null;
         switch(param1)
         {
            case Entity.ON_STATE_CHANGED:
               this.updateState();
               break;
            case Messages.ENVIRONMENT_CHANGED:
               this.updateEnvironmentModifiers();
               break;
            case Messages.FEATURE_ACTIVATED:
               _loc3_ = param2.workers;
               if(Boolean(_loc3_) && ArrayUtils.contains(_loc3_,entity.id))
               {
                  entity.broadcastLocalMessage(Worker.ON_EFFECTED,{"type":param2.primaryEffectType});
               }
               break;
            case Messages.FAST_FORWARDED:
               if(this.worker.state == Unit.NORMAL_STATE && parseInt(Game.level.key) >= 4)
               {
                  this.worker.changeState(Worker.LEVEL_DONE_STATE);
               }
         }
      }
      
      private function updateEnvironmentModifiers() : void
      {
         var _loc1_:Environment = engine.resolveReference(this.worker.environmentRef);
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:int = this.worker.position.x;
         var _loc3_:int = this.worker.position.y;
         this.worker.skillModifier = _loc1_.getValue(Environment.SKILL_MODIFIER,_loc2_,_loc3_);
         this.worker.staminaModifier = _loc1_.getValue(Environment.STAMINA_MODIFIER,_loc2_,_loc3_);
         this.worker.extraRechargeModifier = _loc1_.getValue(Environment.RECHARGE_MODIFIER,_loc2_,_loc3_);
         this.worker.cashBonusModifier = _loc1_.getValue(Environment.CASH_BONUS,_loc2_,_loc3_);
      }
      
      override protected function think() : void
      {
         if(this._removeTime > -1 && engine.timer.elapsed > this._removeTime)
         {
            Game.factory.removeDeployable(entity.id);
         }
      }
      
      private function updateState() : void
      {
         switch(entity.state)
         {
            case Worker.DEAD_EXHAUSTION_STATE:
            case MapEntity.SOOT_STATE:
            case MapEntity.BURNING_STATE:
               this.worker.flammability = 0;
               break;
            case Worker.DISMISSED_STATE:
               this.worker.flammability = 0;
               this._removeTime = engine.timer.elapsed + Values.WORKER_FIRED_ANIMATION_TIME;
               break;
            case Worker.LEVEL_DONE_STATE:
               this.worker.flammability = 0;
               break;
            default:
               this.worker.flammability = Values.WORKER_FLAMMABILITY;
         }
      }
      
      private function get worker() : Worker
      {
         return entity as Worker;
      }
   }
}

