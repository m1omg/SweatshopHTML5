package ss.game.data
{
   import flash.geom.Point;
   
   public class Effect
   {
      
      public var type:String;
      
      public var position:Point;
      
      public var amount:Number;
      
      public var range:int;
      
      public var stackEffects:Boolean;
      
      public function Effect()
      {
         super();
      }
      
      public function toString() : String
      {
         return "[Effect " + this.type + " range=" + this.range + ", amount=" + this.amount + " at " + this.position + "]";
      }
   }
}

