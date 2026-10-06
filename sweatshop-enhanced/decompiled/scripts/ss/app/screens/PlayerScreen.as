package ss.app.screens
{
   import com.adobe.serialization.json.JSON;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.fatlib.Log;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.utils.DisplayUtils;
   import org.fatlib.utils.Tween;
   import ss.Constants;
   import ss.app.App;
   import ss.app.KarmaMeter;
   import ss.data.KarmaRank;
   import ss.data.Trophy;
   import ss.remote.Social;
   import ss.utils.AudioUtils;
   import ss.utils.Utils;
   
   public class PlayerScreen extends BasePopup
   {
      
      public static var T_SCALE:Number = -1;
      
      private var _mc:MovieClip;
      
      private var _selectedTrophy:String;
      
      private var _prevMusic:String;
      
      private var _karmaRank:KarmaRank;
      
      private var _rollovers:Array;
      
      public function PlayerScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         this._mc = App.instance.resources.instantiateMovieClip("ui","PlayerScreenSymbol");
         display.addChild(this._mc);
         this.closePopup();
         this.configureTrophies();
         this.configureStats();
         if(_launchVars["view"] == "trophies")
         {
            this.showView("trophies");
         }
         else
         {
            this.showView("stats");
         }
         this._prevMusic = App.instance.audio.currentMusicTrack;
         App.instance.audio.playMusic("prelevel");
         App.instance.social.addEventListener(Event.COMPLETE,this.onRemoteComplete);
         Utils.fadeFromBGColor(display);
      }
      
      override public function handleRemoved() : void
      {
         var _loc1_:MovieClip = null;
         App.instance.social.removeEventListener(Event.COMPLETE,this.onRemoteComplete);
         if(this._rollovers)
         {
            for each(_loc1_ in this._rollovers)
            {
               _loc1_.removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
               _loc1_.removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
            }
         }
         if(this._prevMusic)
         {
            App.instance.audio.playMusic(this._prevMusic);
         }
      }
      
      private function configureStats() : void
      {
         var _loc1_:MovieClip = this._mc["stats_view"];
         _loc1_["username"].text = App.instance.session.username;
         _loc1_["level"].text = App.instance.session.getLevelsCompleted();
         var _loc2_:Object = App.instance.session.getMedalCounts();
         _loc1_["bronze"].text = _loc2_[Constants.BRONZE_MEDAL];
         _loc1_["silver"].text = _loc2_[Constants.SILVER_MEDAL];
         _loc1_["gold"].text = _loc2_[Constants.GOLD_MEDAL];
         _loc1_["hired"].text = App.instance.session.stats.unitsHired;
         _loc1_["injured"].text = App.instance.session.stats.workersInjured;
         _loc1_["killed"].text = App.instance.session.stats.workersKilled;
         _loc1_["refreshed"].text = App.instance.session.stats.tiredWorkersRefreshed;
         _loc1_["upgraded"].text = App.instance.session.stats.unitsUpgraded;
         _loc1_["features"].text = App.instance.session.stats.featuresDeployed;
         var _loc3_:int = App.instance.session.calculateKarma();
         this._karmaRank = App.instance.karma.getRank(_loc3_);
         KarmaMeter.configure(_loc1_["karma"],_loc3_);
         _loc1_["title"].text = this._karmaRank.title;
      }
      
      private function configureTrophies() : void
      {
         var _loc3_:String = null;
         var _loc4_:MovieClip = null;
         var _loc5_:Trophy = null;
         var _loc1_:MovieClip = this._mc["trophies_view"];
         var _loc2_:int = 1;
         while(_loc2_ <= 20)
         {
            _loc3_ = "t" + _loc2_;
            _loc4_ = _loc1_[_loc3_];
            _loc4_["hit"].alpha = 0;
            _loc4_.mouseChildren = false;
            if(App.instance.session.hasTrophy(_loc3_))
            {
               _loc5_ = App.instance.trophies.getTrophy(_loc3_);
               _loc4_.mouseEnabled = true;
               _loc4_.buttonMode = true;
               _loc4_.useHandCursor = true;
               _loc4_["label"].visible = true;
               _loc4_["label"].textColor = 15616069;
               _loc4_["label"].text = _loc5_.name;
               _loc4_["nuevo"].visible = App.instance.session.isNewTrophy(_loc3_);
               _loc4_["icon"].gotoAndStop(_loc3_);
               DisplayUtils.recursiveStop(_loc4_["icon"]);
               this.addRollover(_loc4_);
            }
            else
            {
               _loc4_.mouseEnabled = false;
               _loc4_["label"].visible = true;
               _loc4_["label"].textColor = 6710886;
               _loc4_["label"].text = App.instance.text.getText("stats.trophy.secret");
               _loc4_["icon"].gotoAndStop("locked");
               _loc4_["nuevo"].visible = false;
            }
            _loc2_++;
         }
         App.instance.session.clearNewTrophies();
      }
      
      override protected function handleClicked(param1:String) : void
      {
         switch(param1)
         {
            case "stats":
            case "trophies":
               this.closePopup();
               AudioUtils.uiClick();
               this.showView(param1);
               break;
            case "close":
               AudioUtils.uiClose();
               this.closePopup();
               break;
            case "facebook_trophy":
            case "twitter_trophy":
               AudioUtils.uiClick();
               this.shareTrophy(param1);
               break;
            case "facebook_karma":
            case "twitter_karma":
               AudioUtils.uiClick();
               this.shareKarma(param1);
         }
         if(param1.substr(0,1) == "t" && this.isDigit(param1.substr(1,1)))
         {
            this.openPopup(param1);
         }
      }
      
      private function shareKarma(param1:String) : void
      {
         var _loc2_:String = Social.TWITTER;
         if(param1 == "facebook_karma")
         {
            _loc2_ = Social.FACEBOOK;
         }
         App.instance.social.share(this._karmaRank.shareable,_loc2_);
      }
      
      private function shareTrophy(param1:String) : void
      {
         var _loc2_:String = Social.TWITTER;
         if(param1 == "facebook_trophy")
         {
            _loc2_ = Social.FACEBOOK;
         }
         var _loc3_:Trophy = App.instance.trophies.getTrophy(this._selectedTrophy);
         App.instance.social.share(_loc3_.shareable,_loc2_);
      }
      
      private function showView(param1:String) : void
      {
         this._mc["trophies"].mouseEnabled = this._mc["trophies"].tabEnabled = this._mc["stats_view"].visible = param1 == "stats";
         this._mc["stats"].mouseEnabled = this._mc["stats"].tabEnabled = this._mc["trophies_view"].visible = param1 == "trophies";
      }
      
      private function openPopup(param1:String) : void
      {
         AudioUtils.uiOpen();
         var _loc2_:MovieClip = this._mc["popup"];
         _loc2_.visible = true;
         Utils.tweenInPanel(_loc2_);
         this._mc["black"].visible = true;
         Utils.tweenIn(this._mc["black"],200);
         var _loc3_:Trophy = App.instance.trophies.getTrophy(param1);
         _loc2_["title"].text = _loc3_.name;
         _loc2_["icon"].gotoAndStop(param1);
         DisplayUtils.recursiveStop(_loc2_["icon"]);
         _loc2_["desc"].text = _loc3_.description;
         _loc2_["copy"].text = _loc3_.vanillaCopy;
         _loc2_["karma"].htmlText = _loc3_.karmaHTMLText;
         this._selectedTrophy = param1;
      }
      
      private function closePopup() : void
      {
         this._mc["popup"].visible = false;
         this._mc["black"].visible = false;
      }
      
      private function isDigit(param1:String) : Boolean
      {
         return param1.charCodeAt(0) >= "0".charCodeAt(0) && param1.charCodeAt(0) <= "9".charCodeAt(0);
      }
      
      private function onRemoteComplete(param1:CustomEvent) : void
      {
         Log.log("[PlayerScreen] remote call complete, result=" + com.adobe.serialization.json.JSON.encode(param1.data));
      }
      
      private function addRollover(param1:MovieClip) : void
      {
         param1.addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         param1.addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         if(!this._rollovers)
         {
            this._rollovers = [];
         }
         this._rollovers.push(param1);
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         if(T_SCALE == -1)
         {
            return;
         }
         var _loc2_:Number = T_SCALE;
         Tween.add(param1.target["icon"],50,{
            "scaleX":_loc2_,
            "scaleY":_loc2_
         });
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         if(T_SCALE == -1)
         {
            T_SCALE = param1.target["icon"].scaleX;
         }
         var _loc2_:Number = 1.1 * T_SCALE;
         Tween.add(param1.target["icon"],80,{
            "scaleX":_loc2_,
            "scaleY":_loc2_
         });
      }
   }
}

