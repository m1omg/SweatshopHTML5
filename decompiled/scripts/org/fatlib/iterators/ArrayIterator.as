package org.fatlib.iterators
{
   import org.fatlib.interfaces.IIterator;
   
   public class ArrayIterator implements IIterator
   {
      
      private var _position:int;
      
      private var _array:Array;
      
      public function ArrayIterator(param1:Array)
      {
         super();
         this._array = param1;
         this._position = 0;
      }
      
      public function get next() : *
      {
         var _loc1_:* = this._array[this.position];
         ++this._position;
         return _loc1_;
      }
      
      public function get position() : int
      {
         return this._position;
      }
      
      public function get hasNext() : Boolean
      {
         if(this._position >= this._array.length)
         {
            return false;
         }
         return true;
      }
   }
}

