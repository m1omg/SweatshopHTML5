package ss.game.core
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class VisualElement extends Sprite
   {
      
      public var attachedToCanvas:Boolean;
      
      public var depth:Number = 0;
      
      public var entityID:String;
      
      private var _child:DisplayObject;
      
      public function VisualElement(param1:DisplayObject = null)
      {
         super();
         if(param1)
         {
            addChild(param1);
         }
         this._child = param1;
      }
      
      override public function toString() : String
      {
         return "[VisualElement " + name + " belonging to " + this.entityID + "]";
      }
   }
}

