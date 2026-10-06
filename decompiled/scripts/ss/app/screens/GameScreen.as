package ss.app.screens
{
   import flash.display.Sprite;
   import flash.utils.getTimer;
   import org.fatlib.Log;
   import org.fatlib.app.Screen;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.utils.DisplayUtils;
   import ss.Constants;
   import ss.Values;
   import ss.app.App;
   import ss.app.PopupManager;
   import ss.app.screens.game.LevelLostDialog;
   import ss.app.screens.game.LevelWonDialog;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.IMessageReceiver;
   import ss.game.factory.GameFactory;
   import ss.utils.MouseHandlers;
   import ss.utils.SessionUtils;
   import ss.utils.Utils;
   
   public class GameScreen extends Screen implements IMessageReceiver
   {
      
      private var _resultDialog:Screen;
      
      private var _gameStartTime:int;
      
      private var _cover:Sprite;
      
      private var _container:Sprite;
      
      public function GameScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         this._cover = DisplayUtils.createRectangle(0,0,Constants.SCREEN_W,Constants.SCREEN_H,Values.BG_COLOR);
         this._container = new Sprite();
         _display.addChild(DisplayUtils.createRectangle(0,0,Constants.SCREEN_W,Constants.SCREEN_H,10726315));
         _display.addChild(this._container);
         _display.addChild(this._cover);
         _delay.create(20,this.start);
      }
      
      private function start() : void
      {
         App.instance.tracking.levelStart(App.instance.session.currentLevelKey);
         this._gameStartTime = getTimer();
         Log.log("[GameScreen] handleAdded");
         App.instance.popups.addEventListener(PopupManager.OPENED,this.onPopupOpened);
         App.instance.popups.addEventListener(PopupManager.CLOSED,this.onPopupClosed);
         App.instance.globalUI.addEventListener("onAction",this.onGlobalUIAction);
         GameFactory.setup();
         this._container.addChild(Game.canvas.display);
         Game.messenger.register(this,Commands.QUIT_LEVEL,Commands.HARD_QUIT,Commands.HARD_RESTART,Messages.STATS_UPDATED,Messages.LEVEL_END);
         Game.engine.render(true);
         _delay.create(20,this.startGame);
      }
      
      private function startGame() : void
      {
         Utils.fadeFromBGColor(display,100);
         _display.removeChild(this._cover);
         Game.engine.start();
         Game.messenger.broadcast(Commands.TRIGGER_DIALOG_CHUNK,{"chunk":"onStart"});
      }
      
      override public function handleRemoved() : void
      {
         Log.log("[GameScreen] handleRemoved");
         App.instance.popups.removeEventListener(PopupManager.OPENED,this.onPopupOpened);
         App.instance.popups.removeEventListener(PopupManager.CLOSED,this.onPopupClosed);
         App.instance.globalUI.removeEventListener("onAction",this.onGlobalUIAction);
         Game.messenger.unregister(this);
         App.instance.audio.stopMusic();
         this._container.removeChild(Game.canvas.display);
         GameFactory.tearDown();
         if(this._resultDialog)
         {
            this._resultDialog.destroy();
         }
         MouseHandlers.flush();
      }
      
      public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Commands.QUIT_LEVEL:
               Game.engine.pause();
               _delay.create(100,this.quit);
               break;
            case Commands.HARD_QUIT:
               Game.engine.pause();
               _delay.create(100,this.hardQuit);
               break;
            case Commands.HARD_RESTART:
               Game.engine.pause();
               _delay.create(100,this.hardRestart);
               break;
            case Messages.STATS_UPDATED:
               App.instance.trophies.checkLevelTrophies(Game.stats);
               App.instance.trophies.checkGlobalTrophies();
               break;
            case Messages.LEVEL_END:
               App.instance.globalUI.configure("level_end");
         }
      }
      
      private function handleGlobalUIAction(param1:String) : void
      {
         switch(param1)
         {
            case "skip":
               Game.messenger.broadcast(Commands.SKIP_DIALOG);
               break;
            case "pause":
               Game.messenger.broadcast(Commands.USER_INVOKE_TOGGLE_PAUSE);
         }
      }
      
      private function hardRestart() : void
      {
         var _loc1_:int = Math.ceil((getTimer() - this._gameStartTime) / 1000);
         App.instance.tracking.levelRestarted(App.instance.session.currentLevelKey,_loc1_);
         App.instance.session.lastResult = Game.result;
         SessionUtils.saveProgress();
         gotoScreen(App.GAME_SCREEN);
      }
      
      private function hardQuit() : void
      {
         var _loc1_:int = Math.ceil((getTimer() - this._gameStartTime) / 1000);
         App.instance.tracking.levelQuit(App.instance.session.currentLevelKey,_loc1_);
         App.instance.session.lastResult = Game.result;
         SessionUtils.saveProgress();
         gotoScreen(App.SELECT_SCREEN);
      }
      
      private function quit() : void
      {
         App.instance.session.markRead(App.instance.session.currentLevelKey);
         App.instance.session.lastResult = Game.result;
         App.instance.session.lastLevelStats = Game.stats;
         SessionUtils.saveProgress();
         var _loc1_:int = Math.ceil((getTimer() - this._gameStartTime) / 1000);
         if(App.instance.session.lastResult.won)
         {
            App.instance.tracking.levelWon(App.instance.session.currentLevelKey,_loc1_,App.instance.session.lastResult.score);
            _delay.create(500,this.showResultDialog,[true]);
         }
         else
         {
            App.instance.tracking.levelLost(App.instance.session.currentLevelKey,_loc1_);
            _delay.create(500,this.showResultDialog,[false]);
         }
      }
      
      private function showResultDialog(param1:Boolean) : void
      {
         if(param1)
         {
            this._resultDialog = new LevelWonDialog();
         }
         else
         {
            this._resultDialog = new LevelLostDialog();
         }
         this._container.addChild(this._resultDialog.display);
      }
      
      private function onPopupOpened(param1:CustomEvent) : void
      {
         Game.messenger.broadcast(Commands.APP_INVOKE_PAUSE);
      }
      
      private function onPopupClosed(param1:CustomEvent) : void
      {
         Game.messenger.broadcast(Commands.APP_INVOKE_UNPAUSE);
      }
      
      private function onGlobalUIAction(param1:CustomEvent) : void
      {
         this.handleGlobalUIAction(param1.data.action);
      }
   }
}

