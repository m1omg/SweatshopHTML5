package ss.game.components.ui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.fatlib.utils.DisplayUtils;
   import ss.Constants;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Renderer;
   
   public class InputHandler extends Renderer
   {
      
      public function InputHandler()
      {
         super();
      }
      
      override public function prepare() : void
      {
         var _loc1_:Sprite = null;
         _loc1_ = DisplayUtils.createRectangle(0,0,Constants.SCREEN_W,Constants.SCREEN_H,16777215);
         _loc1_.alpha = 0;
         _loc1_.name = "bg";
         addElement(_loc1_).depth = DepthManager.getDepth(DepthManager.MINIMUM);
         App.instance.stage.focus = Game.canvas.display.stage;
         Game.canvas.display.addEventListener(MouseEvent.CLICK,this.onMouseDown);
         Game.canvas.display.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         App.instance.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         App.instance.stage.addEventListener(Event.DEACTIVATE,this.onFocusLost);
      }
      
      override public function destroy() : void
      {
         Game.canvas.display.removeEventListener(MouseEvent.CLICK,this.onMouseDown);
         Game.canvas.display.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         App.instance.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         App.instance.stage.removeEventListener(Event.DEACTIVATE,this.onFocusLost);
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         if(!Game.engine.paused)
         {
            Game.messenger.broadcast(Messages.MOUSE_UP,this.createBody(param1));
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(!Game.engine.paused)
         {
            Game.messenger.broadcast(Messages.MOUSE_DOWN,this.createBody(param1));
         }
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         Game.messenger.broadcast(Messages.PRESS_KEY,{
            "charCode":param1.charCode,
            "keyCode":param1.keyCode
         });
      }
      
      private function onFocusLost(param1:Event) : void
      {
         Game.messenger.broadcast(Messages.APP_LOST_FOCUS);
      }
      
      private function createBody(param1:MouseEvent) : Object
      {
         var _loc2_:Point = new Point(param1.stageX,param1.stageY);
         var _loc3_:Point = Game.canvas.screenToTile(_loc2_);
         return {
            "target":param1.target.name,
            "point":Game.canvas.mousePosition,
            "tile":Game.canvas.mouseTile
         };
      }
   }
}

