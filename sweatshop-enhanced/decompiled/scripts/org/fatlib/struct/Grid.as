package org.fatlib.struct
{
   import org.fatlib.interfaces.ICloneable;
   import org.fatlib.interfaces.IIterable;
   import org.fatlib.interfaces.IIterator;
   
   public class Grid implements IIterable, ICloneable
   {
      
      private var _cols:Array;
      
      private var _w:int;
      
      private var _h:int;
      
      public function Grid(param1:int, param2:int)
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         super();
         this._w = param1;
         this._h = param2;
         this._cols = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < this._w)
         {
            _loc4_ = new Array();
            _loc5_ = 0;
            while(_loc5_ < this._h)
            {
               _loc6_ = {"contents":null};
               _loc4_.push(_loc6_);
               _loc5_++;
            }
            this._cols.push(_loc4_);
            _loc3_++;
         }
      }
      
      public function fill(param1:*) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         for each(_loc2_ in this._cols)
         {
            for each(_loc3_ in _loc2_)
            {
               _loc3_.contents = param1;
            }
         }
      }
      
      public function fillWithClones(param1:ICloneable) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         for each(_loc2_ in this._cols)
         {
            for each(_loc3_ in _loc2_)
            {
               _loc3_.contents = param1.clone();
            }
         }
      }
      
      public function getCell(param1:int, param2:int) : *
      {
         if(param1 >= this._w || param1 < 0 || param2 >= this._h || param2 < 0)
         {
            return null;
         }
         return this._cols[param1][param2].contents;
      }
      
      public function setCell(param1:int, param2:int, param3:*) : void
      {
         if(param1 >= this._w || param1 < 0 || param2 >= this._h || param2 < 0)
         {
            return;
         }
         this._cols[param1][param2] = {"contents":param3};
      }
      
      public function getIterator() : IIterator
      {
         return new GridIterator(this);
      }
      
      public function clone() : ICloneable
      {
         var _loc3_:int = 0;
         var _loc4_:* = undefined;
         var _loc1_:Grid = new Grid(this.width,this.height);
         var _loc2_:int = 0;
         while(_loc2_ < this.width)
         {
            _loc3_ = 0;
            while(_loc3_ < this.height)
            {
               _loc4_ = this.getCell(_loc2_,_loc3_);
               if(_loc4_ is ICloneable)
               {
                  _loc1_.setCell(_loc2_,_loc3_,(_loc4_ as ICloneable).clone());
               }
               else
               {
                  _loc1_.setCell(_loc2_,_loc3_,_loc4_);
               }
               _loc3_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function get width() : int
      {
         return this._w;
      }
      
      public function get height() : int
      {
         return this._h;
      }
   }
}

import org.fatlib.iterators.ArrayIterator;
import org.fatlib.struct.Grid;

class GridIterator extends ArrayIterator
{
   
   public function GridIterator(param1:Grid)
   {
      var _loc4_:int = 0;
      var _loc2_:Array = [];
      var _loc3_:int = 0;
      while(_loc3_ < param1.width)
      {
         _loc4_ = 0;
         while(_loc4_ < param1.height)
         {
            _loc2_.push(param1.getCell(_loc3_,_loc4_));
            _loc4_++;
         }
         _loc3_++;
      }
      super(_loc2_);
   }
}
