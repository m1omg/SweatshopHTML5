package ss.game.core
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import org.fatlib.utils.DisplayUtils;
   import ss.game.Game;
   
   public class Renderer extends Component
   {
      
      public static const TILE_BASED_POSITION:String = "tiles";
      
      public static const SCREEN_BASED_POSITION:String = "screen";
      
      public static const INDEPENDENT_POSITION:String = "independent";
      
      public var offset:Point = new Point();
      
      public var positionMode:String;
      
      private var _elements:Vector.<VisualElement>;
      
      public function Renderer()
      {
         super();
      }
      
      public function addElement(param1:DisplayObject, param2:Boolean = false, param3:Boolean = false) : VisualElement
      {
         var _loc4_:VisualElement = new VisualElement(param1);
         if(!this._elements)
         {
            this._elements = new Vector.<VisualElement>();
         }
         this._elements.push(_loc4_);
         if(entity.id)
         {
            _loc4_.entityID = entity.id;
            _loc4_.name = entity.id;
         }
         _loc4_.mouseEnabled = param2;
         _loc4_.mouseChildren = param3;
         return _loc4_;
      }
      
      override public function destroy() : void
      {
         var _loc1_:VisualElement = null;
         super.destroy();
         for each(_loc1_ in this._elements)
         {
            if(_loc1_.attachedToCanvas)
            {
               Game.canvas.detach(_loc1_);
            }
            DisplayUtils.recursiveStop(_loc1_);
            _loc1_ = null;
         }
         this._elements = null;
      }
      
      public function removeElement(param1:VisualElement) : void
      {
         var _loc2_:VisualElement = null;
         var _loc3_:int = 0;
         for each(_loc2_ in this._elements)
         {
            if(_loc2_ == param1)
            {
               _loc3_ = this._elements.indexOf(_loc2_);
               this._elements.splice(_loc3_,1);
               Game.canvas.detach(param1);
            }
         }
      }
      
      public function getElement(param1:String) : void
      {
         throw new Error("NYI");
      }
      
      final override public function update(param1:Number) : void
      {
      }
      
      override public function render() : void
      {
         var _loc2_:VisualElement = null;
         var _loc1_:Point = new Point();
         if(this.positionMode == TILE_BASED_POSITION)
         {
            _loc1_ = Game.canvas.tileToScreen(entity.position).add(this.offset);
         }
         else if(this.positionMode == SCREEN_BASED_POSITION)
         {
            _loc1_ = entity.position.clone();
         }
         else if(this.positionMode == INDEPENDENT_POSITION)
         {
            _loc1_ = this.offset.clone();
         }
         for each(_loc2_ in this._elements)
         {
            if(!_loc2_.attachedToCanvas)
            {
               Game.canvas.attach(_loc2_);
            }
            _loc2_.x = int(_loc1_.x);
            _loc2_.y = int(_loc1_.y);
         }
      }
   }
}

