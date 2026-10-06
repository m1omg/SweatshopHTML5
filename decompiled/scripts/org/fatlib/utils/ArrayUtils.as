package org.fatlib.utils
{
   public class ArrayUtils
   {
      
      public function ArrayUtils()
      {
         super();
      }
      
      public static function shuffle(param1:Array) : Array
      {
         var _loc4_:Object = null;
         var _loc6_:int = 0;
         var _loc2_:Array = param1.concat();
         var _loc3_:Array = new Array();
         var _loc5_:* = 0;
         while(_loc5_ < _loc2_.length)
         {
            _loc6_ = Math.floor(Math.random() * _loc2_.length);
            _loc3_.push(_loc2_[_loc6_]);
            _loc2_.splice(_loc6_,1);
            _loc5_ = --_loc5_ + 1;
         }
         return _loc3_;
      }
      
      public static function contains(param1:Array, param2:*) : Boolean
      {
         return param1.indexOf(param2) > -1;
      }
      
      public static function range(param1:int, param2:int) : Array
      {
         var _loc5_:int = 0;
         if(param2 < param1)
         {
            _loc5_ = param1;
            param1 = param2;
            param2 = _loc5_;
         }
         var _loc3_:Array = new Array();
         var _loc4_:int = param1;
         while(_loc4_ <= param2)
         {
            _loc3_.push(_loc4_);
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function remove(param1:Array, param2:*) : void
      {
         var _loc3_:int = 0;
         while(contains(param1,param2))
         {
            _loc3_ = param1.indexOf(param2);
            param1.splice(_loc3_,1);
         }
      }
      
      public static function clone(param1:Array) : Array
      {
         return param1.slice();
      }
      
      public static function pickOne(param1:Array) : *
      {
         return shuffle(clone(param1)).pop();
      }
      
      public static function average(param1:Array) : Number
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = 0;
         for each(_loc3_ in param1)
         {
            _loc2_ += _loc3_;
         }
         return _loc2_ / param1.length;
      }
   }
}

