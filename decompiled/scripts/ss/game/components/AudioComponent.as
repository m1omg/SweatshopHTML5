package ss.game.components
{
   import ss.app.App;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.core.Component;
   
   public class AudioComponent extends Component
   {
      
      private var _index:Object;
      
      public function AudioComponent()
      {
         super();
      }
      
      override public function prepare() : void
      {
         var _loc1_:String = null;
         this._index = {};
         Game.messenger.register(this,Commands.PLAY_MUSIC,Commands.STOP_MUSIC);
         for each(_loc1_ in App.instance.audio.triggers)
         {
            Game.messenger.register(this,_loc1_);
         }
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Commands.PLAY_MUSIC:
               App.instance.audio.playMusic(param2.track);
               break;
            case Commands.STOP_MUSIC:
               App.instance.audio.stopMusic();
               break;
            default:
               App.instance.audio.trigger(param1,param2);
         }
      }
   }
}

