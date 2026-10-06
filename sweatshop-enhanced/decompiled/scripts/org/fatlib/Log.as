package org.fatlib
{
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   import org.fatlib.events.CustomEvent;
   
   public class Log
   {
      
      public static const MESSAGE:String = "onMessage";
      
      public static var dispatcher:EventDispatcher = new EventDispatcher();
      
      public static const LOG:int = 1;
      
      public static const DEBUG:int = 2;
      
      public static const WARN:int = 3;
      
      public static const ERROR:int = 4;
      
      public static var LOG_LEVEL:int = LOG;
      
      public static var ALLOW_LOGGING:Boolean = true;
      
      public function Log()
      {
         super();
      }
      
      public static function log(param1:*) : void
      {
         if(LOG_LEVEL <= LOG)
         {
            send("log",param1);
         }
      }
      
      public static function debug(param1:*) : void
      {
         if(LOG_LEVEL <= DEBUG)
         {
            send("debug",param1);
         }
      }
      
      public static function warn(param1:*) : void
      {
         if(LOG_LEVEL <= WARN)
         {
            send("warn",param1);
         }
      }
      
      public static function info(param1:*) : void
      {
         send("info",param1);
      }
      
      public static function error(param1:*) : void
      {
         send("error",param1);
      }
      
      private static function send(param1:String, param2:*) : void
      {
         var level:String = param1;
         var item:* = param2;
         if(!ALLOW_LOGGING)
         {
            return;
         }
         dispatcher.dispatchEvent(new CustomEvent(MESSAGE,{
            "level":level,
            "content":item
         }));
         try
         {
            ExternalInterface.call("console." + level,item);
         }
         catch(er:Error)
         {
         }
      }
   }
}

