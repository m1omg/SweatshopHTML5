package org.fatlib.metrics
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getTimer;
   
   public class FPS extends Sprite
   {
      
      private var checkRate:int = 8;
      
      private var checkCounter:int;
      
      private var startTime:Number;
      
      private var t:TextField;
      
      public function FPS(param1:int = 43690)
      {
         super();
         var _loc2_:TextFormat = new TextFormat();
         _loc2_.color = param1;
         _loc2_.font = "_sans";
         this.t = new TextField();
         this.t.defaultTextFormat = _loc2_;
         this.t.selectable = false;
         this.t.mouseEnabled = false;
         mouseChildren = mouseEnabled = false;
         addChild(this.t);
         this.checkCounter = this.checkRate;
         this.startTime = getTimer();
         addEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      private function onFrame(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         if(--this.checkCounter == 0)
         {
            _loc2_ = this.checkRate / ((getTimer() - this.startTime) / 1000);
            _loc2_ = Math.round(_loc2_ * 10 / 10);
            this.t.text = _loc2_.toString();
            this.startTime = getTimer();
            this.checkCounter = this.checkRate;
         }
      }
   }
}

