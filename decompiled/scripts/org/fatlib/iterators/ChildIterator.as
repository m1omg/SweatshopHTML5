package org.fatlib.iterators
{
   import flash.display.DisplayObjectContainer;
   
   public class ChildIterator extends ArrayIterator
   {
      
      private var _position:int;
      
      private var _childList:Array;
      
      public function ChildIterator(param1:DisplayObjectContainer)
      {
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < param1.numChildren)
         {
            _loc2_.push(param1.getChildAt(_loc3_));
            _loc3_++;
         }
         super(_loc2_);
      }
   }
}

