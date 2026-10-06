package ss.game.entities
{
   import org.fatlib.interfaces.IIterator;
   import org.fatlib.iterators.ArrayIterator;
   import ss.game.data.Effect;
   import ss.game.data.IEffector;
   
   public class FireHazard extends MapEntity implements IEffector
   {
      
      public static const ON_UPDATED:String = "ON_UPDATED";
      
      public var effect:Effect;
      
      public var activateChance:Number;
      
      public var isProtected:Boolean;
      
      public var isSparking:Boolean;
      
      public function FireHazard()
      {
         super();
      }
      
      override public function prepare() : void
      {
         selectable = false;
      }
      
      public function getActiveEffectsIterator() : IIterator
      {
         if(this.isSparking && !this.isProtected)
         {
            return new ArrayIterator([this.effect]);
         }
         return new ArrayIterator([]);
      }
      
      public function startSparking() : void
      {
         this.isSparking = true;
         broadcastLocalMessage(ON_UPDATED);
      }
      
      public function stopSparking() : void
      {
         this.isSparking = false;
         broadcastLocalMessage(ON_UPDATED);
      }
      
      public function protect() : void
      {
         this.isProtected = true;
         broadcastLocalMessage(ON_UPDATED);
      }
      
      public function unprotect() : void
      {
         this.isProtected = false;
         broadcastLocalMessage(ON_UPDATED);
      }
   }
}

