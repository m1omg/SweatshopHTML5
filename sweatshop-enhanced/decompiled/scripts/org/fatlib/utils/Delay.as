package org.fatlib.utils
{
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.process.Callback;
   
   public class Delay implements IDestroyable
   {
      
      private var _index:Dictionary;
      
      public function Delay()
      {
         super();
         this._index = new Dictionary(true);
      }
      
      public function create(param1:int, param2:Function, param3:Array = null) : void
      {
         var _loc4_:Callback = new Callback(param2,param3);
         var _loc5_:Timer = new Timer(param1,1);
         _loc5_.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerFinished);
         this._index[_loc5_] = _loc4_;
         _loc5_.start();
      }
      
      public function cancelAll() : void
      {
         var _loc1_:* = undefined;
         for(_loc1_ in this._index)
         {
            this.cancel(_loc1_);
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:Object = null;
         for(_loc1_ in this._index)
         {
            (_loc1_ as Timer).stop();
            delete this._index[_loc1_];
         }
      }
      
      private function cancel(param1:Timer) : void
      {
         if(!param1 || !this._index[param1])
         {
            return;
         }
         param1.stop();
         param1.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerFinished);
         this._index[param1] = null;
         delete this._index[param1];
         param1 = null;
      }
      
      private function onTimerFinished(param1:TimerEvent) : void
      {
         var _loc2_:Timer = param1.currentTarget as Timer;
         var _loc3_:Callback = this._index[_loc2_] as Callback;
         _loc3_.execute();
         _loc2_.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerFinished);
         this._index[_loc2_] = null;
         delete this._index[_loc2_];
         _loc2_ = null;
      }
   }
}

