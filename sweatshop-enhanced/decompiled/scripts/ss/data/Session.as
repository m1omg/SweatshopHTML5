package ss.data
{
   import org.fatlib.utils.ArrayUtils;
   import ss.Constants;
   import ss.app.App;
   
   public class Session
   {
      
      public var username:String;
      
      public var currentLevelKey:String = "1";
      
      public var currentWorld:int = 1;
      
      public var lastResult:LevelResult;
      
      public var lastLevelStats:Stats;
      
      public var beforeNextSelectScene:String;
      
      public var hasSeenOutro:Boolean = false;
      
      private var _trophyIDs:Array;
      
      private var _newTrophyIDs:Array;
      
      private var _stats:Stats;
      
      private var _states:Object;
      
      public function Session()
      {
         var _loc2_:LevelState = null;
         super();
         this._states = {};
         var _loc1_:int = 1;
         while(_loc1_ <= 30)
         {
            _loc2_ = new LevelState();
            if(_loc1_ == 1)
            {
               _loc2_.unlocked = true;
            }
            this._states[_loc1_] = _loc2_;
            _loc1_++;
         }
         this._trophyIDs = [];
         this._newTrophyIDs = [];
         this._stats = new Stats();
      }
      
      public function markUnlocked(param1:String) : void
      {
         if(this._states[param1])
         {
            (this._states[param1] as LevelState).unlocked = true;
         }
      }
      
      public function markRead(param1:String) : void
      {
         if(this._states[param1])
         {
            (this._states[param1] as LevelState).hasRead = true;
         }
      }
      
      public function markWon(param1:String) : void
      {
         if(this._states[param1])
         {
            (this._states[param1] as LevelState).hasWon = true;
         }
      }
      
      public function saveScores(param1:String, param2:int) : void
      {
         (this._states[param1] as LevelState).score = param2;
         this.markWon(param1);
      }
      
      public function addTrophy(param1:String, param2:Boolean = false) : void
      {
         if(this.hasTrophy(param1))
         {
            return;
         }
         this._trophyIDs.push(param1);
         if(param2)
         {
            this._newTrophyIDs.push(param1);
         }
      }
      
      public function clearNewTrophies() : void
      {
         this._newTrophyIDs = [];
      }
      
      public function getLevelState(param1:String) : LevelState
      {
         return this._states[param1];
      }
      
      public function hasReadCurrentLevel() : Boolean
      {
         var _loc1_:LevelState = this.getLevelState(this.currentLevelKey);
         if(_loc1_)
         {
            return _loc1_.hasRead;
         }
         return false;
      }
      
      public function getCurrentLevelMedal() : String
      {
         var _loc1_:LevelState = this.getLevelState(this.currentLevelKey);
         if(_loc1_)
         {
            return _loc1_.medal;
         }
         return Constants.NO_MEDAL;
      }
      
      public function getLevelsCompleted() : int
      {
         var _loc2_:LevelState = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._states)
         {
            if(_loc2_.hasWon)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function getHighestWorldUnlocked() : int
      {
         var _loc2_:String = null;
         var _loc3_:Level = null;
         var _loc4_:LevelState = null;
         var _loc1_:int = 1;
         for(_loc2_ in this._states)
         {
            _loc3_ = App.instance.levels.getLevel(_loc2_);
            _loc4_ = this.getLevelState(_loc2_);
            if(_loc4_.unlocked && _loc3_.world > _loc1_)
            {
               _loc1_ = _loc3_.world;
            }
         }
         return _loc1_;
      }
      
      public function getHighestLevelUnlockedUnfinished() : String
      {
         var _loc3_:String = null;
         var _loc4_:Level = null;
         var _loc5_:LevelState = null;
         var _loc1_:String = null;
         var _loc2_:int = 1;
         while(_loc2_ <= 30)
         {
            _loc3_ = _loc2_.toString();
            _loc4_ = App.instance.levels.getLevel(_loc3_);
            _loc5_ = this.getLevelState(_loc3_);
            if(_loc5_.unlocked && !_loc5_.hasWon)
            {
               _loc1_ = _loc3_;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getMedalCounts() : Object
      {
         var _loc2_:LevelState = null;
         var _loc1_:Object = {};
         _loc1_[Constants.BRONZE_MEDAL] = 0;
         _loc1_[Constants.SILVER_MEDAL] = 0;
         _loc1_[Constants.GOLD_MEDAL] = 0;
         for each(_loc2_ in this._states)
         {
            ++_loc1_[_loc2_.medal];
         }
         return _loc1_;
      }
      
      public function hasTrophy(param1:String) : Boolean
      {
         return ArrayUtils.contains(this._trophyIDs,param1);
      }
      
      public function isNewTrophy(param1:String) : Boolean
      {
         return ArrayUtils.contains(this._newTrophyIDs,param1);
      }
      
      public function getTrophiesAwarded() : int
      {
         return this._trophyIDs.length;
      }
      
      public function calculateKarma() : int
      {
         var _loc2_:String = null;
         var _loc3_:Trophy = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._trophyIDs)
         {
            _loc3_ = App.instance.trophies.getTrophy(_loc2_);
            _loc1_ += _loc3_.karma;
         }
         return _loc1_;
      }
      
      public function loadFromObject(param1:Object) : void
      {
         var data:Object = param1;
         var i:int = 1;
         while(i <= 30)
         {
            (this._states[i.toString()] as LevelState).decode(data["levels"][i]);
            i++;
         }
         this.currentLevelKey = data["currentLevelKey"];
         this.beforeNextSelectScene = data["beforeNextSelectScene"];
         this.username = data["username"];
         this.hasSeenOutro = data["hasSeenOutro"];
         try
         {
            this._trophyIDs = data["trophies"];
         }
         catch(e:Error)
         {
            _trophyIDs = [];
         }
         this._stats = Stats.fromObject(data["stats"]);
      }
      
      public function toObject() : Object
      {
         var _loc3_:LevelState = null;
         var _loc1_:Object = {"levels":{}};
         var _loc2_:int = 1;
         while(_loc2_ <= 30)
         {
            _loc3_ = this._states[_loc2_];
            _loc1_["levels"][_loc2_.toString()] = _loc3_.encode();
            _loc2_++;
         }
         _loc1_["currentLevelKey"] = this.currentLevelKey;
         _loc1_["currentLevelKey"] = this.currentLevelKey;
         _loc1_["beforeNextSelectScene"] = this.beforeNextSelectScene;
         _loc1_["username"] = this.username;
         _loc1_["trophies"] = this._trophyIDs;
         _loc1_["stats"] = Stats.toObject(this._stats);
         _loc1_["hasSeenOutro"] = this.hasSeenOutro;
         return _loc1_;
      }
      
      public function toString() : String
      {
         return "[Session " + this.username + "]";
      }
      
      public function get stats() : Stats
      {
         return this._stats;
      }
   }
}

