package ss.remote
{
   import com.google.analytics.AnalyticsTracker;
   import com.google.analytics.GATracker;
   import ss.Values;
   import ss.app.App;
   
   public class GoogleAnalytics
   {
      
      private var _tracker:AnalyticsTracker;
      
      public function GoogleAnalytics()
      {
         super();
      }
      
      public function init() : void
      {
         var _loc1_:String = null;
         _loc1_ = Values.GOOGLE_ANALYTICS_LIVE_ID;
         this._tracker = new GATracker(App.instance.stage,_loc1_,"AS3",false);
      }
      
      public function gameStart() : void
      {
         this._tracker.trackEvent("Game","Start");
      }
      
      public function gameContinue() : void
      {
         this._tracker.trackEvent("Game","Continue");
      }
      
      public function gameWon(param1:String) : void
      {
         this._tracker.trackEvent("Game","Win",param1);
      }
      
      public function levelStart(param1:String) : void
      {
         this._tracker.trackEvent("Level","Start",param1);
      }
      
      public function levelLost(param1:String, param2:int) : void
      {
         this._tracker.trackEvent("Level","Lose",param1,param2);
      }
      
      public function levelWon(param1:String, param2:int) : void
      {
         this._tracker.trackEvent("Level","Win",param1,param2);
      }
      
      public function levelRestarted(param1:String, param2:int) : void
      {
         this._tracker.trackEvent("Level","Restart",param1,param2);
      }
      
      public function levelQuit(param1:String, param2:int) : void
      {
         this._tracker.trackEvent("Level","Quit",param1,param2);
      }
      
      public function levelRetried(param1:String, param2:int) : void
      {
         this._tracker.trackEvent("Level","Retry",param1,param2);
      }
      
      public function trophyWon(param1:String) : void
      {
         this._tracker.trackEvent("Trophy","Win",param1);
      }
      
      public function trophyShared(param1:String, param2:String) : void
      {
         this._tracker.trackEvent("Trophy","Share (" + param2 + ")",param1);
      }
      
      public function karmaShared(param1:String, param2:String) : void
      {
         this._tracker.trackEvent("Karma","Share (" + param2 + ")",param1);
      }
      
      public function screenChanged(param1:String) : void
      {
         this._tracker.trackEvent("Screen","Change",param1);
      }
      
      public function soundOff() : void
      {
         this._tracker.trackEvent("Sound","Off");
      }
      
      public function soundOn() : void
      {
         this._tracker.trackEvent("Sound","On");
      }
   }
}

