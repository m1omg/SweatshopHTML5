package ss.game.data
{
   import org.fatlib.interfaces.ICloneable;
   
   public class SequenceElement implements ICloneable
   {
      
      public var type:String;
      
      public var predelay:Number = 5;
      
      public var interval:Number = 2;
      
      public var amount:int = 1;
      
      public function SequenceElement()
      {
         super();
      }
      
      public function clone() : ICloneable
      {
         var _loc1_:SequenceElement = new SequenceElement();
         _loc1_.type = this.type;
         _loc1_.interval = this.interval;
         _loc1_.amount = this.amount;
         _loc1_.predelay = this.predelay;
         return _loc1_;
      }
   }
}

