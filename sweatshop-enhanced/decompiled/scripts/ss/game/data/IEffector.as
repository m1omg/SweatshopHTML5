package ss.game.data
{
   import flash.geom.Point;
   import org.fatlib.interfaces.IIterator;
   
   public interface IEffector
   {
      
      function getActiveEffectsIterator() : IIterator;
      
      function get position() : Point;
   }
}

