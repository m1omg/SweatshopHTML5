package ss.app
{
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.display.Stage;
   import org.fatlib.Log;
   import org.fatlib.app.ScreenManager;
   import org.fatlib.assets.ResourceBank;
   import org.fatlib.interfaces.IDisplayable;
   import org.fatlib.process.Callback;
   import org.fatlib.process.MacroProcess;
   import org.fatlib.ui.Key;
   import org.fatlib.utils.DisplayUtils;
   import org.fatlib.utils.NetUtils;
   import ss.Values;
   import ss.app.process.*;
   import ss.data.Session;
   import ss.remote.Social;
   import ss.remote.Tracking;
   import ss.utils.AudioManager;
   import ss.utils.Console;
   import ss.utils.KarmaManager;
   import ss.utils.LevelManager;
   import ss.utils.SessionUtils;
   import ss.utils.TextManager;
   import ss.utils.TrophyManager;
   import ss.utils.Utils;
   
   public class App implements IDisplayable
   {
      
      public static var instance:App;
      
      public static const SPLASH_SCREEN:String = "splash";
      
      public static const TITLE_SCREEN:String = "title";
      
      public static const GAME_SCREEN:String = "game";
      
      public static const SELECT_SCREEN:String = "select";
      
      public static const WIN_SCREEN:String = "win";
      
      public static const LOSE_SCREEN:String = "lose";
      
      public static const RESULTS_SCREEN:String = "results";
      
      public static const HELP_SCREEN:String = "help";
      
      public static const PLAYER_SCREEN:String = "player";
      
      public static const CREDITS_SCREEN:String = "credits";
      
      public static const CLIENT_SCREEN:String = "client";
      
      public static const MOVIE_SCREEN:String = "movie";
      
      public static const OUTRO_SCREEN:String = "outro";
      
      public static const END_SCREEN:String = "end";
      
      public static const END_CREDITS_SCREEN:String = "end_credits";
      
      public var flashvars:Object;
      
      public var stage:Stage;
      
      public var screens:ScreenManager;
      
      public var popups:PopupManager;
      
      public var resources:ResourceBank;
      
      public var console:Console;
      
      public var data:Object;
      
      public var session:Session;
      
      public var text:TextManager;
      
      public var audio:AudioManager;
      
      public var cookies:Cookies;
      
      public var globalUI:GlobalUI;
      
      public var trophies:TrophyManager;
      
      public var levels:LevelManager;
      
      public var karma:KarmaManager;
      
      public var social:Social;
      
      public var tracking:Tracking;
      
      private var _display:Sprite;
      
      public function App(param1:Stage)
      {
         var _loc3_:Sprite = null;
         super();
         instance = this;
         this.stage = param1;
         this.flashvars = NetUtils.getFlashVars(param1);
         new ConfigureContextProcess().execute();
         this.screens = new ScreenManager();
         this.popups = new PopupManager();
         this.resources = new ResourceBank();
         this.console = new Console();
         this.session = new Session();
         this.text = new TextManager();
         this.audio = new AudioManager();
         this.cookies = new Cookies();
         this.globalUI = new GlobalUI();
         this.trophies = new TrophyManager();
         this.levels = new LevelManager();
         this.social = new Social();
         this.karma = new KarmaManager();
         this.tracking = new Tracking();
         this._display = new Sprite();
         param1.addChild(this._display);
         this._display.addChild(DisplayUtils.createRectangle(0,0,700,545,Values.BG_COLOR));
         this._display.addChild(this.screens.display);
         this._display.addChild(this.popups.display);
         this._display.addChild(this.globalUI.display);
         if(Values.DEBUG_MODE)
         {
            _loc3_ = Utils.createDebugInfo();
            _loc3_.x = App.instance.stage.stageWidth - 50;
            _loc3_.y = 0;
            App.instance.display.addChild(_loc3_);
         }
         Key.init(param1);
         XML.ignoreWhitespace = false;
         this.screens.display.tabChildren = false;
         this.popups.display.tabChildren = false;
         this.globalUI.display.tabChildren = false;
         Log.log("[App] flashvars=" + com.adobe.serialization.json.JSON.encode(this.flashvars));
         new RegisterScreensProcess().execute();
         if(App.instance.flashvars["level"])
         {
            Values.SINGLE_LEVEL_MODE = true;
         }
         else
         {
            this.screens.goto(SPLASH_SCREEN);
         }
         var _loc2_:MacroProcess = new MacroProcess();
         if(!Values.SINGLE_LEVEL_MODE)
         {
            _loc2_.addProcess(new Callback(this.screens.goto,[SPLASH_SCREEN]));
         }
         _loc2_.addProcess(new RegisterResourcesProcess());
         if(Values.IS_LOCAL)
         {
            _loc2_.addProcess(new GetRemoteDataProcess());
         }
         else
         {
            _loc2_.addProcess(new GetLocalDataProcess());
         }
         _loc2_.addProcess(new ConfigureRemoteProcess());
         _loc2_.addProcess(new OverrideValuesProcess());
         _loc2_.addProcess(new InitDataProcess());
         if(Values.SINGLE_LEVEL_MODE)
         {
            App.instance.session = SessionUtils.createGodSession();
            _loc2_.addProcess(new Callback(this.globalUI.init));
            _loc2_.addProcess(new Callback(NavUtils.gotoGameScreen));
         }
         _loc2_.execute();
      }
      
      public function get display() : DisplayObjectContainer
      {
         return this._display;
      }
   }
}

