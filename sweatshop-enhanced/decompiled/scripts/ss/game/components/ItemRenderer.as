package ss.game.components
{
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.Entity;
   import ss.game.core.Renderer;
   import ss.game.core.VisualElement;
   import ss.game.entities.Item;
   import ss.game.entities.MapEntity;
   import ss.utils.Utils;
   
   public class ItemRenderer extends Renderer
   {
      
      private var _itemElement:VisualElement;
      
      private var _mc:MovieClip;
      
      private var _burnt:Boolean = false;
      
      private var _firstFrame:int = 0;
      
      public function ItemRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         positionMode = TILE_BASED_POSITION;
         this._mc = Utils.getItemSymbol(this.item.type);
         this._mc.scaleX = this._mc.scaleY = Game.level.objectScale;
         this.showState();
         this._itemElement = addElement(this._mc);
         Utils.applyObjectFilter(this._mc,2);
         this._firstFrame = Utils.getItemFirstFrame(this.item.type,Game.level.world);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Entity.ON_STATE_CHANGED:
               this.showState();
         }
      }
      
      private function showState() : void
      {
         switch(this.item.state)
         {
            case Item.PACKING_STATE:
               this._mc.gotoAndStop(this.getFrame(3));
               break;
            case Item.DONE_STATE:
               this._mc.gotoAndStop(this.getFrame(4));
               break;
            case MapEntity.BURNING_STATE:
               this._mc.transform.colorTransform = new ColorTransform(0.3,0.3,0.3);
         }
      }
      
      override public function render() : void
      {
         var _loc3_:Number = NaN;
         var _loc8_:Number = NaN;
         this._itemElement.depth = DepthManager.getDepth(DepthManager.ITEM,this.item.position,offset);
         var _loc1_:Point = new Point();
         var _loc2_:Point = new Point();
         if(this.item.tileProgress < 0.5)
         {
            _loc1_ = this.item.tileEntryPoint;
            _loc3_ = this.item.tileProgress * 2;
         }
         else
         {
            _loc2_ = this.item.tileExitPoint;
            _loc3_ = (this.item.tileProgress - 0.5) * 2;
         }
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         if(Boolean(_loc1_) && Boolean(_loc2_))
         {
            _loc4_ = _loc1_.x + (_loc2_.x - _loc1_.x) * _loc3_;
            _loc5_ = _loc1_.y + (_loc2_.y - _loc1_.y) * _loc3_;
         }
         var _loc6_:int = Game.level.tileWidth;
         var _loc7_:int = Game.level.tileHeight;
         this.item.renderOffset = offset = new Point(_loc6_ * 0.52 + _loc6_ * _loc4_ * 0.5,_loc7_ * 0.5 + _loc7_ * _loc5_ * 0.5 - Game.level.beltHeight);
         if(this.item.state == Item.STITCHING_STATE)
         {
            _loc8_ = this.item.workProgress / this.item.workComplexity;
            if(_loc8_ < 0.35)
            {
               this._mc.gotoAndStop(this.getFrame(1));
            }
            else if(_loc8_ < 0.66)
            {
               this._mc.gotoAndStop(this.getFrame(2));
            }
            else
            {
               this._mc.gotoAndStop(this.getFrame(3));
            }
         }
         super.render();
      }
      
      private function getFrame(param1:int) : int
      {
         return param1 + this._firstFrame;
      }
      
      private function get item() : Item
      {
         return entity as Item;
      }
   }
}

