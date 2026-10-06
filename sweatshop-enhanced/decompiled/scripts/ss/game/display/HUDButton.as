package ss.game.display
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import org.fatlib.interfaces.IDestroyable;
   import ss.game.Game;
   import ss.game.core.Engine;
   import ss.game.core.IMessageReceiver;
   
   public class HUDButton extends EventDispatcher implements IDestroyable, IMessageReceiver
   {
      
      public var name:String;
      
      protected var _mc:MovieClip;
      
      protected var _isOver:Boolean = false;
      
      protected var _hilited:Boolean;
      
      private var _isActive:Boolean = true;
      
      private var _unhiliteOnClick:Boolean;
      
      public function HUDButton(param1:MovieClip)
      {
         super();
         this._mc = param1;
         this._mc["hit"].alpha = 0;
         this._mc["hit"].buttonMode = true;
         this._mc["hit"].addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         this._mc["hit"].addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this._mc["hit"].addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         this.hilite(false);
         Game.messenger.register(this,Engine.ENGINE_PAUSED,Engine.ENGINE_UNPAUSED);
      }
      
      public function hide() : void
      {
         this._mc.visible = false;
      }
      
      public function show() : void
      {
         this._mc.visible = true;
      }
      
      public function destroy() : void
      {
         this._mc["hit"].removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         this._mc["hit"].removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this._mc["hit"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
      }
      
      public function receiveMessage(param1:String, param2:Object) : void
      {
         if(param1 == Engine.ENGINE_PAUSED && this._hilited)
         {
            this._mc["hilite"].stop();
         }
         if(param1 == Engine.ENGINE_UNPAUSED && this._hilited)
         {
            this._mc["hilite"].play();
         }
      }
      
      public function hilite(param1:Boolean, param2:String = null, param3:Boolean = false) : Boolean
      {
         if(param2 != null && this.name != param2)
         {
            return false;
         }
         this._unhiliteOnClick = param3;
         if(param1)
         {
            this._hilited = true;
            this._mc["hilite"].visible = true;
            this._mc["hilite"].gotoAndPlay("start");
         }
         else
         {
            this._hilited = false;
            this._mc["hilite"].stop();
            this._mc["hilite"].visible = false;
         }
         return true;
      }
      
      public function get isActive() : Boolean
      {
         return this._isActive;
      }
      
      public function set isActive(param1:Boolean) : void
      {
         this._isActive = param1;
         this._mc.mouseChildren = this._mc.mouseEnabled = this._isActive;
      }
      
      public function refresh() : void
      {
      }
      
      protected function handleMouseDown() : void
      {
      }
      
      protected function handleMouseOver() : void
      {
      }
      
      protected function handleMouseOut() : void
      {
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         this._isOver = false;
         this.handleMouseOut();
         dispatchEvent(new Event(PatchEvent.ROLL_OUT));
         this.refresh();
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         this._isOver = true;
         this.handleMouseOver();
         dispatchEvent(new Event(PatchEvent.ROLL_OVER));
         this.refresh();
      }
      
      private function onDown(param1:MouseEvent) : void
      {
         if(this._unhiliteOnClick)
         {
            this.hilite(false);
         }
         this.handleMouseDown();
         dispatchEvent(new Event(PatchEvent.CLICK));
         this.refresh();
      }
   }
}

