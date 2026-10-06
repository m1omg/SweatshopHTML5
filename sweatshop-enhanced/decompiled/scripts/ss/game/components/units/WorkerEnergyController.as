package ss.game.components.units
{
   import ss.Values;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.entities.Belt;
   import ss.game.entities.Environment;
   import ss.game.entities.Unit;
   import ss.game.entities.Worker;
   
   public class WorkerEnergyController extends Component
   {
      
      public function WorkerEnergyController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         this.worker.tirednessStrikes = 0;
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Worker.ON_EFFECTED:
               if(param2.type == Environment.RECHARGE_MODIFIER && this.worker.energy < Values.SAD_ENERGY_THRESHOLD)
               {
                  Game.messenger.broadcast(Messages.TIRED_WORKER_REFRESHED);
                  this.worker.energy = Values.SAD_SKILL_MULTIPLIER;
               }
         }
      }
      
      override public function update(param1:Number) : void
      {
         if(this.worker.energy < Values.SAD_ENERGY_THRESHOLD)
         {
            this.worker.skillTirednessMultiplier = Values.SAD_SKILL_MULTIPLIER;
         }
         else
         {
            this.worker.skillTirednessMultiplier = 1;
         }
         switch(this.worker.state)
         {
            case Unit.NORMAL_STATE:
               this.normalStateUpdate(param1);
               break;
            case Worker.TIRED_STATE:
               this.tiredStateUpdate(param1);
               break;
            case Worker.EXHAUSTED_STATE:
               this.exhaustedStateUpdate(param1);
         }
      }
      
      private function normalStateUpdate(param1:Number) : void
      {
         this.applyEnvironmentRecharge(param1);
         if(this.worker.isWorking)
         {
            this.tire(param1);
         }
         else
         {
            this.recharge(param1);
         }
         if(this.worker.energy <= 0)
         {
            if(this.worker.tirednessStrikes >= Values.MAX_TIREDNESS_STRIKES)
            {
               this.worker.changeState(Worker.EXHAUSTED_STATE);
               this.worker.dieFromExhaustionTime = engine.timer.elapsed + Values.WORKER_EXHAUSTED_TIME;
            }
            else
            {
               this.worker.changeState(Worker.TIRED_STATE);
               ++this.worker.tirednessStrikes;
            }
         }
         else if(this.worker.energy > Values.CANCEL_TIREDNESS_COUNT_ENERGY_THRESHOLD)
         {
            this.worker.tirednessStrikes = 0;
         }
      }
      
      private function tiredStateUpdate(param1:Number) : void
      {
         this.applyEnvironmentRecharge(param1);
         this.recharge(param1);
         if(this.worker.energy > Values.SAD_ENERGY_THRESHOLD)
         {
            this.worker.changeState(Unit.NORMAL_STATE);
         }
      }
      
      private function exhaustedStateUpdate(param1:Number) : void
      {
         this.applyEnvironmentRecharge(param1);
         if(this.worker.energy > Values.SAD_ENERGY_THRESHOLD)
         {
            this.worker.changeState(Unit.NORMAL_STATE);
         }
         else if(engine.timer.elapsed > this.worker.dieFromExhaustionTime)
         {
            this.worker.changeState(Worker.DEAD_EXHAUSTION_STATE);
         }
      }
      
      private function tire(param1:Number) : void
      {
         var _loc2_:Number = Values.ENERGY_MT * (this.worker.stamina + this.worker.staminaModifier) + Values.ENERGY_T0;
         var _loc3_:Belt = engine.find("belt") as Belt;
         if(Boolean(_loc3_) && _loc3_.speedSetting == Belt.FAST)
         {
            _loc2_ *= Values.FAST_BELT_SPEED / Values.SLOW_BELT_SPEED;
         }
         this.worker.adjustEnergy(_loc2_ * this.worker.skillTirednessMultiplier * param1);
      }
      
      private function applyEnvironmentRecharge(param1:Number) : void
      {
         this.worker.adjustEnergy(this.worker.extraRechargeModifier * param1);
      }
      
      private function recharge(param1:Number) : void
      {
         var _loc2_:Number = Values.ENERGY_MR * (this.worker.stamina + this.worker.staminaModifier) + Values.ENERGY_R0;
         this.worker.adjustEnergy(_loc2_ * param1);
      }
      
      private function get worker() : Worker
      {
         return entity as Worker;
      }
   }
}

