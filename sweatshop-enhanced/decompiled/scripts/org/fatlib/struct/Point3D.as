package org.fatlib.struct
{
   public class Point3D
   {
      
      private var _x:Number;
      
      private var _y:Number;
      
      private var _z:Number;
      
      public function Point3D(param1:Number = 0, param2:Number = 0, param3:Number = 0)
      {
         super();
         this._x = param1;
         this._y = param2;
         this._z = param3;
      }
      
      public function get x() : Number
      {
         return this._x;
      }
      
      public function set x(param1:Number) : void
      {
         this._x = param1;
      }
      
      public function get y() : Number
      {
         return this._y;
      }
      
      public function set y(param1:Number) : void
      {
         this._y = param1;
      }
      
      public function get z() : Number
      {
         return this._z;
      }
      
      public function set z(param1:Number) : void
      {
         this._z = param1;
      }
      
      public function toString() : String
      {
         return "[Point3D " + this.x + ", " + this.y + ", " + this.z + "]";
      }
   }
}

