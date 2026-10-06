package ss.remote
{
   import com.adobe.serialization.json.JSON;
   import com.omniture.ActionSource;
   import org.fatlib.Log;
   import ss.Values;
   import ss.app.App;
   
   public class Omniture
   {
      
      private var _target:ActionSource;
      
      private var _gameTitle:String;
      
      private var _domain:String;
      
      public function Omniture()
      {
         super();
      }
      
      public function init() : void
      {
         var config:Object;
         var s:String = null;
         var account:String = "channel4dotcomtest";
         if(Values.IS_LIVE)
         {
            account = "channel4educationwidgets";
         }
         this._gameTitle = "sweatshop";
         this._domain = "";
         config = {
            "account":account,
            "trackingServer":"webstat.channel4.com",
            "trackingServerSecure":"webstat.channel4.com",
            "pageName":"",
            "pageURL":"",
            "charSet":"UTF-8",
            "currencyCode":"GBP",
            "trackClickMap":true,
            "movieID":"",
            "debugTracking":true,
            "trackLocal":true,
            "visitorNamespace":"channel4",
            "dc":"112"
         };
         Log.log("[Omniture] init: " + com.adobe.serialization.json.JSON.encode(config));
         this._target = new ActionSource();
         App.instance.stage.addChild(this._target);
         for(s in config)
         {
            try
            {
               this._target[s] = config[s];
            }
            catch(r:Error)
            {
               Log.error("Omniture error - problem with variable " + s);
            }
         }
      }
      
      public function gameStart() : void
      {
         if(!this._target || !Values.ENABLE_OMNITURE)
         {
            return;
         }
         Log.log("[Omniture] gameStart");
         this._target.linkTrackVars = "eVar1,eVar31,products,events";
         this._target.linkTrackEvents = "event10,event31";
         this._target.eVar1 = this._domain;
         this._target.eVar31 = this._gameTitle + ": Game Play";
         this._target.products = "Games;" + this._gameTitle;
         this._target.events = "event10,event31";
         this._target.trackLink(this._target.pageURL,"o"," " + this._gameTitle + " Game Interaction");
      }
      
      public function gameWon() : void
      {
         if(!this._target || !Values.ENABLE_OMNITURE)
         {
            return;
         }
         Log.log("[Omniture] gameWon");
         this._target.linkTrackVars = "eVar1,eVar31,products,events";
         this._target.linkTrackEvents = "event10,event31";
         this._target.eVar1 = this._domain;
         this._target.eVar31 = "" + this._gameTitle + ": Game Completed";
         this._target.products = "Games;" + this._gameTitle;
         this._target.events = "event10,event31";
         this._target.trackLink(this._target.pageURL,"o",this._gameTitle + " Game Interaction");
      }
      
      public function levelStart(param1:String) : void
      {
         if(!this._target || !Values.ENABLE_OMNITURE)
         {
            return;
         }
         Log.log("[Omniture] levelStart");
         this._target.linkTrackVars = "eVar1,eVar31,products,events";
         this._target.linkTrackEvents = "event10,event31";
         this._target.eVar31 = this._gameTitle + ": Game Level " + param1;
         this._target.products = "Games;" + this._gameTitle;
         this._target.events = "event10,event31";
         this._target.trackLink(this._target.pageURL,"o",this._gameTitle + " Game Interaction");
      }
      
      public function levelLost(param1:String, param2:int) : void
      {
         if(!this._target || !Values.ENABLE_OMNITURE)
         {
            return;
         }
         Log.log("[Omniture] levelLost " + param2);
         this._target.linkTrackVars = "eVar31,products,events";
         this._target.linkTrackEvents = "event6,event31";
         this._target.eVar31 = "" + this._gameTitle + ": Game Over";
         this._target.products = "Games;" + this._gameTitle + ";;;event6=" + param2;
         this._target.events = "event6,event31";
         this._target.trackLink(this._target.pageURL,"o",this._gameTitle + " Game Interaction");
      }
      
      public function levelWon(param1:String, param2:int) : void
      {
         if(!this._target || !Values.ENABLE_OMNITURE)
         {
            return;
         }
         Log.log("[Omniture] levelWon " + param2);
         this._target.linkTrackVars = "eVar31,products,events";
         this._target.linkTrackEvents = "event6,event13,event31";
         this._target.eVar31 = "" + this._gameTitle + ": Level Completed";
         this._target.products = "Games;" + this._gameTitle + ";;;event6=" + param2;
         this._target.events = "event6,event13,event31,";
         this._target.trackLink(this._target.pageURL,"o",this._gameTitle + " Game Interaction");
      }
   }
}

