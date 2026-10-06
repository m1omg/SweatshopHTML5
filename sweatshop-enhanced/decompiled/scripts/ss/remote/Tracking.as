package ss.remote
{
   import org.fatlib.app.ScreenManager;
   import org.fatlib.events.CustomEvent;
   import ss.app.App;
   import ss.app.PopupManager;
   
   public class Tracking
   {
      
      public var omniture:Omniture;
      
      public var analytics:GoogleAnalytics;
      
      public function Tracking()
      {
         super();
         this.omniture = new Omniture();
         this.analytics = new GoogleAnalytics();
      }
      
      public function init() : void
      {
         this.omniture.init();
         this.analytics.init();
         App.instance.screens.addEventListener(ScreenManager.SCREEN_INITED,this.onScreenChanged);
         App.instance.popups.addEventListener(PopupManager.OPENED,this.onScreenChanged);
         App.instance.popups.addEventListener(PopupManager.CLOSED,this.onPopupClosed);
      }
      
      public function gameStart() : void
      {
         this.omniture.gameStart();
         this.analytics.gameStart();
      }
      
      public function gameWon(param1:String) : void
      {
         this.omniture.gameWon();
         this.analytics.gameWon(param1);
      }
      
      public function levelStart(param1:String) : void
      {
         this.omniture.levelStart(param1);
         this.analytics.levelStart(param1);
      }
      
      public function levelLost(param1:String, param2:int) : void
      {
         this.omniture.levelLost(param1,param2);
         this.analytics.levelLost(param1,param2);
      }
      
      public function levelWon(param1:String, param2:int, param3:int) : void
      {
         this.omniture.levelWon(param1,param2);
         this.analytics.levelWon(param1,param3);
      }
      
      public function levelRetried(param1:String, param2:int) : void
      {
         this.analytics.levelRetried(param1,param2);
      }
      
      public function levelRestarted(param1:String, param2:int) : void
      {
         this.analytics.levelRestarted(param1,param2);
      }
      
      public function levelQuit(param1:String, param2:int) : void
      {
         this.analytics.levelQuit(param1,param2);
      }
      
      public function gameContinue() : void
      {
         this.analytics.gameContinue();
      }
      
      public function screenChanged(param1:String) : void
      {
         this.analytics.screenChanged(param1);
      }
      
      public function trophyShared(param1:String, param2:String) : void
      {
         this.analytics.trophyShared(param1,param2);
      }
      
      public function karmaShared(param1:String, param2:String) : void
      {
         this.analytics.karmaShared(param1,param2);
      }
      
      public function trophyWon(param1:String) : void
      {
         this.analytics.trophyWon(param1);
      }
      
      public function soundOff() : void
      {
         this.analytics.soundOff();
      }
      
      public function soundOn() : void
      {
         this.analytics.soundOn();
      }
      
      private function onScreenChanged(param1:CustomEvent) : void
      {
         this.screenChanged(param1.data.name);
      }
      
      private function onPopupClosed(param1:CustomEvent) : void
      {
         this.screenChanged(param1.data.base);
      }
   }
}

