package ss.game.entities
{
   import flash.geom.Point;
   import org.fatlib.struct.Grid;
   import ss.game.Game;
   import ss.game.core.Entity;
   import ss.utils.Utils;
   
   public class Map extends Entity
   {
      
      private var _deployables:Grid;
      
      private var _belt:Grid;
      
      private var _nodes:Array;
      
      public function Map()
      {
         super();
      }
      
      override public function prepare() : void
      {
         this._deployables = new Grid(Game.level.mapWidth,Game.level.mapHeight);
         this._deployables.fill("");
         this._belt = new Grid(Game.level.mapWidth,Game.level.mapHeight);
         this._belt.fill(0);
         this._nodes = [];
      }
      
      public function get width() : int
      {
         return Game.level.mapWidth;
      }
      
      public function get height() : int
      {
         return Game.level.mapHeight;
      }
      
      public function addDeployable(param1:Point, param2:String) : void
      {
         this._deployables.setCell(param1.x,param1.y,param2);
      }
      
      public function removeDeployable(param1:Point) : void
      {
         this._deployables.setCell(param1.x,param1.y,"");
      }
      
      public function addBelt(param1:Point) : void
      {
         this._belt.setCell(param1.x,param1.y,1);
      }
      
      public function addBeltNode(param1:Point, param2:String, param3:Boolean) : void
      {
         if(!Utils.isActiveTile(param1,Game.level.world))
         {
            return;
         }
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         this._nodes.push(param1);
         var _loc8_:String = "n";
         if(param2 == Belt.DOWN)
         {
            _loc8_ = "s";
         }
         else if(param2 == Belt.LEFT)
         {
            if(param3)
            {
               _loc8_ = "w";
            }
            else
            {
               _loc8_ = "e";
            }
         }
         else if(param2 == Belt.RIGHT)
         {
            if(param3)
            {
               _loc8_ = "e";
            }
            else
            {
               _loc8_ = "w";
            }
         }
         switch(_loc8_)
         {
            case "n":
            case "s":
               this.setNodeTile(param1,-1,0,_loc8_);
               this.setNodeTile(param1,0,0,_loc8_);
               this.setNodeTile(param1,0,-1,_loc8_);
               this.setNodeTile(param1,1,0,_loc8_);
               break;
            case "w":
               this.setNodeTile(param1,0,0,_loc8_);
               this.setNodeTile(param1,0,-1,_loc8_);
               this.setNodeTile(param1,1,0,_loc8_);
               this.setNodeTile(param1,1,-1,_loc8_);
               break;
            case "e":
               this.setNodeTile(param1,-1,0,_loc8_);
               this.setNodeTile(param1,-1,-1,_loc8_);
               this.setNodeTile(param1,0,0,_loc8_);
               this.setNodeTile(param1,0,-1,_loc8_);
         }
      }
      
      public function setNodeTile(param1:Point, param2:int, param3:int, param4:String = null) : void
      {
         this._deployables.setCell(param1.x + param2,param1.y + param3,"_node");
      }
      
      public function isEmpty(param1:Point) : Boolean
      {
         return this._deployables.getCell(param1.x,param1.y) == "" && this._belt.getCell(param1.x,param1.y) == 0;
      }
      
      public function isBeltAt(param1:Point) : Boolean
      {
         return this._belt.getCell(param1.x,param1.y) == 1;
      }
      
      public function canPlaceWorker(param1:Point) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(!this.isEmpty(param1))
         {
            return false;
         }
         var _loc2_:Boolean = false;
         _loc3_ = param1.x - 1;
         while(_loc3_ <= param1.x + 1)
         {
            _loc4_ = param1.y - 1;
            while(_loc4_ <= param1.y + 1)
            {
               if(this._belt.getCell(_loc3_,_loc4_) > 0)
               {
                  if(!this.isNode(new Point(_loc3_,_loc4_)))
                  {
                     _loc2_ = true;
                  }
               }
               _loc4_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function isNode(param1:Point) : Boolean
      {
         var _loc2_:Point = null;
         for each(_loc2_ in this._nodes)
         {
            if(_loc2_.equals(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      public function getDeployableIDAt(param1:Point) : String
      {
         return this._deployables.getCell(param1.x,param1.y);
      }
   }
}

