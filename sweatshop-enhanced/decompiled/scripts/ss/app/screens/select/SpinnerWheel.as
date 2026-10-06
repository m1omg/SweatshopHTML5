package ss.app.screens.select
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.utils.MovieClipListener;
   import org.fatlib.utils.Tween;
   import ss.app.App;
   
   public class SpinnerWheel implements IDestroyable
   {
      
      private var _mc:MovieClip;
      
      private var _mcl:MovieClipListener;
      
      private var _onDone:Function;
      
      private var _oy:Number;
      
      public var rotation:Number = 0;
      
      public function SpinnerWheel(param1:MovieClip)
      {
         super();
         this._mc = param1;
         this._mc.addEventListener(Event.ENTER_FRAME,this.onFrame);
         this.rotation = 0;
         this._oy = this._mc.y;
      }
      
      public function lockWorld(param1:int) : void
      {
         this._mc["world" + param1].gotoAndStop("locked");
      }
      
      public function unlockWorld(param1:int, param2:Boolean = false, param3:Function = null) : void
      {
         if(param2)
         {
            this.killMCL();
            this._mcl = new MovieClipListener(this._mc["world" + param1]);
            this._mcl.addEventListener(Event.CHANGE,this.onChange);
            this._mcl.mc.gotoAndPlay("unlock");
            this._onDone = param3;
         }
         else
         {
            this._mc["world" + param1].gotoAndStop("unlocked");
         }
      }
      
      private function killMCL() : void
      {
         if(this._mcl)
         {
            this._mcl.destroy();
            this._mcl.removeEventListener(Event.CHANGE,this.onChange);
         }
      }
      
      private function onChange(param1:Event) : void
      {
         if((param1.target as MovieClipListener).currentLabel == "done")
         {
            this._mcl.mc.stop();
            this.killMCL();
            this._onDone.call();
         }
      }
      
      public function rotateTo(param1:int, param2:Boolean = false, param3:Function = null) : void
      {
         if(param2)
         {
            Tween.add(this,400,{"rotation":this.getWheelRotation(param1)},Tween.EASE_IN,param3);
            App.instance.audio.play("whoosh");
         }
         else
         {
            this.rotation = this.getWheelRotation(param1);
            this.update();
         }
      }
      
      private function scaleUp() : void
      {
         Tween.add(this._mc,400,{
            "scaleX":1,
            "scaleY":1,
            "y":this._oy
         },Tween.LINEAR);
      }
      
      private function update() : void
      {
         this._mc.rotation = this.rotation;
      }
      
      private function getWheelRotation(param1:int) : int
      {
         return (param1 - 1) * -120;
      }
      
      private function onFrame(param1:Event) : void
      {
         var _loc2_:Number = this.rotation;
         if(_loc2_ < 0)
         {
            _loc2_ += 360;
         }
         if(_loc2_ > 360)
         {
            _loc2_ -= 360;
         }
         var _loc3_:Number = this._mc.rotation;
         if(_loc3_ < 0)
         {
            _loc3_ += 360;
         }
         if(_loc3_ > 360)
         {
            _loc3_ -= 360;
         }
         if(_loc2_ != _loc3_)
         {
            this.update();
         }
      }
      
      public function destroy() : void
      {
         this._mc.removeEventListener(Event.ENTER_FRAME,this.onFrame);
      }
   }
}

