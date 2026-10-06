package org.fatlib.events
{
   import flash.events.Event;
   
   public class TextInputEvent extends Event
   {
      
      public static const TEXT_INPUT:String = "onTextInput";
      
      private var _text:String;
      
      public function TextInputEvent(param1:String, param2:String, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this._text = param2;
      }
      
      override public function clone() : Event
      {
         return new TextInputEvent(type,this._text,bubbles,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("TextInputEvent","text","type","bubbles","cancelable","eventPhase");
      }
      
      public function get text() : String
      {
         return this._text;
      }
   }
}

