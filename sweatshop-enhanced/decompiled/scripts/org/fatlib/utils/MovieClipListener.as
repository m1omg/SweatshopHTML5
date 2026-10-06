package org.fatlib.utils
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.interfaces.IDestroyable;
   
   public class MovieClipListener extends EventDispatcher implements IDestroyable
   {
      
      private var _currentLabel:String;
      
      private var _mc:MovieClip;
      
      public function MovieClipListener(param1:MovieClip)
      {
         super();
         this._mc = param1;
         this._mc.addEventListener(Event.ENTER_FRAME,this.onFrame,false,0,true);
         this._currentLabel = this._mc.currentLabel;
      }
      
      private function onFrame(param1:Event) : void
      {
         if(this._mc.currentLabel != this._currentLabel)
         {
            this._currentLabel = this._mc.currentLabel;
            dispatchEvent(new CustomEvent(Event.CHANGE,this._currentLabel));
         }
         if(this._mc.currentFrame == this._mc.totalFrames && this._mc.totalFrames > 1)
         {
            dispatchEvent(new CustomEvent(Event.COMPLETE));
         }
      }
      
      public function destroy() : void
      {
         this._mc.removeEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      public function get currentLabel() : String
      {
         return this._currentLabel;
      }
      
      public function get currentFrame() : int
      {
         return this._mc.currentFrame;
      }
      
      public function get totalFrames() : int
      {
         return this._mc.totalFrames;
      }
   }
}

