package ss.app.screens
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import org.fatlib.Log;
   import org.fatlib.app.Screen;
   import org.fatlib.display.WireframeButton;
   import org.fatlib.events.CustomEvent;
   import ss.Constants;
   import ss.Values;
   import ss.app.App;
   import ss.app.NavUtils;
   import ss.app.screens.title.SlotsScreenManager;
   import ss.data.Session;
   import ss.utils.AudioUtils;
   import ss.utils.SessionUtils;
   import ss.utils.Utils;
   
   public class TitleScreen extends Screen
   {
      
      private var _mc:MovieClip;
      
      private var _slots:SlotsScreenManager;
      
      public function TitleScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         this._mc = App.instance.resources.instantiateMovieClip("ui","TitleScreenSymbol");
         display.addChild(this._mc);
         if(Values.DEBUG_MODE)
         {
            display.addChild(new WireframeButton("good"));
            display.addChild(new WireframeButton("evil")).y = 20;
            display.addChild(new WireframeButton("level_10")).y = 40;
            display.addChild(new WireframeButton("level_20")).y = 60;
            display.addChild(new WireframeButton("god_good")).y = 80;
            display.addChild(new WireframeButton("god_evil")).y = 100;
         }
         this._slots = new SlotsScreenManager(this._mc["slots"]);
         this._slots.addEventListener(SlotsScreenManager.CLOSE,this.onClose);
         this._slots.addEventListener(SlotsScreenManager.ERASE,this.onErase);
         this._slots.addEventListener(SlotsScreenManager.NEW,this.onNew);
         this._slots.addEventListener(SlotsScreenManager.CONTINUE,this.onContinue);
         this.refreshSlotInfo();
         this._slots.hide();
         App.instance.audio.playMusic("title");
         Utils.fadeFromBGColor(display);
      }
      
      private function onContinue(param1:CustomEvent) : void
      {
         var _loc2_:int = int(param1.data["slot"]);
         Log.log("[TitleScreen] continuing game in slot " + _loc2_);
         App.instance.cookies.currentSlot = _loc2_;
         App.instance.cookies.loadSessionFromCurrentSlot();
         App.instance.session.currentWorld = App.instance.session.getHighestWorldUnlocked();
         App.instance.tracking.gameContinue();
         NavUtils.gotoSelectScreen();
      }
      
      private function onNew(param1:CustomEvent) : void
      {
         var _loc2_:String = param1.data["name"];
         var _loc3_:int = int(param1.data["slot"]);
         Log.log("[TitleScreen] making new game in slot " + _loc3_ + " with name " + _loc2_);
         App.instance.session = SessionUtils.createEmptySession();
         App.instance.session.username = _loc2_;
         App.instance.cookies.currentSlot = _loc3_;
         App.instance.cookies.saveCurrentSessionToCurrentSlot();
         App.instance.tracking.gameStart();
         NavUtils.gotoSelectScreen();
      }
      
      private function onErase(param1:CustomEvent) : void
      {
         var _loc2_:int = int(param1.data["slot"]);
         App.instance.cookies.erase(_loc2_);
         Log.log("[TitleScreen] erasing slot " + _loc2_);
         this.refreshSlotInfo();
         this._slots.show();
      }
      
      private function onClose(param1:Event) : void
      {
         this._slots.hide();
      }
      
      private function refreshSlotInfo() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:Session = null;
         for each(_loc1_ in [1,2,3])
         {
            _loc2_ = App.instance.cookies.getSlotData(_loc1_);
            if(_loc2_)
            {
               _loc3_ = new Session();
               _loc3_.loadFromObject(_loc2_);
               this._slots.setInfo(_loc1_,_loc3_);
            }
            else
            {
               this._slots.setInfo(_loc1_,null);
            }
         }
      }
      
      override public function handleRemoved() : void
      {
         this._slots.removeEventListener(SlotsScreenManager.CLOSE,this.onClose);
         this._slots.removeEventListener(SlotsScreenManager.ERASE,this.onErase);
         this._slots.removeEventListener(SlotsScreenManager.NEW,this.onNew);
         this._slots.removeEventListener(SlotsScreenManager.CONTINUE,this.onContinue);
         this._slots.destroy();
         App.instance.audio.stopMusic();
      }
      
      override protected function handleClicked(param1:String) : void
      {
         switch(param1)
         {
            case "mainSiteBtn":
               navigateToURL(new URLRequest("http://www.playsweatshop.com"));
               break;
            case "start":
               this._slots.show();
               AudioUtils.uiOpen();
               break;
            case "credits":
               App.instance.popups.open(App.CREDITS_SCREEN);
               AudioUtils.uiNav();
               break;
            case "good":
               App.instance.cookies.saveSessionToSlot(4,SessionUtils.createGodSession(false));
               App.instance.cookies.currentSlot = 4;
               App.instance.cookies.loadSessionFromCurrentSlot();
               App.instance.session.currentWorld = App.instance.session.getHighestWorldUnlocked();
               gotoScreen(App.OUTRO_SCREEN,{"id":Constants.OUTRO_GOOD});
               break;
            case "evil":
               App.instance.cookies.saveSessionToSlot(4,SessionUtils.createGodSession(true));
               App.instance.cookies.currentSlot = 4;
               App.instance.cookies.loadSessionFromCurrentSlot();
               App.instance.session.currentWorld = App.instance.session.getHighestWorldUnlocked();
               gotoScreen(App.OUTRO_SCREEN,{"id":Constants.OUTRO_EVIL});
               break;
            case "level_10":
               App.instance.cookies.saveSessionToSlot(4,SessionUtils.createCheatSession(10));
               App.instance.cookies.currentSlot = 4;
               App.instance.cookies.loadSessionFromCurrentSlot();
               App.instance.session.currentWorld = App.instance.session.getHighestWorldUnlocked();
               NavUtils.gotoSelectScreen();
               break;
            case "level_20":
               App.instance.cookies.saveSessionToSlot(4,SessionUtils.createCheatSession(20));
               App.instance.cookies.currentSlot = 4;
               App.instance.cookies.loadSessionFromCurrentSlot();
               App.instance.session.currentWorld = App.instance.session.getHighestWorldUnlocked();
               NavUtils.gotoSelectScreen();
               break;
            case "god_evil":
               App.instance.cookies.saveSessionToSlot(4,SessionUtils.createGodSession(true));
               App.instance.cookies.currentSlot = 4;
               App.instance.cookies.loadSessionFromCurrentSlot();
               App.instance.session.currentWorld = App.instance.session.getHighestWorldUnlocked();
               NavUtils.gotoSelectScreen();
               break;
            case "god_good":
               App.instance.cookies.saveSessionToSlot(4,SessionUtils.createGodSession(false));
               App.instance.cookies.currentSlot = 4;
               App.instance.cookies.loadSessionFromCurrentSlot();
               App.instance.session.currentWorld = App.instance.session.getHighestWorldUnlocked();
               NavUtils.gotoSelectScreen();
         }
      }
   }
}

