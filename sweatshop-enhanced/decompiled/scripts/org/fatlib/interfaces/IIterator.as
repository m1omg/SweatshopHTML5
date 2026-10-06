package org.fatlib.interfaces
{
   public interface IIterator
   {
      
      function get hasNext() : Boolean;
      
      function get next() : *;
      
      function get position() : int;
   }
}

