package ss.game.entities
{
   import org.fatlib.struct.Grid;
   import ss.Values;
   import ss.game.Game;
   import ss.game.core.Entity;
   import ss.game.data.Effect;
   
   public class Environment extends Entity
   {
      
      public static const FIRE_RISK:String = "fire_risk";
      
      public static const FIRE_PROTECTION:String = "fire_protection";
      
      public static const ACCIDENT_RISK:String = "accident_risk";
      
      public static const CASH_BONUS:String = "cash_bonus";
      
      public static const SKILL_MODIFIER:String = "skill_modifier";
      
      public static const STAMINA_MODIFIER:String = "stamina_modifier";
      
      public static const RECHARGE_MODIFIER:String = "recharge_modifier";
      
      public var layers:Array;
      
      private var _grid:Grid;
      
      public function Environment()
      {
         super();
      }
      
      override public function prepare() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         this.layers = [FIRE_RISK,FIRE_PROTECTION,ACCIDENT_RISK,SKILL_MODIFIER,STAMINA_MODIFIER,RECHARGE_MODIFIER,CASH_BONUS];
         this._grid = new Grid(Game.level.mapWidth,Game.level.mapHeight);
         var _loc1_:int = 0;
         while(_loc1_ < this._grid.width)
         {
            _loc2_ = 0;
            while(_loc2_ < this._grid.height)
            {
               _loc3_ = {};
               for each(_loc4_ in this.layers)
               {
                  _loc3_[_loc4_] = this.getBaseValue(_loc4_);
               }
               this._grid.setCell(_loc1_,_loc2_,_loc3_);
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function getValue(param1:String, param2:int, param3:int) : Number
      {
         if(!this._grid.getCell(param2,param3))
         {
            return 0;
         }
         return this._grid.getCell(param2,param3)[param1];
      }
      
      public function addValue(param1:String, param2:int, param3:int, param4:Number, param5:Boolean) : void
      {
         if(!this._grid.getCell(param2,param3))
         {
            return;
         }
         var _loc6_:int = int(this._grid.getCell(param2,param3)[param1]);
         if(param5 && param4 <= _loc6_)
         {
            return;
         }
         this._grid.getCell(param2,param3)[param1] = this._grid.getCell(param2,param3)[param1] + param4;
      }
      
      public function resetToBase() : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._grid.width)
         {
            _loc2_ = 0;
            while(_loc2_ < this._grid.height)
            {
               for each(_loc3_ in this.layers)
               {
                  this._grid.getCell(_loc1_,_loc2_)[_loc3_] = this.getBaseValue(_loc3_);
               }
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function applyEffect(param1:Effect) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:Boolean = !param1.stackEffects;
         var _loc3_:int = -param1.range;
         while(_loc3_ <= param1.range)
         {
            _loc4_ = -param1.range;
            while(_loc4_ <= param1.range)
            {
               _loc5_ = param1.position.x + _loc3_;
               _loc6_ = param1.position.y + _loc4_;
               _loc7_ = _loc3_ * _loc3_ + _loc4_ * _loc4_;
               if(_loc7_ < param1.range * param1.range)
               {
                  this.addValue(param1.type,_loc5_,_loc6_,param1.amount,_loc2_);
               }
               _loc4_++;
            }
            _loc3_++;
         }
      }
      
      public function getBaseValue(param1:String) : Number
      {
         var _loc2_:Number = NaN;
         var _loc3_:Belt = null;
         switch(param1)
         {
            case ACCIDENT_RISK:
               _loc2_ = Game.level.accidentRisk;
               _loc3_ = engine.find("belt") as Belt;
               if(Boolean(_loc3_) && _loc3_.speedSetting == Belt.FAST)
               {
                  _loc2_ *= Values.FAST_BELT_SPEED / Values.SLOW_BELT_SPEED;
               }
               return _loc2_;
            case FIRE_RISK:
            case FIRE_PROTECTION:
               return 0;
            case STAMINA_MODIFIER:
               return Game.level.staminaModifier;
            case SKILL_MODIFIER:
               return Game.level.skillModifier;
            case CASH_BONUS:
               return 0;
            default:
               return 0;
         }
      }
   }
}

