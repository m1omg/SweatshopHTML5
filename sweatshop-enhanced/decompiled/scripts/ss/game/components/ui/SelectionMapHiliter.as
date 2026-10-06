package ss.game.components.ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   import ss.Values;
   import ss.game.Commands;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Entity;
   import ss.game.core.Renderer;
   import ss.game.entities.DragInstance;
   import ss.game.entities.Feature;
   import ss.game.entities.Officer;
   import ss.game.entities.Selection;
   import ss.utils.Utils;
   
   public class SelectionMapHiliter extends Renderer
   {
      
      private var _bitmap:Bitmap;
      
      private var _overID:String;
      
      private var _selectedID:String;
      
      private var _layer:String;
      
      public function SelectionMapHiliter()
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
         this._bitmap.visible = false;
         Game.messenger.register(this,Messages.DEPLOYABLE_SELECTED,Messages.DEPLOYABLE_DESELECTED,Messages.DEPLOYABLE_MOUSE_OVER,Messages.DEPLOYABLE_MOUSE_OUT);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         var _loc3_:DragInstance = null;
         switch(param1)
         {
            case Messages.DEPLOYABLE_SELECTED:
               this._selectedID = param2.id;
               this.refresh();
               break;
            case Messages.DEPLOYABLE_DESELECTED:
               this._selectedID = null;
               this.refresh();
               break;
            case Messages.DEPLOYABLE_MOUSE_OVER:
               _loc3_ = engine.resolveReference(this.selection.dragRef);
               if(_loc3_.isDragging)
               {
                  return;
               }
               this._overID = param2.id;
               this.refresh();
               break;
            case Messages.DEPLOYABLE_MOUSE_OUT:
               _loc3_ = engine.resolveReference(this.selection.dragRef);
               if(_loc3_.isDragging)
               {
                  return;
               }
               if(param2.id == this._overID)
               {
                  this._overID = null;
               }
               this.refresh();
         }
      }
      
      private function get selection() : Selection
      {
         return entity as Selection;
      }
      
      private function refresh() : void
      {
         if(this._selectedID)
         {
            this.show(this._selectedID);
         }
         else if(this._overID)
         {
            this.show(this._overID);
         }
         else
         {
            this.hide();
         }
      }
      
      private function hide() : void
      {
         this._bitmap.bitmapData.fillRect(this._bitmap.bitmapData.rect,0);
         this._bitmap.visible = false;
         if(this._layer)
         {
            Game.messenger.broadcast(Commands.HIDE_OVERLAY,{"layer":this._layer});
            this._layer = null;
         }
      }
      
      private function show(param1:String) : void
      {
         var _loc3_:Feature = null;
         var _loc4_:Rectangle = null;
         var _loc5_:Officer = null;
         var _loc2_:Entity = engine.find(param1);
         if(!_loc2_)
         {
            return;
         }
         this.hide();
         if(_loc2_ is Feature)
         {
            _loc3_ = _loc2_ as Feature;
            _loc4_ = Values.ACTIVE_TILE_AREAS[Game.level.world];
            this._bitmap.bitmapData.lock();
            Utils.drawCircle(this._bitmap.bitmapData,_loc3_.position.x,_loc3_.position.y,_loc3_.range,_loc3_.overlayColor,_loc4_);
            this._bitmap.bitmapData.unlock();
            this._bitmap.visible = true;
         }
         else if(_loc2_ is Officer)
         {
            _loc5_ = _loc2_ as Officer;
            this._layer = _loc5_.getEffectLayer();
            if(this._layer)
            {
               Game.messenger.broadcast(Commands.SHOW_OVERLAY,{"layer":this._layer});
            }
         }
      }
   }
}

