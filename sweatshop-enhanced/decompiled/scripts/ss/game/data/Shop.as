package ss.game.data
{
   import org.fatlib.interfaces.IDestroyable;
   
   public class Shop implements IDestroyable
   {
      
      private var _shopDB:Object;
      
      public function Shop(param1:Object)
      {
         super();
         this._shopDB = param1;
      }
      
      public function getBuyPrice(param1:String, param2:int) : Number
      {
         var _loc3_:Object = this._shopDB[param1];
         var _loc4_:String = "buy_price_" + param2;
         if(Boolean(_loc3_) && Boolean(_loc3_[_loc4_]))
         {
            return _loc3_[_loc4_];
         }
         return 0;
      }
      
      public function getSellPrice(param1:String, param2:int) : Number
      {
         var _loc3_:Object = this._shopDB[param1];
         var _loc4_:String = "sell_price_" + param2;
         if(Boolean(_loc3_) && Boolean(_loc3_[_loc4_]))
         {
            return _loc3_[_loc4_];
         }
         return 0;
      }
      
      public function getActionPrice(param1:String, param2:int) : Number
      {
         var _loc3_:Object = this._shopDB[param1];
         var _loc4_:String = "action_price_" + param2;
         if(Boolean(_loc3_) && Boolean(_loc3_[_loc4_]))
         {
            return _loc3_[_loc4_];
         }
         return 0;
      }
      
      public function destroy() : void
      {
         this._shopDB = null;
      }
   }
}

