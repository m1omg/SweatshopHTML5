package ss.utils
{
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.process.Callback;
   
   public class PausableDelay implements IDestroyable, IPausable
   {
      
      private var _index:Dictionary;
      
      public function PausableDelay()
      {
         super();
         this._index = new Dictionary(true);
      }
      
      public function create(param1:int, param2:Function, param3:Array = null) : void
      {
         var _loc4_:Callback = new Callback(param2,param3);
         var _loc5_:PausableTimer = new PausableTimer(param1,1);
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
      
      public function pause() : void
      {
         var _loc1_:* = undefined;
         for(_loc1_ in this._index)
         {
            _loc1_.pause();
         }
      }
      
      public function unpause() : void
      {
         var _loc1_:* = undefined;
         for(_loc1_ in this._index)
         {
            _loc1_.unpause();
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:Object = null;
         for(_loc1_ in this._index)
         {
            (_loc1_ as PausableTimer).destroy();
            delete this._index[_loc1_];
         }
      }
      
      private function cancel(param1:PausableTimer) : void
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
      
      private function onTimerFinished(param1:Event) : void
      {
         var _loc2_:PausableTimer = param1.currentTarget as PausableTimer;
         var _loc3_:Callback = this._index[_loc2_] as Callback;
         _loc3_.execute();
         _loc2_.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerFinished);
         this._index[_loc2_] = null;
         delete this._index[_loc2_];
         _loc2_ = null;
      }
   }
}

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;
import org.fatlib.interfaces.IDestroyable;
import ss.utils.IPausable;

class PausableTimer extends EventDispatcher implements IPausable, IDestroyable
{
   
   private var _delay:Number;
   
   private var _lastTime:Number;
   
   private var _repeat:Number;
   
   private var _thisTime:Number = 0;
   
   public var timer:Timer;
   
   public function PausableTimer(param1:Number, param2:uint = 0)
   {
      super();
      this._delay = param1;
      this._repeat = param2;
      this.timer = new Timer(param1,param2);
      this.timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onComplete);
   }
   
   private function onComplete(param1:TimerEvent) : void
   {
      dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
   }
   
   public function start() : void
   {
      this._lastTime = getTimer();
      this.timer.start();
   }
   
   public function stop() : void
   {
      this.timer.stop();
   }
   
   public function pause() : void
   {
      this.timer.stop();
      this._thisTime = getTimer() - this._lastTime;
   }
   
   public function unpause() : void
   {
      if(this._thisTime > this.timer.delay)
      {
         this._thisTime = this.timer.delay;
      }
      this.timer.delay -= this._thisTime;
      this._lastTime = getTimer();
      this.timer.start();
      this._thisTime = 0;
   }
   
   public function destroy() : void
   {
      this.timer.stop();
      this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onComplete);
   }
}
