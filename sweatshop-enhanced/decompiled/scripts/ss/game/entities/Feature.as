package ss.game.entities
{
   import org.fatlib.interfaces.IIterator;
   import org.fatlib.iterators.ArrayIterator;
   import ss.game.data.Effect;
   import ss.game.data.IEffector;
   
   public class Feature extends MapEntity implements IEffector
   {
      
      public static const DEACTIVATED_STATE:String = "DEACTIVATED_STATE";
      
      public static const ACTIVATED_STATE:String = "ACTIVATED_STATE";
      
      public static const ON_EFFECTED_WORKERS_CHANGED:String = "ON_EFFECTED_WORKERS_CHANGED";
      
      public var duration:Number;
      
      public var range:int;
      
      public var effectedTiles:Array;
      
      public var effectedWorkers:Array;
      
      public var effectedWorkerTiles:Array;
      
      public var overlayColor:int;
      
      public var isAmbient:Boolean;
      
      private var _effects:Array;
      
      public function Feature()
      {
         super();
      }
      
      public function getActiveEffectsIterator() : IIterator
      {
         var _loc2_:Effect = null;
         var _loc1_:Array = [];
         if(!this._effects)
         {
            this._effects = [];
         }
         for each(_loc2_ in this._effects)
         {
            if(this.isAmbient)
            {
               _loc1_.push(_loc2_);
            }
            else if(this.isActivated)
            {
               _loc1_.push(_loc2_);
            }
         }
         return new ArrayIterator(_loc1_);
      }
      
      public function addEffect(param1:Effect) : void
      {
         if(!this._effects)
         {
            this._effects = [];
         }
         this._effects.push(param1);
      }
      
      public function get isActivated() : Boolean
      {
         return state == ACTIVATED_STATE;
      }
      
      public function set isActivated(param1:Boolean) : void
      {
         if(param1)
         {
            this.changeState(ACTIVATED_STATE);
         }
         else
         {
            this.changeState(DEACTIVATED_STATE);
         }
      }
      
      public function getPrimaryEffectType() : String
      {
         if(this._effects.length == 0)
         {
            return null;
         }
         return (this._effects[0] as Effect).type;
      }
      
      override public function changeState(param1:String) : void
      {
         super.changeState(param1);
         selectable = state != BURNING_STATE && state != SOOT_STATE;
      }
   }
}

