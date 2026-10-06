package ss.app.screens
{
   import flash.display.MovieClip;
   import org.fatlib.app.Screen;
   import ss.app.App;
   import ss.app.NavUtils;
   import ss.data.Level;
   import ss.data.LevelResult;
   import ss.data.Stats;
   import ss.utils.ScoreUtils;
   import ss.utils.Utils;
   
   public class ResultsScreen extends Screen
   {
      
      private var _mc:MovieClip;
      
      public function ResultsScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         this._mc = App.instance.resources.instantiateMovieClip("ui","LevelResultsSymbol");
         display.addChild(this._mc);
         App.instance.audio.playMusic("results");
         var _loc1_:LevelResult = App.instance.session.lastResult;
         var _loc2_:Stats = App.instance.session.lastLevelStats;
         var _loc3_:Level = App.instance.levels.getLevel(App.instance.session.currentLevelKey);
         this._mc["title"].text = "STAGE " + App.instance.session.currentLevelKey + " SUMMARY";
         this._mc["medal"].gotoAndStop(ScoreUtils.getMedal(_loc1_.score));
         this._mc["score"].text = _loc1_.score + "%";
         this._mc["hired"].text = _loc2_.unitsHired;
         this._mc["injured"].text = _loc2_.workersInjured;
         this._mc["killed"].text = _loc2_.workersKilled;
         this._mc["refreshed"].text = _loc2_.tiredWorkersRefreshed;
         this._mc["upgraded"].text = _loc2_.unitsUpgraded;
         this._mc["features"].text = _loc2_.featuresDeployed;
         this._mc["fact"].text = _loc3_.fact;
         App.instance.trophies.checkResultTrophies();
         Utils.fadeFromBGColor(display);
      }
      
      override public function handleRemoved() : void
      {
         App.instance.audio.stopMusic();
      }
      
      override protected function handleClicked(param1:String) : void
      {
         switch(param1)
         {
            case "cont":
               NavUtils.continueFromResultScreen();
               break;
            case "retry":
               NavUtils.retryLevel();
               break;
            case "player":
               App.instance.popups.open(App.PLAYER_SCREEN);
         }
      }
   }
}

