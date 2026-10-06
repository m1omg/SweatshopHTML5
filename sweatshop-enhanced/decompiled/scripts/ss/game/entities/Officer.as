package ss.game.entities
{
   import org.fatlib.interfaces.IIterator;
   import org.fatlib.iterators.ArrayIterator;
   import ss.game.data.Effect;
   import ss.game.data.IEffector;
   
   public class Officer extends Unit implements IEffector
   {
      
      public static const FIRE_OFFICER:String = "fire_officer";
      
      public static const ENGINEER:String = "engineer";
      
      private var _effects:Array;
      
      public function Officer()
      {
         super();
      }
      
      public function getActiveEffectsIterator() : IIterator
      {
         if(!this._effects)
         {
            this._effects = [];
         }
         return new ArrayIterator(this._effects);
      }
      
      public function addEffect(param1:Effect) : void
      {
         if(!this._effects)
         {
            this._effects = [];
         }
         this._effects.push(param1);
      }
      
      public function getEffectLayer() : String
      {
         switch(type)
         {
            case FIRE_OFFICER:
               return Environment.FIRE_RISK;
            case ENGINEER:
               return Environment.ACCIDENT_RISK;
            default:
               return "";
         }
      }
      
      public function removeAllEffects() : void
      {
         this._effects = [];
      }
   }
}

