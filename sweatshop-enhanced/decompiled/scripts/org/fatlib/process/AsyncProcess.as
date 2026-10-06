package org.fatlib.process
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import org.fatlib.interfaces.IProcess;
   
   public class AsyncProcess extends EventDispatcher implements IProcess
   {
      
      public static const READY:String = "READY";
      
      public static const EXECUTING:String = "EXECUTING";
      
      public static const DONE:String = "DONE";
      
      private var _state:String;
      
      public function AsyncProcess()
      {
         super();
         this._state = READY;
      }
      
      public function execute() : void
      {
         this._state = EXECUTING;
      }
      
      public function destroy() : void
      {
      }
      
      final protected function done() : void
      {
         this._state = DONE;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function get state() : String
      {
         return this._state;
      }
   }
}

