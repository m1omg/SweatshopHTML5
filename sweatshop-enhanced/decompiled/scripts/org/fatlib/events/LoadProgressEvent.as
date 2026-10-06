package org.fatlib.events
{
   import flash.events.Event;
   
   public class LoadProgressEvent extends Event
   {
      
      public static const LOADED:String = "onLoaded";
      
      public static const ERROR:String = "onError";
      
      public static const PROGRESS:String = "onProgress";
      
      private var _percentLoaded:Number;
      
      private var _fractionLoaded:Number;
      
      private var _message:String;
      
      public function LoadProgressEvent(param1:String, param2:Number = 1, param3:String = null, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param4,param5);
         this._fractionLoaded = param2;
         this._percentLoaded = param2 * 100;
         this._message = param3;
      }
      
      override public function clone() : Event
      {
         return new LoadProgressEvent(type,this._fractionLoaded,this._message,bubbles,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("LoadProgressEvent","type","fractionLoaded","message","bubbles","cancelable","eventPhase");
      }
      
      public function get percentLoaded() : Number
      {
         return this._percentLoaded;
      }
      
      public function get fractionLoaded() : Number
      {
         return this._fractionLoaded;
      }
      
      public function get message() : String
      {
         return this._message;
      }
   }
}

