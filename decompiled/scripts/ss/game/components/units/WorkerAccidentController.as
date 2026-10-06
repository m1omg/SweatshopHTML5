package ss.game.components.units
{
   import ss.Values;
   import ss.game.core.Entity;
   import ss.game.core.ThinkingComponent;
   import ss.game.entities.Belt;
   import ss.game.entities.Environment;
   import ss.game.entities.Worker;
   import ss.utils.Utils;
   
   public class WorkerAccidentController extends ThinkingComponent
   {
      
      public function WorkerAccidentController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         interval = 1;
      }
      
      override protected function think() : void
      {
         var _loc1_:Entity = engine.resolveReference(this.worker.currentItemRef);
         var _loc2_:Environment = engine.resolveReference(this.worker.environmentRef);
         var _loc3_:Belt = engine.resolveReference(this.worker.beltRef);
         if(!_loc1_ || !_loc2_ || !_loc3_)
         {
            return;
         }
         var _loc4_:Number = _loc2_.getValue(Environment.ACCIDENT_RISK,_loc1_.position.x,_loc1_.position.y);
         if(_loc4_ == 0)
         {
            return;
         }
         if(_loc3_.speedSetting == Belt.FAST)
         {
            _loc4_ *= Values.FAST_BELT_SPEED / Values.SLOW_BELT_SPEED;
         }
         if(Math.random() < _loc4_ / 100 && Utils.isAdjacent(_loc1_.position,entity.position))
         {
            this.worker.injure();
         }
      }
      
      private function get worker() : Worker
      {
         return entity as Worker;
      }
   }
}

