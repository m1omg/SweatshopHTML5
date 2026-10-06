package ss.game.components
{
   import ss.Values;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.ThinkingComponent;
   import ss.game.entities.Environment;
   import ss.game.entities.FireHazard;
   
   public class FireHazardController extends ThinkingComponent
   {
      
      public function FireHazardController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         interval = 1;
         Game.messenger.register(this,Messages.DEPLOYABLE_ADDED,Messages.DEPLOYABLE_REMOVED,Messages.UNIT_UPGRADED);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         var _loc3_:Environment = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         switch(param1)
         {
            case Messages.DEPLOYABLE_ADDED:
            case Messages.DEPLOYABLE_REMOVED:
            case Messages.UNIT_UPGRADED:
               _loc3_ = engine.find("environment") as Environment;
               _loc4_ = _loc3_.getValue(Environment.FIRE_PROTECTION,entity.position.x,entity.position.y);
               _loc5_ = _loc3_.getValue(Environment.FIRE_RISK,entity.position.x,entity.position.y);
               if(_loc4_ > 0)
               {
                  this.hazard.protect();
                  this.hazard.stopSparking();
                  Game.messenger.broadcast(Messages.FEATURE_DEACTIVATED);
                  break;
               }
               this.hazard.unprotect();
         }
      }
      
      override protected function think() : void
      {
         if(!this.hazard.isProtected && !this.hazard.isSparking && Math.random() * 100 < this.hazard.activateChance && entity.age > Values.MINIMUM_HAZARD_SPARK_TIME)
         {
            this.hazard.startSparking();
            Game.messenger.broadcast(Messages.FEATURE_ACTIVATED,{"type":this.hazard.type});
         }
      }
      
      private function get hazard() : FireHazard
      {
         return entity as FireHazard;
      }
   }
}

