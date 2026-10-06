package ss.utils
{
   import org.fatlib.Log;
   import ss.Constants;
   import ss.app.App;
   import ss.data.Level;
   import ss.data.LevelResult;
   import ss.data.LevelState;
   import ss.data.Session;
   
   public class SessionUtils
   {
      
      public function SessionUtils()
      {
         super();
      }
      
      public static function saveProgress() : void
      {
         if(App.instance.cookies.currentSlot == -1)
         {
            Log.warn("[SessionUtils] no save slot so saving is disabled");
            return;
         }
         var _loc1_:LevelResult = App.instance.session.lastResult;
         var _loc2_:String = App.instance.session.currentLevelKey;
         if(_loc1_.finished)
         {
            if(_loc1_.won)
            {
               App.instance.session.lastResult.isNewRecord = levelWon(_loc2_,_loc1_);
               unlockNextLevel(_loc2_);
            }
            else
            {
               App.instance.session.lastResult.isNewRecord = false;
               levelLost(_loc2_,_loc1_);
            }
         }
         else
         {
            levelUnfinished(_loc2_);
         }
         App.instance.cookies.saveCurrentSessionToCurrentSlot();
      }
      
      private static function unlockNextLevel(param1:String) : void
      {
         var _loc2_:String = App.instance.levels.getLevel(param1).next;
         if(_loc2_ == "end" || App.instance.session.getLevelState(_loc2_).unlocked)
         {
            return;
         }
         App.instance.session.markUnlocked(_loc2_);
         Log.log("[SessionUtils] unlocking " + _loc2_);
         var _loc3_:Level = App.instance.levels.getLevel(param1);
         if(_loc3_.sceneAfter)
         {
            App.instance.session.beforeNextSelectScene = _loc3_.sceneAfter;
         }
      }
      
      private static function levelWon(param1:String, param2:LevelResult) : Boolean
      {
         var _loc3_:LevelState = App.instance.session.getLevelState(param1);
         var _loc4_:Boolean = false;
         if(param2.score > _loc3_.score)
         {
            _loc3_.score = param2.score;
            Log.log("[SessionUtils] level won, replacing score (" + param2.score + ">" + _loc3_.score + ")");
            _loc4_ = true;
         }
         else
         {
            Log.log("[SessionUtils] level won, score lower (" + param2.score + "<" + _loc3_.score + ")");
         }
         App.instance.session.saveScores(param1,_loc3_.score);
         return _loc4_;
      }
      
      private static function levelUnfinished(param1:String) : void
      {
         Log.log("[SessionUtils] level unfinished");
      }
      
      private static function levelLost(param1:String, param2:LevelResult) : void
      {
         Log.log("[SessionUtils] level lost:" + param2.reason);
      }
      
      public static function createGodSession(param1:Boolean = true) : Session
      {
         var _loc2_:Session = new Session();
         _loc2_.currentLevelKey = "1";
         _loc2_.currentWorld = 1;
         _loc2_.markUnlocked("30");
         _loc2_.username = "<GOD>";
         var _loc3_:int = 1;
         while(_loc3_ < 30)
         {
            _loc2_.saveScores(_loc3_.toString(),25);
            _loc2_.markRead(_loc3_.toString());
            _loc2_.markUnlocked(_loc3_.toString());
            _loc2_.markWon(_loc3_.toString());
            _loc3_++;
         }
         _loc2_.addTrophy("t1");
         _loc2_.addTrophy("t2");
         _loc2_.addTrophy("t3");
         _loc2_.addTrophy("t4");
         if(param1)
         {
            _loc2_.addTrophy("t7");
            _loc2_.addTrophy("t8");
            _loc2_.addTrophy("t9");
            _loc2_.addTrophy("t14");
            _loc2_.addTrophy("t16");
            _loc2_.addTrophy("t17");
            _loc2_.addTrophy("t20");
         }
         else
         {
            _loc2_.addTrophy("t10");
            _loc2_.addTrophy("t11");
            _loc2_.addTrophy("t12");
            _loc2_.addTrophy("t13");
            _loc2_.addTrophy("t15");
            _loc2_.addTrophy("t18");
            _loc2_.addTrophy("t19");
         }
         return _loc2_;
      }
      
      public static function createCheatSession(param1:int) : Session
      {
         var _loc2_:Session = new Session();
         _loc2_.currentLevelKey = param1.toString();
         _loc2_.currentWorld = 1;
         _loc2_.username = "<LVL-" + param1 + ">";
         var _loc3_:int = 1;
         while(_loc3_ < param1)
         {
            _loc2_.saveScores(_loc3_.toString(),25);
            _loc2_.markRead(_loc3_.toString());
            _loc2_.markUnlocked(_loc3_.toString());
            _loc3_++;
         }
         _loc2_.markUnlocked(param1.toString());
         return _loc2_;
      }
      
      public static function createEmptySession() : Session
      {
         var _loc1_:Session = new Session();
         _loc1_.markUnlocked("1");
         _loc1_.beforeNextSelectScene = Constants.INTRO;
         return _loc1_;
      }
      
      public static function logout() : void
      {
         App.instance.session = null;
      }
   }
}

