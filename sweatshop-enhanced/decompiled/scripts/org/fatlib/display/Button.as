package org.fatlib.display
{
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class Button extends Graphic
   {
      
      public static const UP:String = "up";
      
      public static const OVER:String = "over";
      
      public static const DISABLED:String = "disabled";
      
      public function Button()
      {
         super();
         addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
         this.registerState(UP);
         this.registerState(OVER);
         childrenInteractable = false;
         interactable = true;
         actAsButton = true;
      }
      
      override public function registerState(param1:*, param2:DisplayObject = null) : void
      {
         super.registerState(param1,param2);
         if(param1 == UP)
         {
            showState(UP);
         }
      }
      
      override protected function handleMadeInteractive() : void
      {
         alpha = 1;
         if(hasState(UP))
         {
            showState(UP);
         }
      }
      
      override protected function handleMadeNonInteractive() : void
      {
         if(hasState(DISABLED))
         {
            showState(DISABLED);
         }
         else
         {
            showState(UP);
            alpha = 0.3;
         }
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         showState(OVER);
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         showState(UP);
      }
   }
}

