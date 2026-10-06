package ss.game.entities
{
   import flash.geom.Point;
   import ss.Values;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Entity;
   
   public class MapEntity extends Entity
   {
      
      public static const BURNING_STATE:String = "BURNING_STATE";
      
      public static const SOOT_STATE:String = "SOOT_STATE";
      
      public var category:String;
      
      public var type:String;
      
      public var key:String;
      
      public var renderOffset:Point = new Point();
      
      public var flammability:Number = 0;
      
      public var burnEndTime:Number;
      
      public var environmentRef:String;
      
      public var mapRef:String;
      
      public var selectable:Boolean = true;
      
      public function MapEntity()
      {
         super();
      }
      
      public function remove() : void
      {
         Game.factory.removeDeployable(id);
      }
      
      public function ignite() : void
      {
         var _loc1_:Environment = engine.resolveReference(this.environmentRef) as Environment;
         if(_loc1_.getValue(Environment.FIRE_RISK,position.x,position.y) <= 0)
         {
            return;
         }
         if(this.flammability == 0)
         {
            return;
         }
         this.burnEndTime = engine.timer.elapsed + Values.BURN_TIME;
         this.flammability = 0;
         changeState(MapEntity.BURNING_STATE);
         Game.messenger.broadcast(Messages.FIRE_STARTED);
      }
   }
}

