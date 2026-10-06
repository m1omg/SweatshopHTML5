package ss.app
{
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import org.fatlib.Log;
   import org.fatlib.app.ScreenManager;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.interfaces.IDisplayable;
   import org.fatlib.utils.ArrayUtils;
   import org.fatlib.utils.Delay;
   import ss.utils.AudioManager;
   import ss.utils.AudioUtils;
   import ss.utils.Utils;
   
   public class GlobalUI extends EventDispatcher implements IDestroyable, IDisplayable
   {
      
      public static var ACTION:String = "onAction";
      
      public static var BACK:String = "onBack";
      
      private var UI_JSON:Class = GlobalUI_UI_JSON;
      
      private var _mc:MovieClip;
      
      private var _container:MovieClip;
      
      private var _inited:Boolean = false;
      
      private var _buttonData:Object;
      
      private var _delay:Delay;
      
      private var _trophyPopup:TrophyPopup;
      
      private var _newTrophyAlert:Boolean;
      
      private var _playerHiVisible:Boolean;
      
      private var _confirm:ConfirmPopup;
      
      private var _tooltip:MovieClip;
      
      private var _currentTooltipName:String;
      
      public function GlobalUI()
      {
         super();
         App.instance.screens.addEventListener(ScreenManager.SCREEN_INITED,this.onScreenChanged);
         App.instance.popups.addEventListener(ScreenManager.SCREEN_INITED,this.onScreenChanged);
         App.instance.popups.addEventListener(PopupManager.OPENED,this.onPopupOpened);
         App.instance.popups.addEventListener(PopupManager.CLOSED,this.onPopupClosed);
         this._container = new MovieClip();
         this._buttonData = com.adobe.serialization.json.JSON.decode(new this.UI_JSON());
      }
      
      public function init() : void
      {
         this._mc = App.instance.resources.instantiateMovieClip("ui","GlobalUISymbol");
         this._mc.x = 0;
         this._mc.y = 500;
         this._container.addChild(this._mc);
         this._container.addEventListener(MouseEvent.CLICK,this.onClick);
         this._container.addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         this._container.addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this.updateSoundButton();
         App.instance.audio.addEventListener(AudioManager.MUTE_TOGGLED,this.onMuteToggled);
         this._inited = true;
         this._mc["player_hi"].mouseEnabled = this._mc["player_hi"].mouseChildren = false;
         this._trophyPopup = new TrophyPopup(this._mc["trophy"]);
         this._confirm = new ConfirmPopup(this._mc["confirm"],this._mc["menu"],100);
         this._confirm.addEventListener(ConfirmPopup.CLICK,this.onConfirmComplete);
         this._tooltip = this._mc["tooltip"];
         this._tooltip.stop();
         this._tooltip.visible = false;
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         var _loc3_:String = "ui.tooltip." + _loc2_.name;
         if(App.instance.text.hasText(_loc3_))
         {
            _loc4_ = App.instance.text.getText(_loc3_);
            this._currentTooltipName = _loc2_.name;
            this._tooltip["label"].text = _loc4_;
            this._tooltip.visible = true;
            _loc5_ = _loc2_.getRect(this._mc).left;
            if(_loc2_.x < 350)
            {
               this._tooltip.gotoAndStop("right");
               this._tooltip.x = _loc5_ + 50;
            }
            else
            {
               this._tooltip.gotoAndStop("left");
               this._tooltip.x = _loc5_ - 5;
            }
            Utils.tweenInTooltip(this._tooltip);
         }
         else
         {
            this._currentTooltipName = null;
            this._tooltip.visible = false;
         }
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(_loc2_.name == this._currentTooltipName)
         {
            this._tooltip.visible = false;
            this._currentTooltipName = null;
         }
      }
      
      public function get display() : DisplayObjectContainer
      {
         return this._container as DisplayObjectContainer;
      }
      
      public function get inited() : Boolean
      {
         return this._inited;
      }
      
      public function destroy() : void
      {
      }
      
      public function openTrophyPopup(param1:String) : void
      {
         this._newTrophyAlert = true;
         this._playerHiVisible = true;
         this._mc["player_hi"].visible = true;
         this._trophyPopup.open(param1);
      }
      
      public function showSkip() : void
      {
         this._mc["skip"].visible = true;
      }
      
      public function hideSkip() : void
      {
         this._mc["skip"].visible = false;
      }
      
      private function updateSoundButton() : void
      {
         this._mc["sound_on"].visible = App.instance.audio.muted;
         this._mc["sound_off"].visible = !App.instance.audio.muted;
      }
      
      public function configure(param1:String) : void
      {
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         if(!this._inited)
         {
            return;
         }
         var _loc2_:Array = ["pause","skip","player","player_hi","help","back","menu"];
         Log.log("[GlobalUI] configure " + param1);
         var _loc3_:Array = this._buttonData[param1];
         if(!_loc3_)
         {
            return;
         }
         for each(_loc4_ in _loc2_)
         {
            _loc5_ = ArrayUtils.contains(_loc3_,_loc4_);
            if(_loc4_ == "player_hi")
            {
               _loc5_ &&= this._playerHiVisible;
            }
            this._mc.getChildByName(_loc4_).visible = _loc5_;
         }
      }
      
      public function openPlayerPopup() : void
      {
         if(this._mc["player"].visible == false)
         {
            return;
         }
         var _loc1_:Object = {};
         if(this._newTrophyAlert)
         {
            _loc1_["view"] = "trophies";
         }
         this._playerHiVisible = false;
         this._mc["player_hi"].visible = false;
         this._newTrophyAlert = false;
         App.instance.popups.open(App.PLAYER_SCREEN,_loc1_);
      }
      
      private function handleClicked(param1:String) : void
      {
         switch(param1)
         {
            case "menu":
               AudioUtils.uiConfirm();
               this._confirm.show();
               break;
            case "pause":
            case "skip":
            case "back":
               AudioUtils.uiClose();
               dispatchEvent(new CustomEvent(ACTION,{"action":param1}));
               break;
            case "help":
               AudioUtils.uiNav();
               App.instance.popups.open(App.HELP_SCREEN);
               break;
            case "player":
               AudioUtils.uiNav();
               this.openPlayerPopup();
               break;
            case "sound_on":
            case "sound_off":
               App.instance.audio.toggleMute();
               if(App.instance.audio.muted)
               {
                  App.instance.tracking.soundOff();
               }
               else
               {
                  App.instance.tracking.soundOn();
               }
         }
         if(param1 == "sound_off")
         {
            AudioUtils.uiClick();
         }
      }
      
      private function onConfirmComplete(param1:CustomEvent) : void
      {
         if(param1.data["yes"])
         {
            dispatchEvent(new CustomEvent(ACTION,{"action":"menu"}));
         }
         this._confirm.hide();
      }
      
      private function onScreenChanged(param1:CustomEvent) : void
      {
         if(!this.inited)
         {
            if(!App.instance.resources.hasLoaded)
            {
               return;
            }
            this.init();
         }
         var _loc2_:String = param1.data["name"];
         this.configure(_loc2_);
      }
      
      private function onPopupOpened(param1:CustomEvent) : void
      {
         this._tooltip.visible = false;
      }
      
      private function onPopupClosed(param1:CustomEvent) : void
      {
         var _loc2_:String = param1.data["base"];
         this.configure(_loc2_);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         this.handleClicked(param1.target.name);
      }
      
      private function onMuteToggled(param1:Event) : void
      {
         this.updateSoundButton();
      }
   }
}

