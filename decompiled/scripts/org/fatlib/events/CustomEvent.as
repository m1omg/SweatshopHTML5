package org.fatlib.events
{
   import flash.events.Event;
   
   public class CustomEvent extends Event
   {
      
      private var _data:Object;
      
      public function CustomEvent(param1:String, param2:Object = null, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this._data = param2;
      }
      
      override public function clone() : Event
      {
         return new CustomEvent(type,this._data,bubbles,cancelable);
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      override public function toString() : String
      {
         return formatToString("CustomEvent","data","type","bubbles","cancelable");
      }
   }
}

