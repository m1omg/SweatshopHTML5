package org.fatlib.utils
{
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class Tween
   {
      
      private static var _activeTweens:Dictionary;
      
      public static const LINEAR:String = "linear";
      
      public static const EASE_IN:String = "ease_in";
      
      public static const EASE_OUT:String = "ease_out";
      
      public static const EASE_IN_OUT:String = "ease_in_out";
      
      public function Tween()
      {
         super();
      }
      
      public static function add(param1:Object, param2:Number, param3:Object, param4:String = null, param5:Function = null, param6:Array = null) : void
      {
         if(!_activeTweens)
         {
            _activeTweens = new Dictionary(false);
         }
         var _loc7_:TweenInstance = new TweenInstance(param1,param2,param3,param4,param5,param6);
         _activeTweens[_loc7_] = 1;
         _loc7_.addEventListener(Event.COMPLETE,onTweenComplete);
         _loc7_.start();
      }
      
      private static function onTweenComplete(param1:Event) : void
      {
         var _loc2_:TweenInstance = param1.target as TweenInstance;
         delete _activeTweens[_loc2_];
         _loc2_.doCompleteAction();
      }
   }
}

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.getTimer;
import org.fatlib.process.Callback;

class TweenInstance extends EventDispatcher
{
   
   private var _target:Object;
   
   private var _duration:Number;
   
   private var _propertyList:Array;
   
   private var _transition:String;
   
   private var _onComplete:Callback;
   
   private var _frameSource:MovieClip;
   
   private var _startTime:int;
   
   public function TweenInstance(param1:Object, param2:Number, param3:Object, param4:String = null, param5:Function = null, param6:Array = null)
   {
      var _loc7_:String = null;
      var _loc8_:Number = NaN;
      var _loc9_:Number = NaN;
      var _loc10_:Object = null;
      super();
      this._target = param1;
      this._duration = param2;
      this._transition = param4;
      if(!this._transition)
      {
         this._transition = "ease_in";
      }
      if(param5 != null)
      {
         this._onComplete = new Callback(param5,param6);
      }
      this._frameSource = new MovieClip();
      this._propertyList = new Array();
      for(_loc7_ in param3)
      {
         _loc8_ = Number(this._target[_loc7_]);
         _loc9_ = Number(param3[_loc7_]);
         _loc10_ = {
            "key":_loc7_,
            "from":_loc8_,
            "to":_loc9_
         };
         this._propertyList.push(_loc10_);
      }
   }
   
   internal function start() : void
   {
      this._startTime = getTimer();
      this._frameSource.addEventListener(Event.ENTER_FRAME,this.onFrame);
   }
   
   private function onFrame(param1:Event) : void
   {
      var _loc3_:Number = NaN;
      var _loc2_:Number = getTimer() - this._startTime;
      if(_loc2_ >= this._duration)
      {
         this.updateProgress(1);
         this.done();
      }
      else
      {
         _loc3_ = _loc2_ / this._duration;
         this.updateProgress(_loc3_);
      }
   }
   
   private function updateProgress(param1:Number) : void
   {
      var _loc2_:Number = NaN;
      var _loc3_:Object = null;
      var _loc4_:String = null;
      var _loc5_:Number = NaN;
      var _loc6_:Number = NaN;
      switch(this._transition)
      {
         case "linear":
            _loc2_ = param1;
            break;
         case "ease_in":
            _loc2_ = param1 * param1;
            break;
         case "ease_out":
            _loc2_ = 1 - (1 - param1) * (1 - param1);
            break;
         case "ease_in_out":
            _loc2_ = (Math.sin(param1 * Math.PI - Math.PI / 2) + 1) / 2;
      }
      for each(_loc3_ in this._propertyList)
      {
         _loc4_ = _loc3_["key"];
         _loc5_ = Number(_loc3_["from"]);
         _loc6_ = Number(_loc3_["to"]);
         this._target[_loc4_] = _loc5_ + _loc2_ * (_loc6_ - _loc5_);
      }
   }
   
   private function done() : void
   {
      this._frameSource.removeEventListener(Event.ENTER_FRAME,this.onFrame);
      this._frameSource = null;
      this._target = null;
      this._propertyList = null;
      dispatchEvent(new Event(Event.COMPLETE));
   }
   
   internal function doCompleteAction() : void
   {
      if(this._onComplete != null)
      {
         this._onComplete.execute();
      }
   }
}
