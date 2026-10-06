package ss.utils
{
   import org.fatlib.Log;
   import ss.Values;
   import ss.data.Level;
   
   public class LevelManager
   {
      
      public static const KEY:String = "key";
      
      public static const WORLD:String = "world";
      
      public static const MAP:String = "map";
      
      public static const SEQUENCE:String = "sequence";
      
      public static const AVAIL:String = "avail";
      
      public static const NEW:String = "new";
      
      public static const MUSIC:String = "music";
      
      public static const FACT:String = "fact";
      
      public static const ACCIDENT_RISK:String = "accident_risk";
      
      public static const SKILL_MODIFIER:String = "skill_modifier";
      
      public static const STAMINA_MODIFIER:String = "stamina_modifier";
      
      public static const EXTRA_TIME:String = "extra_time";
      
      public static const CASH:String = "cash";
      
      public static const ALLOWED_REJECTIONS:String = "allowed_rejections";
      
      public static const STORY:String = "story";
      
      public static const NEXT:String = "next";
      
      public static const CUT_SCENE:String = "cut_scene";
      
      public static const BEFORE:String = "before";
      
      public static const AFTER:String = "after";
      
      private var _levels:Object;
      
      public function LevelManager()
      {
         super();
      }
      
      public function init(param1:Object) : void
      {
         var c:int;
         var k:String = null;
         var data:Object = param1;
         Log.log("[LevelManager] init");
         this._levels = {};
         c = 0;
         for(k in data)
         {
            try
            {
               this._levels[k] = this.createLevel(k,data);
               c++;
            }
            catch(e:Error)
            {
               Log.error("[LevelManager] error parsing level " + k);
            }
         }
         Log.log("[LevelManager] created " + c + " levels");
      }
      
      public function getLevel(param1:String) : Level
      {
         return this._levels[param1];
      }
      
      private function createLevel(param1:String, param2:Object) : Level
      {
         var _loc3_:Object = param2[param1];
         var _loc4_:Level = new Level(_loc3_[KEY],_loc3_[WORLD]);
         _loc4_.next = _loc3_[NEXT];
         _loc4_.availableUnits = _loc3_[AVAIL];
         _loc4_.newUnits = _loc3_[NEW];
         _loc4_.musicTrack = _loc3_[MUSIC];
         _loc4_.fact = _loc3_[FACT];
         _loc4_.accidentRiskSetting = _loc3_[ACCIDENT_RISK];
         if(_loc3_[ACCIDENT_RISK] == 1)
         {
            _loc4_.accidentRisk = Values.LOW_ACCIDENT_RISK;
         }
         if(_loc3_[ACCIDENT_RISK] == 2)
         {
            _loc4_.accidentRisk = Values.HIGH_ACCIDENT_RISK;
         }
         _loc4_.extraTime = _loc3_[EXTRA_TIME];
         _loc4_.startingCash = _loc3_[CASH];
         _loc4_.allowedRejections = _loc3_[ALLOWED_REJECTIONS];
         _loc4_.staminaModifier = _loc3_[STAMINA_MODIFIER];
         _loc4_.skillModifier = _loc3_[SKILL_MODIFIER];
         _loc4_.storyXML = new XML(unescape(_loc3_[STORY]));
         _loc4_.sceneBefore = _loc3_[CUT_SCENE][BEFORE];
         _loc4_.sceneAfter = _loc3_[CUT_SCENE][AFTER];
         _loc4_.scoreProfitFraction = _loc3_["profit_for_max_cash_bonus"];
         _loc4_.scoreFastFraction = _loc3_["fast_fraction_for_max_time_bonus"];
         return _loc4_;
      }
   }
}

