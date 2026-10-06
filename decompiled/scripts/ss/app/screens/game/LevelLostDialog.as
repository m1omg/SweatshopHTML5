package ss.app.screens.game
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.fatlib.app.Screen;
   import ss.app.App;
   import ss.app.NavUtils;
   import ss.utils.Utils;
   
   public class LevelLostDialog extends Screen
   {
      
      private var _mc:MovieClip;
      
      public function LevelLostDialog()
      {
         super();
         this._mc = App.instance.resources.instantiateMovieClip("ui","LosePopupSymbol");
         Utils.tweenInPanel(this._mc,true);
         this._mc.addEventListener(MouseEvent.CLICK,this.onClick);
         App.instance.audio.play("boo");
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         switch(param1.target.name)
         {
            case "retry":
               NavUtils.gotoGameScreen(false);
               break;
            case "quit":
               NavUtils.gotoSelectScreen();
         }
      }
      
      override public function get display() : DisplayObjectContainer
      {
         return this._mc;
      }
      
      override public function destroy() : void
      {
         this._mc.removeEventListener(MouseEvent.CLICK,this.onClick);
      }
   }
}

