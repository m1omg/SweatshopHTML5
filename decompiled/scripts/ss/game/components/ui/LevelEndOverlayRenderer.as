package ss.game.components.ui
{
   import flash.display.MovieClip;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Renderer;
   
   public class LevelEndOverlayRenderer extends Renderer
   {
      
      public function LevelEndOverlayRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Messages.LEVEL_END);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         var _loc3_:String = "WinOverlaySymbol";
         if(param2["won"] == false)
         {
            _loc3_ = "LoseOverlaySymbol";
         }
         var _loc4_:MovieClip = App.instance.resources.instantiateMovieClip("hud",_loc3_);
         addElement(_loc4_,true).depth = DepthManager.getDepth(DepthManager.WIN_LOSE_OVERLAY);
      }
   }
}

