package ss.game.components.ui
{
   import ss.KeyCodes;
   import ss.app.App;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   
   public class PauseController extends Component
   {
      
      private var _userPaused:Boolean = false;
      
      private var _storyPaused:Boolean = false;
      
      private var _appPaused:Boolean = false;
      
      private var _levelEnded:Boolean;
      
      public function PauseController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Commands.USER_INVOKE_TOGGLE_PAUSE,Commands.USER_INVOKE_PAUSE,Commands.USER_INVOKE_UNPAUSE,Commands.STORY_INVOKE_PAUSE,Commands.STORY_INVOKE_UNPAUSE,Commands.APP_INVOKE_PAUSE,Commands.APP_INVOKE_UNPAUSE,Messages.PRESS_KEY,Messages.APP_LOST_FOCUS,Messages.LEVEL_END);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Commands.USER_INVOKE_TOGGLE_PAUSE:
               this.userTogglePause();
               break;
            case Commands.USER_INVOKE_PAUSE:
               this.userPause();
               break;
            case Messages.APP_LOST_FOCUS:
               if(!this._levelEnded)
               {
                  this.userPause();
               }
               break;
            case Messages.LEVEL_END:
               this._levelEnded = true;
               break;
            case Commands.USER_INVOKE_UNPAUSE:
               this.userUnpause();
               break;
            case Commands.STORY_INVOKE_PAUSE:
               this.storyPause();
               break;
            case Commands.STORY_INVOKE_UNPAUSE:
               this.storyUnpause();
               break;
            case Commands.APP_INVOKE_PAUSE:
               this.appPause();
               break;
            case Commands.APP_INVOKE_UNPAUSE:
               this.appUnpause();
               break;
            case Messages.PRESS_KEY:
               if(param2.keyCode == KeyCodes.P)
               {
                  this.userTogglePause();
               }
         }
      }
      
      private function userTogglePause() : void
      {
         if(this._userPaused)
         {
            this.userUnpause();
         }
         else
         {
            this.userPause();
         }
      }
      
      private function appPause() : void
      {
         this._appPaused = true;
         if(!this._storyPaused && !this._userPaused)
         {
            Game.engine.pause();
         }
      }
      
      private function appUnpause() : void
      {
         this._appPaused = false;
         if(this._userPaused)
         {
            App.instance.audio.muteMusic();
         }
         if(!this._storyPaused && !this._userPaused)
         {
            Game.engine.unpause();
         }
      }
      
      private function userPause() : void
      {
         if(this._userPaused || this._appPaused)
         {
            return;
         }
         this._userPaused = true;
         if(!this._storyPaused)
         {
            Game.engine.pause();
         }
         App.instance.audio.muteMusic(true);
         Game.messenger.broadcast(Commands.SHOW_PAUSE_MENU);
         Game.messenger.broadcast(Messages.USER_PAUSED);
      }
      
      private function userUnpause() : void
      {
         if(this._appPaused)
         {
            return;
         }
         this._userPaused = false;
         if(!this._storyPaused)
         {
            Game.engine.unpause();
         }
         App.instance.audio.muteMusic(false);
         Game.messenger.broadcast(Commands.HIDE_PAUSE_MENU);
         Game.messenger.broadcast(Messages.USER_UNPAUSED);
      }
      
      private function storyPause() : void
      {
         if(this._userPaused || this._appPaused)
         {
            return;
         }
         this._storyPaused = true;
         Game.engine.pause();
      }
      
      private function storyUnpause() : void
      {
         if(this._userPaused || this._appPaused)
         {
            return;
         }
         this._storyPaused = false;
         Game.engine.unpause();
      }
   }
}

