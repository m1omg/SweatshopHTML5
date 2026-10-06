package ss.game.components
{
   import org.fatlib.Log;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.core.Entity;
   import ss.game.core.IMessageReceiver;
   import ss.game.entities.Feature;
   import ss.game.entities.FireHazard;
   import ss.game.entities.Map;
   import ss.game.entities.MapEntity;
   import ss.game.entities.Officer;
   import ss.game.entities.Worker;
   
   public class MapUpdater extends Component implements IMessageReceiver
   {
      
      public function MapUpdater()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Messages.DEPLOYABLE_ADDED,Messages.DEPLOYABLE_REMOVED,Commands.FORCE_UPDATE_ENTIRE_MAP);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Messages.DEPLOYABLE_ADDED:
               this.map.addDeployable(param2.tile,param2.id);
               break;
            case Messages.DEPLOYABLE_REMOVED:
               this.map.removeDeployable(param2.tile);
               break;
            case Commands.FORCE_UPDATE_ENTIRE_MAP:
               this.updateEntireMap();
         }
      }
      
      private function updateEntireMap() : void
      {
         var _loc2_:MapEntity = null;
         Log.log("[MapUpdater] updating entire map... expensive!");
         var _loc1_:Vector.<Entity> = engine.findByClass(MapEntity);
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_ is Worker || _loc2_ is Feature || _loc2_ is Officer || _loc2_.category == "box" || _loc2_ is FireHazard)
            {
               this.map.addDeployable(_loc2_.position,_loc2_.id);
            }
         }
      }
      
      private function get map() : Map
      {
         return entity as Map;
      }
   }
}

