package ss.game.components.ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import ss.Values;
   import ss.game.Commands;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Renderer;
   import ss.game.core.VisualElement;
   import ss.game.entities.DragInstance;
   import ss.game.entities.Environment;
   import ss.game.factory.EntityFactory;
   import ss.utils.Utils;
   
   public class DragMapHiliter extends Renderer
   {
      
      private var _element:VisualElement;
      
      private var _bitmap:Bitmap;
      
      private var _wasDragging:Boolean = false;
      
      private var _lastMouseTile:Point = new Point();
      
      private var _forceRefresh:Boolean;
      
      public function DragMapHiliter()
      {
         super();
      }
      
      override public function prepare() : void
      {
         positionMode = TILE_BASED_POSITION;
         var _loc1_:BitmapData = new BitmapData(Game.level.mapWidth,Game.level.mapHeight,true,0);
         this._bitmap = new Bitmap(_loc1_);
         this._bitmap.scaleX = Game.level.tileWidth;
         this._bitmap.scaleY = Game.level.tileHeight;
         addElement(this._bitmap).depth = DepthManager.getDepth(DepthManager.DRAG_MAP);
         Game.messenger.register(this,Messages.CASH_CHANGED);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Messages.CASH_CHANGED:
               this._forceRefresh = true;
         }
      }
      
      override public function render() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:Point = null;
         var _loc4_:Boolean = false;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(this.draggable.isDragging)
         {
            _loc1_ = this.draggable.attributes.category;
            _loc2_ = this.draggable.attributes.type;
            this._bitmap.visible = true;
            _loc3_ = this.draggable.mouseTile.clone();
            _loc4_ = false;
            Game.messenger.broadcast(Commands.UNHILITE_BELT);
            if(_loc1_ == EntityFactory.WORKER && this.draggable.canDrop)
            {
               _loc5_ = this.getWorkerEffectedBeltTiles(_loc3_);
               Game.messenger.broadcast(Commands.HILITE_BELT,{
                  "tiles":_loc5_,
                  "canBuy":this.draggable.canBuy
               });
            }
            if(_loc2_ == "engineer" && this.draggable.canDrop)
            {
               _loc5_ = this.getEngineerEffectedBeltTiles(_loc3_,this.draggable.staticData.range);
               Game.messenger.broadcast(Commands.HILITE_BELT,{
                  "tiles":_loc5_,
                  "canBuy":this.draggable.canBuy
               });
            }
            if(!this._lastMouseTile.equals(_loc3_) || this._forceRefresh)
            {
               this._lastMouseTile = _loc3_.clone();
               _loc4_ = true;
            }
            if(this.draggable.canDrop && this.draggable.canBuy && _loc4_)
            {
               this.clearRect();
               switch(_loc1_)
               {
                  case EntityFactory.WORKER:
                     this.fillRect(_loc3_.x,_loc3_.y,1,1,855703296);
                     break;
                  default:
                     _loc6_ = int(this.draggable.staticData.range);
                     _loc7_ = 855703296;
                     if(_loc1_ == EntityFactory.FEATURE)
                     {
                        _loc7_ = this.draggable.attributes.color + 51 * 256 * 256 * 256;
                     }
                     this.fillCirc(_loc3_.x,_loc3_.y,_loc6_,_loc7_);
                     this.fillRect(_loc3_.x,_loc3_.y,1,1,2566979328);
                     if(_loc2_ == "fire_officer")
                     {
                        Game.messenger.broadcast(Commands.SHOW_OVERLAY,{"layer":Environment.FIRE_RISK});
                     }
                     if(_loc2_ == "engineer")
                     {
                        Game.messenger.broadcast(Commands.SHOW_OVERLAY,{"layer":Environment.ACCIDENT_RISK});
                     }
               }
            }
            else if(_loc4_)
            {
               this.clearRect();
               this.fillRect(_loc3_.x,_loc3_.y,1,1,872349696);
            }
            this._wasDragging = true;
         }
         else if(this._wasDragging)
         {
            this._bitmap.visible = false;
            Game.messenger.broadcast(Commands.HIDE_OVERLAY);
            Game.messenger.broadcast(Commands.UNHILITE_BELT);
            this._wasDragging = false;
         }
         this._forceRefresh = false;
         super.render();
      }
      
      private function fillCirc(param1:Number, param2:Number, param3:int, param4:int) : void
      {
         var _loc5_:Rectangle = Values.ACTIVE_TILE_AREAS[Game.level.world];
         Utils.drawCircle(this._bitmap.bitmapData,param1,param2,param3,param4,_loc5_);
      }
      
      private function fillRect(param1:int, param2:int, param3:int, param4:int, param5:int) : void
      {
         var _loc6_:Rectangle = new Rectangle(param1,param2,param3,param4).intersection(Values.ACTIVE_TILE_AREAS[Game.level.world]);
         this._bitmap.bitmapData.fillRect(_loc6_,param5);
      }
      
      private function clearRect() : void
      {
         this._bitmap.bitmapData.fillRect(this._bitmap.bitmapData.rect,0);
      }
      
      private function getWorkerEffectedBeltTiles(param1:Point) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:Array = [];
         _loc3_ = -1;
         while(_loc3_ <= 1)
         {
            _loc4_ = -1;
            while(_loc4_ <= 1)
            {
               _loc2_.push(new Point(param1.x + _loc3_,param1.y + _loc4_));
               _loc4_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function getEngineerEffectedBeltTiles(param1:Point, param2:int) : Array
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc3_:Array = [];
         var _loc4_:int = -param2;
         while(_loc4_ <= param2)
         {
            _loc5_ = -param2;
            while(_loc5_ <= param2)
            {
               _loc6_ = param1.x + _loc4_;
               _loc7_ = param1.y + _loc5_;
               _loc8_ = _loc4_ * _loc4_ + _loc5_ * _loc5_;
               if(_loc8_ < param2 * param2)
               {
                  _loc3_.push(new Point(_loc6_,_loc7_));
               }
               _loc5_++;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function get draggable() : DragInstance
      {
         return entity as DragInstance;
      }
   }
}

