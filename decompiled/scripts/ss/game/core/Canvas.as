package ss.game.core
{
   import flash.display.Sprite;
   import flash.geom.Point;
   import org.fatlib.Log;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.utils.ArrayUtils;
   import ss.Values;
   
   public class Canvas implements IDestroyable
   {
      
      public var display:Sprite;
      
      public var tileOrigin:Point;
      
      private var _elements:Array;
      
      private var _tileW:int;
      
      private var _tileH:int;
      
      private var _mousePosition:Point;
      
      private var _mouseTile:Point;
      
      private var _forceDepthSort:Boolean;
      
      private var _engine:Engine;
      
      private var _nextDepthSortTime:Number = 0;
      
      public function Canvas(param1:Engine, param2:int = 0, param3:int = 0)
      {
         super();
         Log.log("[Canvas]");
         this._engine = param1;
         this._elements = [];
         this._tileW = param2;
         this._tileH = param3;
         this.display = new Sprite();
         this.tileOrigin = new Point();
         this._mousePosition = new Point();
         this._mouseTile = new Point();
      }
      
      public function forceDepthSort(param1:Boolean = false) : void
      {
         if(param1)
         {
            this.depthSort();
         }
         else
         {
            this._forceDepthSort = true;
         }
      }
      
      public function destroy() : void
      {
         this._elements = [];
      }
      
      public function attach(param1:VisualElement) : void
      {
         this._elements.push(param1);
         param1.attachedToCanvas = true;
         this.display.addChild(param1);
      }
      
      public function detach(param1:VisualElement) : void
      {
         ArrayUtils.remove(this._elements,param1);
         param1.attachedToCanvas = false;
         this.display.removeChild(param1);
      }
      
      public function find(param1:String) : VisualElement
      {
         return this.display.getChildByName(param1) as VisualElement;
      }
      
      public function render() : void
      {
         if(this._forceDepthSort || this._engine.timer.elapsed > this._nextDepthSortTime)
         {
            this.depthSort();
            this._forceDepthSort = false;
            this._nextDepthSortTime = this._engine.timer.elapsed + Values.DEPTH_SORT_INTERVAL;
         }
         this._mousePosition = new Point(this.display.mouseX,this.display.mouseY);
         this._mouseTile = this.screenToTile(new Point(this.display.mouseX,this.display.mouseY));
      }
      
      private function depthSort() : void
      {
         var _loc2_:VisualElement = null;
         this._elements.sortOn("depth",Array.NUMERIC);
         var _loc1_:int = -1;
         while(++_loc1_ != this._elements.length)
         {
            _loc2_ = this._elements[_loc1_];
            this.display.setChildIndex(_loc2_,this.display.numChildren - 1);
         }
      }
      
      public function tileToScreen(param1:Point) : Point
      {
         return new Point(this.tileOrigin.x + param1.x * this._tileW,this.tileOrigin.y + param1.y * this._tileH);
      }
      
      public function tileCentreToScreen(param1:Point) : Point
      {
         return new Point(this.tileOrigin.x + (param1.x + 0.5) * this._tileW,this.tileOrigin.y + (param1.y + 0.5) * this._tileH);
      }
      
      public function screenToTile(param1:Point) : Point
      {
         return new Point(int((param1.x - this.tileOrigin.x) / this._tileW),int((param1.y - this.tileOrigin.y) / this._tileH));
      }
      
      public function get mousePosition() : Point
      {
         return this._mousePosition;
      }
      
      public function get mouseTile() : Point
      {
         return this._mouseTile;
      }
   }
}

