package ss.game.core
{
   import com.adobe.serialization.json.JSON;
   import org.fatlib.Log;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.utils.ArrayUtils;
   
   public class Messenger implements IDestroyable
   {
      
      private var _index:Object;
      
      private var _suppress:Array;
      
      public function Messenger()
      {
         super();
         Log.log("[Messenger]");
         this._index = {};
         this._suppress = [];
      }
      
      public function broadcast(param1:String, param2:Object = null) : void
      {
         var _loc3_:IMessageReceiver = null;
         if(!ArrayUtils.contains(this._suppress,param1))
         {
            if(param2)
            {
               Log.log("[Messenger] " + param1 + ": " + com.adobe.serialization.json.JSON.encode(param2));
            }
            else
            {
               Log.log("[Messenger] " + param1);
            }
         }
         if(!this._index[param1])
         {
            return;
         }
         if(!param2)
         {
            param2 = {};
         }
         for each(_loc3_ in this._index[param1])
         {
            if(!this._index)
            {
               return;
            }
            _loc3_.receiveMessage(param1,param2);
         }
      }
      
      public function register(param1:IMessageReceiver, ... rest) : void
      {
         var _loc3_:String = null;
         for each(_loc3_ in rest)
         {
            if(!this._index[_loc3_])
            {
               this._index[_loc3_] = [];
            }
            if(!ArrayUtils.contains(this._index[_loc3_],param1))
            {
               this._index[_loc3_].push(param1);
            }
         }
      }
      
      public function unregister(param1:IMessageReceiver) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         for each(_loc2_ in this._index)
         {
            _loc3_ = this._index[_loc2_];
            if(_loc3_)
            {
               ArrayUtils.remove(_loc3_,param1);
            }
         }
      }
      
      public function suppressFromLog(... rest) : void
      {
         var _loc2_:String = null;
         for each(_loc2_ in rest)
         {
            if(!ArrayUtils.contains(this._suppress,_loc2_))
            {
               this._suppress.push(_loc2_);
            }
         }
      }
      
      public function destroy() : void
      {
         this._index = null;
         this._suppress = null;
      }
   }
}

