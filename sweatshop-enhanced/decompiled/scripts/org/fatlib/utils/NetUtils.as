package org.fatlib.utils
{
   import flash.display.DisplayObject;
   import flash.display.LoaderInfo;
   
   public class NetUtils
   {
      
      public function NetUtils()
      {
         super();
      }
      
      public static function getExtension(param1:String) : String
      {
         var _loc2_:Array = param1.split("/");
         var _loc3_:Array = _loc2_.pop().split(".");
         if(_loc3_.length < 2)
         {
            return "";
         }
         var _loc4_:String = _loc3_.pop() as String;
         return _loc4_.toLowerCase();
      }
      
      public static function getFlashVars(param1:DisplayObject) : Object
      {
         return LoaderInfo(param1.root.loaderInfo).parameters;
      }
   }
}

