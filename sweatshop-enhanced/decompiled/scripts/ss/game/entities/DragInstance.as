package ss.game.entities
{
   import flash.geom.Point;
   import ss.game.core.Entity;
   
   public class DragInstance extends Entity
   {
      
      public var attributes:Object;
      
      public var staticData:Object;
      
      public var price:Number;
      
      public var gender:String;
      
      public var isDragging:Boolean = false;
      
      public var canDrop:Boolean;
      
      public var canBuy:Boolean;
      
      public var mouseTile:Point;
      
      public var mapRef:String;
      
      public function DragInstance()
      {
         super();
      }
   }
}

