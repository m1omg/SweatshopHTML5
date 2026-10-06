package ss.utils
{
   import org.fatlib.Log;
   import ss.Constants;
   import ss.app.App;
   import ss.data.Stats;
   import ss.data.Trophy;
   import ss.remote.Shareable;
   
   public class TrophyManager
   {
      
      private var _trophies:Object;
      
      public function TrophyManager()
      {
         super();
      }
      
      public function init(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Trophy = null;
         var _loc4_:Object = null;
         Log.log("[TrophyManager] init");
         this._trophies = {};
         for(_loc2_ in param1)
         {
            _loc3_ = new Trophy();
            _loc3_.id = _loc2_;
            _loc4_ = param1[_loc2_];
            _loc3_.description = _loc4_["description"];
            _loc3_.name = _loc4_["name"];
            _loc3_.karma = _loc4_["karma"];
            _loc3_.requirements = _loc4_["requirements"];
            _loc3_.context = _loc4_["context"];
            _loc3_.shareable = new Shareable();
            _loc3_.shareable.id = _loc2_;
            _loc3_.shareable.facebookCopy = _loc4_["facebook_copy"];
            _loc3_.shareable.twitterCopy = _loc4_["twitter_copy"];
            _loc3_.shareable.imageFilestub = _loc2_;
            _loc3_.shareable.type = Constants.SHAREABLE_TROPHY;
            _loc3_.vanillaCopy = _loc4_["vanilla_copy"];
            this._trophies[_loc2_] = _loc3_;
         }
      }
      
      public function getTrophy(param1:String) : Trophy
      {
         return this._trophies[param1];
      }
      
      public function checkLevelTrophies(param1:Stats) : void
      {
         var _loc2_:Trophy = null;
         for each(_loc2_ in this._trophies)
         {
            if(_loc2_.context == "level")
            {
               this.checkTrophy(_loc2_,param1);
            }
         }
      }
      
      public function checkGlobalTrophies() : void
      {
         var _loc1_:Trophy = null;
         for each(_loc1_ in this._trophies)
         {
            if(_loc1_.context == "global")
            {
               this.checkTrophy(_loc1_,App.instance.session.stats);
            }
         }
      }
      
      public function checkResultTrophies() : void
      {
         var _loc1_:Trophy = null;
         for each(_loc1_ in this._trophies)
         {
            if(_loc1_.context == "results")
            {
               this.checkTrophy(_loc1_,App.instance.session.stats);
            }
         }
      }
      
      public function unlockTrophy(param1:String) : void
      {
         this.trophyRequirementsMet(param1);
      }
      
      public function getKarmaRange() : Array
      {
         var _loc3_:Trophy = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         for each(_loc3_ in this._trophies)
         {
            if(_loc3_.karma < 0)
            {
               _loc1_ += _loc3_.karma;
            }
            if(_loc3_.karma > 0)
            {
               _loc2_ += _loc3_.karma;
            }
         }
         return [_loc1_,_loc2_];
      }
      
      private function checkTrophy(param1:Trophy, param2:Stats) : void
      {
         var match:Boolean;
         var r:Object = null;
         var v:String = null;
         var count:int = 0;
         var type:String = null;
         var t:Trophy = param1;
         var stats:Stats = param2;
         var req:Array = t.requirements as Array;
         if(req.length == 0)
         {
            return;
         }
         match = true;
         for each(r in req)
         {
            v = r["variable"];
            count = int(r["count"]);
            switch(v)
            {
               case "deployed":
                  type = r["type"];
                  if(stats.deployed[type] != count)
                  {
                     match = false;
                  }
                  break;
               case "stagesComplete":
                  if(App.instance.session.getLevelsCompleted() < count)
                  {
                     match = false;
                  }
                  break;
               case "goldsWon":
                  if(App.instance.session.getMedalCounts()[Constants.GOLD_MEDAL] < count)
                  {
                     match = false;
                  }
                  break;
               default:
                  try
                  {
                     if(stats[v] != count)
                     {
                        match = false;
                     }
                  }
                  catch(e:Error)
                  {
                     Log.error("trophy requirments reference an unknown property:" + v);
                  }
            }
         }
         if(match)
         {
            this.trophyRequirementsMet(t.id);
         }
      }
      
      private function trophyRequirementsMet(param1:String) : void
      {
         Log.log("[TrophyManager] requirements met for " + param1 + ": \"" + this.getTrophy(param1).name + "\"");
         if(!App.instance.session.hasTrophy(param1))
         {
            App.instance.session.addTrophy(param1,true);
            App.instance.globalUI.openTrophyPopup(param1);
            App.instance.tracking.trophyWon(param1);
         }
      }
   }
}

