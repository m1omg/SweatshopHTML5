package org.fatlib.utils
{
   import org.fatlib.interfaces.IDestroyable;
   
   public class DestroyList implements IDestroyable
   {
      
      private var _list:Array;
      
      public function DestroyList()
      {
         super();
      }
      
      public function add(... rest) : void
      {
         var _loc2_:Object = null;
         if(!this._list)
         {
            this._list = new Array();
         }
         for each(_loc2_ in rest)
         {
            if(!(_loc2_ is IDestroyable))
            {
               throw new Error(_loc2_ + " does not implement IDestroyable");
            }
            this._list.push(_loc2_);
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:IDestroyable = null;
         for each(_loc1_ in this._list)
         {
            _loc1_.destroy();
            _loc1_ = null;
         }
         this._list = null;
      }
   }
}

