package ss.game.components
{
   import flash.geom.Point;
   import org.fatlib.Log;
   import org.fatlib.struct.Grid;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.core.IMessageReceiver;
   import ss.game.entities.Belt;
   import ss.game.entities.Unit;
   import ss.game.entities.Worker;
   import ss.game.factory.EntityFactory;
   
   public class BeltInfoController extends Component implements IMessageReceiver
   {
      
      private var _grid:Grid;
      
      private var _longestBeltLength:int = 0;
      
      public function BeltInfoController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         super.prepare();
         this._grid = new Grid(Game.level.mapWidth,Game.level.mapHeight);
         this._grid.fill(0);
         this.refresh();
         Game.messenger.register(this,Messages.DEPLOYABLE_ADDED,Messages.DEPLOYABLE_REMOVED,Messages.WORKER_STATE_CHANGED);
      }
      
      public function getPackerDownstreamOf(param1:Point) : Boolean
      {
         return this._grid.getCell(param1.x,param1.y) == 1;
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Messages.DEPLOYABLE_ADDED:
            case Messages.WORKER_STATE_CHANGED:
            case Messages.DEPLOYABLE_REMOVED:
               this.refresh();
         }
      }
      
      public function refresh() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:Worker = null;
         this._grid.fill(0);
         var _loc3_:Grid = new Grid(Game.level.mapWidth,Game.level.mapHeight);
         _loc3_.fill(0);
         for each(_loc4_ in engine.findByClass(Worker))
         {
            if(_loc4_.type == EntityFactory.PACKER && _loc4_.state == Unit.NORMAL_STATE)
            {
               _loc1_ = -1;
               while(_loc1_ <= 1)
               {
                  _loc2_ = -1;
                  while(_loc2_ <= 1)
                  {
                     _loc3_.setCell(_loc4_.position.x + _loc1_,_loc4_.position.y + _loc2_,1);
                     _loc2_++;
                  }
                  _loc1_++;
               }
            }
         }
         this.compute(this.belt.endNodes[1],_loc3_);
         if(this.belt.endNodes[2])
         {
            this.compute(this.belt.endNodes[2],_loc3_);
         }
         Log.log("[BeltInfoController] belt length=" + this._longestBeltLength);
         this.belt.length = this._longestBeltLength;
         Game.messenger.broadcast(Messages.BELT_LENGTH_CALCULATED,{"length":this.belt.length});
      }
      
      private function compute(param1:Point, param2:Grid, param3:Boolean = false, param4:int = 1) : Boolean
      {
         var _loc7_:Array = null;
         var _loc8_:Point = null;
         if(param4 > this._longestBeltLength)
         {
            this._longestBeltLength = param4;
         }
         var _loc5_:Point = param1;
         var _loc6_:Boolean = false;
         do
         {
            if(param2.getCell(_loc5_.x,_loc5_.y) == 1)
            {
               param3 = true;
            }
            if(param3)
            {
               this._grid.setCell(_loc5_.x,_loc5_.y,1);
            }
            if(this.belt.isStartNode(_loc5_))
            {
               _loc6_ = true;
            }
            else
            {
               _loc7_ = this.getAllPointingTo(_loc5_);
               if(_loc7_.length == 0)
               {
                  _loc6_ = true;
               }
               else
               {
                  for each(_loc8_ in _loc7_)
                  {
                     _loc6_ = this.compute(_loc8_,param2,param3,param4 + 1);
                  }
               }
            }
         }
         while(!_loc6_);
         return _loc6_;
      }
      
      private function getAllPointingTo(param1:Point) : Array
      {
         var _loc4_:Array = null;
         var _loc5_:Point = null;
         var _loc2_:Array = [];
         var _loc3_:Array = [[-1,0,Belt.RIGHT],[1,0,Belt.LEFT],[0,-1,Belt.DOWN],[0,1,Belt.UP]];
         for each(_loc4_ in _loc3_)
         {
            _loc5_ = new Point(param1.x + _loc4_[0],param1.y + _loc4_[1]);
            if(this.belt.getDirection(_loc5_) == _loc4_[2])
            {
               _loc2_.push(_loc5_);
            }
         }
         return _loc2_;
      }
      
      private function get belt() : Belt
      {
         return entity as Belt;
      }
   }
}

