package org.fatlib.utils
{
   import flash.geom.Point;
   import org.fatlib.struct.Point3D;
   
   public class MathUtils
   {
      
      public function MathUtils()
      {
         super();
      }
      
      public static function flipCoin() : Boolean
      {
         return Math.random() < 0.5;
      }
      
      public static function rollDice(param1:int = 6, param2:int = 1) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 1;
         while(_loc4_ <= param2)
         {
            _loc3_ += int(Math.random() * param1) + 1;
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function isEven(param1:int) : Boolean
      {
         return param1 % 2 == 0;
      }
      
      public static function isOdd(param1:int) : Boolean
      {
         return !isEven(param1);
      }
      
      public static function manhattan(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return Math.abs(param1 - param3) + Math.abs(param2 - param4);
      }
      
      public static function distance3D(param1:Point3D, param2:Point3D) : Number
      {
         return Math.sqrt((param1.x - param2.x) * (param1.x - param2.x) + (param1.y - param2.y) * (param1.y - param2.y) + (param1.z - param2.z) * (param1.z - param2.z));
      }
      
      public static function distance(param1:Point, param2:Point) : Number
      {
         return Math.sqrt((param1.x - param2.x) * (param1.x - param2.x) + (param1.y - param2.y) * (param1.y - param2.y));
      }
      
      public static function rangesOverlap(param1:Number, param2:Number, param3:Number, param4:Number) : Boolean
      {
         var _loc5_:Number = NaN;
         if(param2 < param1)
         {
            _loc5_ = param2;
            param2 = param1;
            param1 = _loc5_;
         }
         if(param4 < param3)
         {
            _loc5_ = param4;
            param4 = param3;
            param3 = _loc5_;
         }
         return param2 > param3 && param1 < param4;
      }
      
      public static function getBezierValue(param1:Point, param2:Point, param3:Point, param4:Point, param5:Number) : Point
      {
         var _loc6_:Number = param5;
         var _loc7_:Point = new Point((1 - _loc6_) * (1 - _loc6_) * (1 - _loc6_) * param1.x,(1 - _loc6_) * (1 - _loc6_) * (1 - _loc6_) * param1.y);
         var _loc8_:Point = new Point(3 * (1 - _loc6_) * (1 - _loc6_) * _loc6_ * param2.x,3 * (1 - _loc6_) * (1 - _loc6_) * _loc6_ * param2.y);
         var _loc9_:Point = new Point(3 * (1 - _loc6_) * _loc6_ * _loc6_ * param3.x,3 * (1 - _loc6_) * _loc6_ * _loc6_ * param3.y);
         var _loc10_:Point = new Point(_loc6_ * _loc6_ * _loc6_ * param4.x,_loc6_ * _loc6_ * _loc6_ * param4.y);
         return new Point(_loc7_.x + _loc8_.x + _loc9_.x + _loc10_.x,_loc7_.y + _loc8_.y + _loc9_.y + _loc10_.y);
      }
      
      public static function rotate3D(param1:Point3D, param2:Point3D, param3:Number) : Point3D
      {
         var _loc4_:Number = Math.sin(param3);
         var _loc5_:Number = Math.cos(param3);
         var _loc6_:Number = Math.sqrt(param2.x * param2.x + param2.y * param2.y + param2.z * param2.z);
         var _loc7_:Point3D = new Point3D(param2.x / _loc6_,param2.y / _loc6_,param2.z / _loc6_);
         var _loc8_:Number = _loc7_.x;
         var _loc9_:Number = _loc7_.y;
         var _loc10_:Number = _loc7_.z;
         var _loc11_:Point3D = new Point3D();
         _loc11_.x = param1.x * (_loc8_ * _loc8_ + (1 - _loc8_ * _loc8_) * _loc5_) + param1.y * (_loc8_ * _loc9_ * (1 - _loc5_) + _loc10_ * _loc4_) + param1.z * (_loc8_ * _loc10_ * (1 - _loc5_) - _loc9_ * _loc4_);
         _loc11_.y = param1.x * (_loc8_ * _loc9_ * (1 - _loc5_) - _loc10_ * _loc4_) + param1.y * (_loc9_ * _loc9_ + (1 - _loc9_ * _loc9_) * _loc5_) + param1.z * (_loc9_ * _loc10_ * (1 - _loc5_) + _loc8_ * _loc4_);
         _loc11_.z = param1.x * (_loc8_ * _loc10_ * (1 - _loc5_) + _loc9_ * _loc4_) + param1.y * (_loc9_ * _loc10_ * (1 - _loc5_) - _loc8_ * _loc4_) + param1.z * (_loc10_ * _loc10_ + (1 - _loc10_ * _loc10_) * _loc5_);
         return _loc11_;
      }
      
      public static function decay(param1:Number, param2:Number, param3:Number = 1) : Number
      {
         return param1 / Math.pow(2,param2 / param3);
      }
   }
}

