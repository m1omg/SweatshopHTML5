package ss.game.entities
{
   import flash.geom.Point;
   import org.fatlib.struct.Grid;
   import ss.Values;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Entity;
   import ss.utils.Compression;
   
   public class Belt extends Entity
   {
      
      public static const UP:String = "u";
      
      public static const DOWN:String = "d";
      
      public static const LEFT:String = "l";
      
      public static const RIGHT:String = "r";
      
      public static const NONE:String = "x";
      
      public static const UNKNOWN:String = "?";
      
      public static const STOPPED:String = "stopped";
      
      public static const SLOW:String = "slow";
      
      public static const FAST:String = "fast";
      
      public static const FAST_FORWARD:String = "fast_forward";
      
      public var startNodes:Object;
      
      public var endNodes:Object;
      
      public var length:int;
      
      private var _directionGrid:Grid;
      
      private var _directions:Object;
      
      private var _speed:Number;
      
      private var _speedSetting:String;
      
      public function Belt()
      {
         super();
      }
      
      public function get width() : int
      {
         return this._directionGrid.width;
      }
      
      public function get height() : int
      {
         return this._directionGrid.height;
      }
      
      override public function prepare() : void
      {
         this._directionGrid = new Grid(Game.level.mapWidth,Game.level.mapHeight);
         this._directionGrid.fill(NONE);
         this._directions = new Object();
         this._directions[UP] = new Point(0,-1);
         this._directions[DOWN] = new Point(0,1);
         this._directions[LEFT] = new Point(-1,0);
         this._directions[RIGHT] = new Point(1,0);
         this._directions[NONE] = new Point(0,0);
         this.startNodes = {
            1:new Point(-1,-1),
            2:new Point(-1,-1)
         };
         this.endNodes = {
            1:new Point(-1,-1),
            2:new Point(-1,-1)
         };
         this.slow();
      }
      
      public function setDirection(param1:Point, param2:String) : void
      {
         this._directionGrid.setCell(param1.x,param1.y,param2);
      }
      
      public function getDirection(param1:Point) : String
      {
         if(this._directionGrid.getCell(param1.x,param1.y))
         {
            return this._directionGrid.getCell(param1.x,param1.y);
         }
         return NONE;
      }
      
      public function getMotionVector(param1:Point) : Point
      {
         var _loc2_:String = this._directionGrid.getCell(param1.x,param1.y);
         if(_loc2_ == null)
         {
            _loc2_ = NONE;
         }
         return this._directions[_loc2_];
      }
      
      public function get directions() : Object
      {
         return this._directions;
      }
      
      public function stop(param1:Boolean = false) : void
      {
         this._speedSetting = STOPPED;
         this._speed = 0;
         Game.messenger.broadcast(Messages.BELT_SPEED_CHANGED,{
            "speed":this._speedSetting,
            "byUser":param1
         });
      }
      
      public function slow(param1:Boolean = false) : void
      {
         this._speedSetting = SLOW;
         this._speed = Values.SLOW_BELT_SPEED;
         Game.messenger.broadcast(Messages.BELT_SPEED_CHANGED,{
            "speed":this._speedSetting,
            "byUser":param1
         });
      }
      
      public function fast(param1:Boolean = false) : void
      {
         this._speed = Values.FAST_BELT_SPEED;
         this._speedSetting = FAST;
         Game.messenger.broadcast(Messages.BELT_SPEED_CHANGED,{
            "speed":this._speedSetting,
            "byUser":param1
         });
      }
      
      public function fastForward() : void
      {
         this._speed = Values.FAST_BELT_SPEED;
         this._speedSetting = FAST_FORWARD;
         Game.messenger.broadcast(Messages.BELT_SPEED_CHANGED,{"speed":this._speedSetting});
      }
      
      public function toggle() : void
      {
         if(this._speedSetting == STOPPED || this._speedSetting == FAST)
         {
            this.slow(true);
         }
         else
         {
            this.fast(true);
         }
      }
      
      public function get speed() : Number
      {
         return this._speed;
      }
      
      public function get speedSetting() : String
      {
         return this._speedSetting;
      }
      
      public function save() : Object
      {
         var _loc4_:int = 0;
         var _loc1_:Object = {};
         var _loc2_:String = "";
         var _loc3_:int = 0;
         while(_loc3_ < this._directionGrid.width)
         {
            _loc4_ = 0;
            while(_loc4_ < this._directionGrid.height)
            {
               _loc2_ += this._directionGrid.getCell(_loc3_,_loc4_);
               _loc4_++;
            }
            _loc3_++;
         }
         _loc1_["tiles"] = Compression.compress(_loc2_);
         _loc1_["nodes"] = {
            "start":{
               1:{
                  "x":this.startNodes[1].x,
                  "y":this.startNodes[1].y
               },
               2:{
                  "x":this.startNodes[2].x,
                  "y":this.startNodes[2].y
               }
            },
            "end":{
               1:{
                  "x":this.endNodes[1].x,
                  "y":this.endNodes[1].y
               },
               2:{
                  "x":this.endNodes[2].x,
                  "y":this.endNodes[2].y
               }
            }
         };
         return _loc1_;
      }
      
      public function load(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc2_:String = Compression.uncompress(param1["tiles"]);
         var _loc3_:* = 0;
         var _loc4_:int = 0;
         while(_loc4_ < this._directionGrid.width)
         {
            _loc5_ = 0;
            while(_loc5_ < this._directionGrid.height)
            {
               this._directionGrid.setCell(_loc4_,_loc5_,_loc2_.charAt(_loc3_++));
               _loc5_++;
            }
            _loc4_++;
         }
         if(param1["start"])
         {
            this.startNodes[1].x = param1["start"].x;
            this.startNodes[1].y = param1["start"].y;
            this.startNodes[2].x = -1;
            this.startNodes[2].y = -1;
         }
         else
         {
            this.startNodes[1].x = param1["nodes"]["start"][1].x;
            this.startNodes[1].y = param1["nodes"]["start"][1].y;
            this.startNodes[2].x = param1["nodes"]["start"][2].x;
            this.startNodes[2].y = param1["nodes"]["start"][2].y;
         }
         if(param1["end"])
         {
            this.endNodes[1].x = param1["end"].x;
            this.endNodes[1].y = param1["end"].y;
            this.endNodes[2].x = -1;
            this.endNodes[2].y = -1;
         }
         else
         {
            this.endNodes[1].x = param1["nodes"]["end"][1].x;
            this.endNodes[1].y = param1["nodes"]["end"][1].y;
            this.endNodes[2].x = param1["nodes"]["end"][2].x;
            this.endNodes[2].y = param1["nodes"]["end"][2].y;
         }
      }
      
      public function shift(param1:int, param2:int) : void
      {
         var _loc5_:String = null;
         var _loc6_:Point = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc3_:Grid = new Grid(this._directionGrid.width,this._directionGrid.height);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.width)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc3_.height)
            {
               _loc3_.setCell(_loc4_,_loc8_,this._directionGrid.getCell(_loc4_,_loc8_));
               _loc8_++;
            }
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc3_.width)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc3_.height)
            {
               _loc9_ = _loc3_.getCell(_loc4_ - param1,_loc8_ - param2);
               if(!_loc9_)
               {
                  _loc9_ = NONE;
               }
               this._directionGrid.setCell(_loc4_,_loc8_,_loc9_);
               _loc8_++;
            }
            _loc4_++;
         }
         var _loc7_:Point = new Point(param1,param2);
         for(_loc5_ in this.startNodes)
         {
            this.startNodes[_loc5_] = this.startNodes[_loc5_].add(_loc7_);
         }
         for(_loc5_ in this.endNodes)
         {
            this.endNodes[_loc5_] = this.endNodes[_loc5_].add(_loc7_);
         }
      }
      
      private function getOppositeDirection(param1:String) : String
      {
         var _loc2_:String = param1;
         switch(param1)
         {
            case LEFT:
               _loc2_ = RIGHT;
               break;
            case RIGHT:
               _loc2_ = LEFT;
               break;
            case UP:
               _loc2_ = DOWN;
               break;
            case DOWN:
               _loc2_ = UP;
         }
         return _loc2_;
      }
      
      public function getTileSprite(param1:Point) : String
      {
         var _loc2_:Boolean = this.getDirection(param1.add(new Point(0,-1))) != NONE;
         var _loc3_:Boolean = this.getDirection(param1.add(new Point(0,1))) != NONE;
         var _loc4_:Boolean = this.getDirection(param1.add(new Point(1,0))) != NONE;
         var _loc5_:Boolean = this.getDirection(param1.add(new Point(-1,0))) != NONE;
         var _loc6_:String = "NS";
         if(_loc4_ && _loc5_)
         {
            _loc6_ = "EW";
         }
         if(_loc2_ && _loc5_)
         {
            _loc6_ = "NW";
         }
         if(_loc2_ && _loc4_)
         {
            _loc6_ = "NE";
         }
         if(_loc3_ && _loc5_)
         {
            _loc6_ = "SW";
         }
         if(_loc3_ && _loc4_)
         {
            _loc6_ = "SE";
         }
         if(_loc2_ && _loc4_ && _loc5_)
         {
            _loc6_ = "Special1";
         }
         if(_loc3_ && _loc4_ && _loc5_)
         {
            _loc6_ = "Special2";
         }
         return _loc6_;
      }
      
      public function isStartNode(param1:Point) : Boolean
      {
         var _loc2_:Point = null;
         for each(_loc2_ in this.startNodes)
         {
            if(_loc2_.equals(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      public function isEndNode(param1:Point) : Boolean
      {
         var _loc2_:Point = null;
         for each(_loc2_ in this.endNodes)
         {
            if(_loc2_.equals(param1))
            {
               return true;
            }
         }
         return false;
      }
   }
}

