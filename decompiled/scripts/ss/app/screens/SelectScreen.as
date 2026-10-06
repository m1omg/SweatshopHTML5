package ss.app.screens
{
   import flash.display.MovieClip;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.fatlib.Log;
   import org.fatlib.app.Screen;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.utils.DestroyList;
   import ss.app.App;
   import ss.app.GlobalUI;
   import ss.app.NavUtils;
   import ss.app.PopupManager;
   import ss.app.screens.select.SelectPopup;
   import ss.app.screens.select.SpinnerWheel;
   import ss.app.screens.select.Weather;
   import ss.app.screens.select.WorldDialog;
   import ss.utils.Utils;
   
   public class SelectScreen extends Screen
   {
      
      private var _popup:SelectPopup;
      
      private var _dialog:WorldDialog;
      
      private var _mc:MovieClip;
      
      private var _selectedLevel:String;
      
      private var _selectedWorld:int;
      
      private var _lastDir:int;
      
      private var _wheel:SpinnerWheel;
      
      private var _destroyList:DestroyList;
      
      private var _highestWorld:int = 1;
      
      private var _weather:Weather;
      
      public function SelectScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         this._destroyList = new DestroyList();
         this._highestWorld = App.instance.session.getHighestWorldUnlocked();
         this._selectedWorld = App.instance.session.currentWorld;
         Log.log("[SelectScreen] highestWorld=" + this._highestWorld + " , selectedWorld=" + this._selectedWorld);
         this._mc = App.instance.resources.instantiateMovieClip("ui","LevelSelectSymbol");
         display.addChild(this._mc);
         this._dialog = new WorldDialog(this._mc["dialog"]);
         this._destroyList.add(this._dialog);
         this._dialog.addEventListener(WorldDialog.LEVEL_SELECTED,this.onLevelSelected);
         this._dialog.addEventListener(WorldDialog.LEVEL_DESELECTED,this.onLevelDeselected);
         App.instance.popups.addEventListener(PopupManager.OPENED,this.onGlobalPopupOpened);
         App.instance.popups.addEventListener(PopupManager.CLOSED,this.onGlobalPopupClosed);
         this._dialog.hide(false);
         this._popup = new SelectPopup(this._mc["popup"]);
         this._destroyList.add(this._popup);
         this._popup.hide(false);
         this._popup.addEventListener(SelectPopup.PLAY,this.onPlaySelected);
         this._popup.addEventListener(SelectPopup.CLOSE,this.onLevelDeselected);
         this._mc["left"].addEventListener(MouseEvent.CLICK,this.onClickLeft);
         this._mc["right"].addEventListener(MouseEvent.CLICK,this.onClickRight);
         this._wheel = new SpinnerWheel(this._mc["wheel"]);
         this._destroyList.add(this._wheel);
         this._weather = new Weather(this._mc["weather"]);
         this._destroyList.add(this._weather);
         this.deactivate();
         this.refreshArrows(true);
         if(App.instance.session.beforeNextSelectScene)
         {
            App.instance.session.beforeNextSelectScene = null;
            this._selectedWorld = this._highestWorld;
            if(this._highestWorld > 1)
            {
               this.revealWorldSetup();
            }
            else
            {
               this.normalSetup();
            }
         }
         else
         {
            this.normalSetup();
         }
         App.instance.globalUI.addEventListener(GlobalUI.ACTION,this.onGlobalUIAction);
         App.instance.audio.playMusic("select");
         Utils.fadeFromBGColor(display);
      }
      
      override public function handleRemoved() : void
      {
         this._mc["left"].removeEventListener(MouseEvent.CLICK,this.onClickLeft);
         this._mc["right"].removeEventListener(MouseEvent.CLICK,this.onClickRight);
         this._dialog.removeEventListener(WorldDialog.LEVEL_SELECTED,this.onLevelSelected);
         this._dialog.removeEventListener(WorldDialog.LEVEL_DESELECTED,this.onLevelDeselected);
         this._popup.removeEventListener(SelectPopup.PLAY,this.onPlaySelected);
         this._popup.removeEventListener(SelectPopup.CLOSE,this.onLevelDeselected);
         App.instance.globalUI.removeEventListener(GlobalUI.ACTION,this.onGlobalUIAction);
         App.instance.popups.removeEventListener(PopupManager.OPENED,this.onGlobalPopupOpened);
         App.instance.popups.removeEventListener(PopupManager.CLOSED,this.onGlobalPopupClosed);
         App.instance.audio.stopMusic();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this._destroyList.destroy();
      }
      
      private function playSelectedLevel() : void
      {
         if(!this._selectedLevel)
         {
            return;
         }
         App.instance.session.currentLevelKey = this._selectedLevel;
         App.instance.session.currentWorld = this._selectedWorld;
         NavUtils.gotoGameScreen();
      }
      
      private function scroll(param1:int) : void
      {
         this.refreshArrows(true);
         this.deselect();
         this.invokeTransition();
         if(this._selectedWorld == 3)
         {
            this._weather.stop();
         }
         this._selectedWorld += param1;
      }
      
      private function deselect() : void
      {
         this._selectedLevel = null;
         this._popup.hide();
         this._dialog.deselectAll();
      }
      
      private function activate() : void
      {
         this._mc.mouseChildren = this._mc.mouseEnabled = true;
      }
      
      private function deactivate() : void
      {
         this._mc.mouseChildren = this._mc.mouseEnabled = false;
      }
      
      private function refreshArrows(param1:Boolean = false) : void
      {
         this._mc["left"].visible = this._selectedWorld > 1 && !param1;
         this._mc["right"].visible = this._selectedWorld < 3 && !param1;
      }
      
      private function normalSetup() : void
      {
         var _loc1_:int = 1;
         while(_loc1_ <= 3)
         {
            if(this._highestWorld >= _loc1_)
            {
               this._wheel.unlockWorld(_loc1_);
            }
            else
            {
               this._wheel.lockWorld(_loc1_);
            }
            _loc1_++;
         }
         this._wheel.rotateTo(this._selectedWorld,false);
         this._dialog.show(this._selectedWorld,false);
         this.refreshArrows();
         this.activate();
         if(this._selectedWorld == 3)
         {
            this._weather.start();
         }
      }
      
      private function revealWorldSetup() : void
      {
         var _loc1_:int = 1;
         while(_loc1_ <= 3)
         {
            if(this._highestWorld > _loc1_)
            {
               this._wheel.unlockWorld(_loc1_);
            }
            else
            {
               this._wheel.lockWorld(_loc1_);
            }
            _loc1_++;
         }
         this._wheel.rotateTo(this._highestWorld - 1,false);
         _delay.create(2500,this.rotateToNextWorld);
         this._dialog.show(this._highestWorld - 1,false);
         _delay.create(2000,this._dialog.hide,[true]);
      }
      
      private function rotateToNextWorld() : void
      {
         this._wheel.rotateTo(this._highestWorld,true,this.pauseBeforeUnlockWorld);
      }
      
      private function pauseBeforeUnlockWorld() : void
      {
         _delay.create(500,this.unlockNextWorld);
      }
      
      private function unlockNextWorld() : void
      {
         this._wheel.unlockWorld(this._selectedWorld,true,this.worldUnlockAnimDone);
         App.instance.audio.play("good");
      }
      
      private function worldUnlockAnimDone() : void
      {
         _delay.create(500,this.revealComplete);
      }
      
      private function revealComplete() : void
      {
         this._dialog.show(this._selectedWorld);
         this.refreshArrows();
         this.activate();
         if(this._selectedWorld == 3)
         {
            this._weather.start();
         }
      }
      
      public function invokeTransition() : void
      {
         this.deactivate();
         this._dialog.hide(true,this.dialogHidden);
      }
      
      private function dialogHidden() : void
      {
         _delay.create(300,this.doRotation);
      }
      
      private function doRotation() : void
      {
         this._wheel.rotateTo(this._selectedWorld,true,this.rotationDone);
         App.instance.stage.quality = StageQuality.MEDIUM;
      }
      
      private function rotationDone() : void
      {
         App.instance.stage.quality = StageQuality.HIGH;
         _delay.create(300,this.showDialog);
         if(this._mc["wheel"].rotation < 0)
         {
            this._mc["wheel"].rotation += 360;
         }
      }
      
      private function showDialog() : void
      {
         this._dialog.show(this._selectedWorld,true,this.transitionDone);
      }
      
      private function transitionDone() : void
      {
         this.activate();
         this.refreshArrows();
         if(this._selectedWorld == 3)
         {
            this._weather.start();
         }
      }
      
      private function onClickRight(param1:MouseEvent) : void
      {
         this.scroll(1);
      }
      
      private function onClickLeft(param1:MouseEvent) : void
      {
         this.scroll(-1);
      }
      
      private function onPlaySelected(param1:Event) : void
      {
         this.playSelectedLevel();
      }
      
      private function onLevelSelected(param1:CustomEvent) : void
      {
         if(this._selectedLevel == param1.data.level)
         {
            this.playSelectedLevel();
         }
         else
         {
            this._selectedLevel = param1.data.level;
            this._popup.show(this._selectedLevel);
            this._dialog.select(this._selectedLevel);
         }
      }
      
      private function onLevelDeselected(param1:CustomEvent) : void
      {
         this.deselect();
      }
      
      private function onGlobalUIAction(param1:CustomEvent) : void
      {
         if(param1.data.action == "menu")
         {
            gotoScreen(App.TITLE_SCREEN);
         }
      }
      
      private function onGlobalPopupClosed(param1:Event) : void
      {
         if(this._weather)
         {
            this._weather.unpause();
         }
      }
      
      private function onGlobalPopupOpened(param1:Event) : void
      {
         if(this._weather)
         {
            this._weather.pause();
         }
      }
   }
}

