package ss.game.components
{
   import flash.geom.Point;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Entity;
   import ss.game.core.ThinkingComponent;
   import ss.game.entities.Environment;
   import ss.game.entities.Item;
   import ss.game.entities.Map;
   import ss.game.entities.MapEntity;
   
   public class EnvironmentFireController extends ThinkingComponent
   {
      
      public function EnvironmentFireController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         interval = 0.25;
         Game.messenger.register(this,Messages.ENVIRONMENT_CHANGED);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         var _loc3_:MapEntity = null;
         switch(param1)
         {
            case Messages.ENVIRONMENT_CHANGED:
               this.checkExtinguishes();
         }
      }
      
      override protected function think() : void
      {
         var _loc6_:MapEntity = null;
         var _loc7_:Point = null;
         var _loc8_:Point = null;
         var _loc9_:String = null;
         var _loc10_:Item = null;
         var _loc11_:MapEntity = null;
         var _loc1_:Map = engine.find("map") as Map;
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         var _loc4_:Vector.<Entity> = engine.findByClass(MapEntity);
         var _loc5_:Vector.<Entity> = engine.findByClass(Item);
         for each(_loc6_ in _loc4_)
         {
            if(_loc6_.state == MapEntity.BURNING_STATE)
            {
               for each(_loc7_ in [new Point(-1,0),new Point(1,0),new Point(0,-1),new Point(0,1)])
               {
                  _loc8_ = _loc6_.position.add(_loc7_);
                  _loc9_ = _loc1_.getDeployableIDAt(_loc8_);
                  if(_loc9_ !== "")
                  {
                     _loc11_ = engine.find(_loc9_) as MapEntity;
                     if((Boolean(_loc11_)) && _loc11_.state != MapEntity.BURNING_STATE)
                     {
                        if(Math.random() < _loc11_.flammability * interval)
                        {
                           _loc3_.push(_loc11_);
                        }
                     }
                  }
                  for each(_loc10_ in _loc5_)
                  {
                     if(_loc10_.position.equals(_loc8_))
                     {
                        if(Math.random() < _loc10_.flammability * interval)
                        {
                           _loc3_.push(_loc10_);
                        }
                     }
                  }
               }
               if(engine.timer.elapsed > _loc6_.burnEndTime)
               {
                  this.extinguish(_loc6_);
               }
            }
         }
         for each(_loc11_ in _loc3_)
         {
            _loc11_.ignite();
         }
      }
      
      private function extinguish(param1:MapEntity) : void
      {
         param1.changeState(MapEntity.SOOT_STATE);
      }
      
      private function checkExtinguishes() : void
      {
         var _loc3_:MapEntity = null;
         var _loc1_:Environment = engine.find("environment") as Environment;
         var _loc2_:Vector.<Entity> = engine.findByClass(MapEntity);
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.state == MapEntity.BURNING_STATE)
            {
               if(_loc1_.getValue(Environment.FIRE_RISK,_loc3_.position.x,_loc3_.position.y) <= 0)
               {
                  this.extinguish(_loc3_);
               }
            }
         }
      }
      
      private function get environment() : Environment
      {
         return entity as Environment;
      }
   }
}

