package ss.app
{
   import ss.Constants;
   import ss.utils.KarmaManager;
   
   public class NavUtils
   {
      
      public function NavUtils()
      {
         super();
      }
      
      public static function gotoSelectScreen(param1:Boolean = true) : void
      {
         var _loc2_:String = App.SELECT_SCREEN;
         var _loc3_:Object = {};
         if(Boolean(App.instance.session.beforeNextSelectScene) && param1)
         {
            if(App.instance.session.beforeNextSelectScene == Constants.INTRO)
            {
               _loc2_ = App.MOVIE_SCREEN;
               _loc3_["next"] = App.GAME_SCREEN;
               _loc3_["id"] = "intro.flv";
               App.instance.session.beforeNextSelectScene = null;
            }
            else
            {
               _loc2_ = App.CLIENT_SCREEN;
               _loc3_["next"] = App.SELECT_SCREEN;
               _loc3_["id"] = App.instance.session.beforeNextSelectScene;
            }
         }
         App.instance.screens.goto(_loc2_,_loc3_);
      }
      
      public static function gotoGameScreen(param1:Boolean = true) : void
      {
         var _loc2_:String = App.GAME_SCREEN;
         var _loc3_:Object = {};
         var _loc4_:String = App.instance.levels.getLevel(App.instance.session.currentLevelKey).sceneBefore;
         if(_loc4_ != null && param1)
         {
            _loc2_ = App.CLIENT_SCREEN;
            _loc3_["id"] = _loc4_;
            _loc3_["next"] = App.GAME_SCREEN;
         }
         App.instance.screens.goto(_loc2_,_loc3_);
      }
      
      public static function continueFromResultScreen() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         if(App.instance.session.currentLevelKey == "30" && !App.instance.session.hasSeenOutro)
         {
            _loc1_ = {"next":App.END_CREDITS_SCREEN};
            _loc2_ = App.instance.session.calculateKarma();
            if(KarmaManager.hasGoodEnding(_loc2_))
            {
               _loc1_["id"] = Constants.OUTRO_GOOD;
               App.instance.tracking.gameWon("Good");
            }
            else
            {
               _loc1_["id"] = Constants.OUTRO_EVIL;
               App.instance.tracking.gameWon("Evil");
            }
            App.instance.session.hasSeenOutro = true;
            App.instance.cookies.saveCurrentSessionToCurrentSlot();
            App.instance.screens.goto(App.OUTRO_SCREEN,_loc1_);
         }
         else
         {
            gotoSelectScreen();
         }
      }
      
      public static function continueFromEndCredits() : void
      {
         App.instance.screens.goto(App.SELECT_SCREEN);
      }
      
      public static function retryLevel() : void
      {
         var _loc1_:int = App.instance.session.lastResult.score;
         App.instance.tracking.levelRetried(App.instance.session.currentLevelKey,_loc1_);
         gotoGameScreen(false);
      }
   }
}

