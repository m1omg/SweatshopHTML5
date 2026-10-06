package ss.story
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.fatlib.Log;
   import org.fatlib.utils.MovieClipListener;
   import ss.utils.PausableProcess;
   
   public class AnimationProcess extends PausableProcess
   {
      
      private var _mcl:MovieClipListener;
      
      private var _frame:String;
      
      public function AnimationProcess(param1:MovieClip, param2:String, param3:String = null)
      {
         var _loc4_:String = null;
         super();
         if(param3 != null)
         {
            _loc4_ = "left";
            if(param3 == "boss")
            {
               _loc4_ = "right";
            }
            this._frame = param2 + "_" + _loc4_;
         }
         else
         {
            this._frame = param2;
         }
         this._mcl = new MovieClipListener(param1);
         this._mcl.addEventListener(Event.CHANGE,this.onChangeLabel);
      }
      
      override public function execute() : void
      {
         super.execute();
         Log.log("[AnimationProcess] execute " + this._mcl.mc.name + " " + this._frame);
         this._mcl.mc.gotoAndPlay(this._frame);
      }
      
      override public function pause() : void
      {
         this._mcl.mc.stop();
      }
      
      override public function unpause() : void
      {
         this._mcl.mc.play();
      }
      
      private function onChangeLabel(param1:Event) : void
      {
         if(this._mcl.currentLabel == this._frame + "_done")
         {
            this._mcl.mc.stop();
            done();
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this._mcl.removeEventListener(Event.CHANGE,this.onChangeLabel);
         this._mcl.destroy();
      }
   }
}

