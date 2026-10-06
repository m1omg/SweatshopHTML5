package ss.utils
{
   import com.adobe.serialization.json.JSON;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import org.fatlib.Log;
   import org.fatlib.interfaces.IDestroyable;
   
   public class Console implements IDestroyable
   {
      
      public static var HISTORY_SIZE:int = 10;
      
      private var _history:Array;
      
      private var _index:Dictionary;
      
      public function Console()
      {
         super();
         this._history = [];
         this._index = new Dictionary(true);
      }
      
      public function destroy() : void
      {
      }
      
      public function parse(param1:String) : void
      {
         var fragments:Array = null;
         var obj:String = null;
         var method:String = null;
         var input:String = param1;
         this._history.push(input);
         if(this._history.length > HISTORY_SIZE)
         {
            this._history.shift();
         }
         Log.log("[Console] " + input);
         try
         {
            fragments = input.split(" ");
            obj = fragments.shift();
            method = fragments.shift();
            this.parseCall(obj,method,fragments);
         }
         catch(r:Error)
         {
            Log.log("[Console] error: " + r.message);
         }
      }
      
      public function getLast() : String
      {
         if(this._history.length > 0)
         {
            return this._history.pop();
         }
         return "";
      }
      
      private function parseCall(param1:String, param2:String, param3:Array) : void
      {
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:* = undefined;
         var _loc4_:Array = [];
         for each(_loc5_ in param3)
         {
            if(_loc5_.charAt(0) == "#")
            {
               _loc7_ = _loc5_.substr(1);
               _loc4_.push(com.adobe.serialization.json.JSON.decode(_loc7_));
            }
            else
            {
               _loc4_.push(_loc5_);
            }
         }
         _loc6_ = this.getObject(param1);
         if(param2 == "set")
         {
            _loc8_ = _loc4_[0];
            _loc10_ = _loc9_ = _loc4_[1];
            switch(typeof _loc6_[_loc8_])
            {
               case "boolean":
                  _loc10_ = _loc9_ == "true";
            }
            _loc6_[_loc8_] = _loc10_;
         }
         else
         {
            (_loc6_[param2] as Function).apply(NaN,_loc4_);
         }
      }
      
      private function getObject(param1:String) : *
      {
         return this._index[param1];
      }
      
      private function parseList(param1:String) : void
      {
         var _loc4_:XML = null;
         var _loc2_:Object = this.getObject(param1);
         Log.log(describeType(_loc2_));
         var _loc3_:XML = describeType(_loc2_);
         for each(_loc4_ in _loc3_.variable)
         {
            Log.log("[Console] " + _loc4_.@name + "=" + _loc2_[_loc4_.@name]);
         }
      }
      
      private function parseSet(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:Object = this.getObject(param1);
         var _loc5_:* = param3;
         switch(typeof _loc4_[param2])
         {
            case "boolean":
               _loc5_ = param3 == "true";
         }
         if(_loc4_)
         {
            _loc4_[param2] = _loc5_;
         }
      }
      
      private function parseGet(param1:String, param2:String) : void
      {
         var _loc3_:Object = this.getObject(param1);
         Log.log("[Console] " + _loc3_[param2]);
      }
      
      public function register(param1:String, param2:*) : void
      {
         Log.log("[Console] registering \"" + param1 + "\": " + param2);
         this._index[param1] = param2;
      }
   }
}

