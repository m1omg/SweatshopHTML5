package ss.app
{
   import flash.net.SharedObject;
   import org.fatlib.Log;
   import ss.data.Session;
   
   public class Cookies
   {
      
      public var currentSlot:int = -1;
      
      public function Cookies()
      {
         super();
      }
      
      public function saveCurrentSessionToCurrentSlot() : void
      {
         this.saveSessionToSlot(this.currentSlot,App.instance.session);
         Log.log("[Cookies] saveCurrentSessionToCurrentSlot");
      }
      
      public function saveSessionToSlot(param1:int, param2:Session) : void
      {
         Log.log("[Cookies] saveSessionToSlot " + param1 + ": " + param2);
         var _loc3_:SharedObject = SharedObject.getLocal("sweatshop");
         _loc3_.data[param1] = param2.toObject();
         _loc3_.flush();
      }
      
      public function loadSessionFromCurrentSlot() : void
      {
         var _loc1_:SharedObject = SharedObject.getLocal("sweatshop");
         var _loc2_:Object = _loc1_.data[this.currentSlot];
         App.instance.session.loadFromObject(_loc2_);
      }
      
      public function getSlotData(param1:int) : Object
      {
         var _loc2_:SharedObject = SharedObject.getLocal("sweatshop");
         return _loc2_.data[param1];
      }
      
      public function erase(param1:int) : void
      {
         var _loc2_:SharedObject = SharedObject.getLocal("sweatshop");
         _loc2_.data[param1] = null;
      }
   }
}

