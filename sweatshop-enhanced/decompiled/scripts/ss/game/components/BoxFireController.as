package ss.game.components
{
   import ss.Values;
   import ss.game.core.ThinkingComponent;
   import ss.game.entities.Environment;
   import ss.game.entities.MapEntity;
   
   public class BoxFireController extends ThinkingComponent
   {
      
      public function BoxFireController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         interval = 1;
         (entity as MapEntity).flammability = Values.BOX_FLAMMABILITY;
      }
      
      override protected function think() : void
      {
         var _loc1_:Environment = engine.find("environment") as Environment;
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:Number = _loc1_.getValue(Environment.FIRE_RISK,entity.position.x,entity.position.y);
         if(_loc2_ == 0)
         {
            return;
         }
         if(Math.random() < _loc2_ / 100 * interval)
         {
            (entity as MapEntity).ignite();
         }
      }
   }
}

