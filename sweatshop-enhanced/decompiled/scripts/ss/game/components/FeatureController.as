package ss.game.components
{
   import flash.geom.Point;
   import org.fatlib.utils.ArrayUtils;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.core.Entity;
   import ss.game.core.IMessageReceiver;
   import ss.game.entities.Feature;
   import ss.game.entities.Map;
   import ss.game.entities.Worker;
   
   public class FeatureController extends Component implements IMessageReceiver
   {
      
      private var _deactivateTime:Number;
      
      public function FeatureController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Point = null;
         var _loc7_:String = null;
         var _loc8_:Entity = null;
         this.feature.effectedTiles = [];
         this.feature.effectedWorkers = [];
         this.feature.effectedWorkerTiles = [];
         var _loc1_:int = this.feature.range;
         var _loc2_:Map = engine.resolveReference(this.feature.mapRef) as Map;
         var _loc3_:int = -_loc1_;
         while(_loc3_ <= _loc1_)
         {
            _loc4_ = -_loc1_;
            while(_loc4_ <= _loc1_)
            {
               _loc5_ = _loc3_ * _loc3_ + _loc4_ * _loc4_;
               if(_loc5_ < _loc1_ * _loc1_)
               {
                  _loc6_ = new Point(this.feature.position.x + _loc3_,this.feature.position.y + _loc4_);
                  this.feature.effectedTiles.push(_loc6_);
                  _loc7_ = _loc2_.getDeployableIDAt(_loc6_);
                  if(_loc7_)
                  {
                     _loc8_ = engine.find(_loc7_);
                     if(_loc8_ is Worker)
                     {
                        this.feature.effectedWorkers.push(_loc7_);
                        this.feature.effectedWorkerTiles.push(_loc6_);
                     }
                  }
               }
               _loc4_++;
            }
            _loc3_++;
         }
         Game.messenger.register(this,Commands.ACTIVATE_FEATURE,Messages.DEPLOYABLE_ADDED,Messages.DEPLOYABLE_REMOVED);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Commands.ACTIVATE_FEATURE:
               if(param2.id == entity.id)
               {
                  this.activate();
               }
               break;
            case Messages.DEPLOYABLE_ADDED:
               this.handleDeployableAdded(param2.id,param2.tile);
               break;
            case Messages.DEPLOYABLE_REMOVED:
               this.handleDeployableRemoved(param2.id,param2.tile);
         }
      }
      
      private function handleDeployableAdded(param1:String, param2:Point) : void
      {
         if(!this.inRange(param2))
         {
            return;
         }
         var _loc3_:Entity = engine.find(param1);
         if(_loc3_ is Worker)
         {
            this.feature.effectedWorkers.push(param1);
            this.feature.effectedWorkerTiles.push(param2.clone());
            entity.broadcastLocalMessage(Feature.ON_EFFECTED_WORKERS_CHANGED);
            if(this.feature.isAmbient)
            {
               this.broadcastActivated([_loc3_.id]);
            }
         }
      }
      
      private function handleDeployableRemoved(param1:String, param2:Point) : void
      {
         if(ArrayUtils.contains(this.feature.effectedWorkers,param1))
         {
            ArrayUtils.remove(this.feature.effectedWorkers,param1);
            ArrayUtils.remove(this.feature.effectedWorkerTiles,param2);
            entity.broadcastLocalMessage(Feature.ON_EFFECTED_WORKERS_CHANGED);
         }
      }
      
      private function inRange(param1:Point) : Boolean
      {
         var _loc2_:int = param1.x - entity.position.x;
         var _loc3_:int = param1.y - entity.position.y;
         return _loc2_ * _loc2_ + _loc3_ * _loc3_ < this.feature.range * this.feature.range;
      }
      
      override public function update(param1:Number) : void
      {
         if(this.feature.isAmbient)
         {
            if(!this.feature.isActivated)
            {
               this.activate();
            }
         }
         else if(this.feature.isActivated && engine.timer.elapsed >= this._deactivateTime)
         {
            this.deactivate();
         }
      }
      
      private function activate() : void
      {
         this.feature.isActivated = true;
         if(!this.feature.isAmbient)
         {
            this._deactivateTime = engine.timer.elapsed + this.feature.duration;
         }
         this.broadcastActivated(this.feature.effectedWorkers);
      }
      
      private function broadcastActivated(param1:Array) : void
      {
         Game.messenger.broadcast(Messages.FEATURE_ACTIVATED,{
            "id":entity.id,
            "type":this.feature.type,
            "workers":param1,
            "primaryEffectType":this.feature.getPrimaryEffectType()
         });
      }
      
      private function deactivate() : void
      {
         this.feature.isActivated = false;
         Game.messenger.broadcast(Messages.FEATURE_DEACTIVATED,{"id":entity.id});
      }
      
      private function get feature() : Feature
      {
         return entity as Feature;
      }
   }
}

