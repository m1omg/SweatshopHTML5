package org.fatlib.display
{
   import flash.display.Sprite;
   import org.fatlib.utils.DisplayUtils;
   
   public class WireframeButton extends Button
   {
      
      public function WireframeButton(param1:String, param2:int = 16777096)
      {
         super();
         name = param1;
         var _loc3_:Button = new Button();
         var _loc4_:Sprite = DisplayUtils.createRectangle(0,0,100,20,param2,true);
         _loc4_.addChild(new Text(param1));
         var _loc5_:Sprite = DisplayUtils.createRectangle(0,0,100,20,0);
         _loc5_.addChild(new Text(param1,null,0,false,param2));
         registerState(Button.UP,_loc4_);
         registerState(Button.OVER,_loc5_);
      }
   }
}

