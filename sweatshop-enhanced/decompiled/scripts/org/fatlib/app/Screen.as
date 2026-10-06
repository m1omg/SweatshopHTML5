package org.fatlib.app
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.interfaces.IDisplayable;
   import org.fatlib.utils.Delay;
   import org.fatlib.utils.DisplayUtils;
   
   public class Screen implements IDisplayable, IDestroyable
   {
      
      protected var _screenName:String;
      
      protected var _launchVars:Object = {};
      
      protected var _display:DisplayObjectContainer;
      
      protected var _delay:Delay;
      
      private var _manager:ScreenManager;
      
      public function Screen()
      {
         super();
         this._delay = new Delay();
         this._display = new Sprite();
         this._display.addEventListener(MouseEvent.CLICK,this.onClick);
         this._display.addEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      public function handleAdded() : void
      {
      }
      
      public function handleRemoved() : void
      {
      }
      
      public function get screenName() : String
      {
         return this._screenName;
      }
      
      public function set screenName(param1:String) : void
      {
         this._screenName = param1;
      }
      
      public function set launchVars(param1:Object) : void
      {
         this._launchVars = param1;
      }
      
      public function get display() : DisplayObjectContainer
      {
         return this._display;
      }
      
      final public function set manager(param1:ScreenManager) : void
      {
         this._manager = param1;
      }
      
      public function get manager() : ScreenManager
      {
         return this._manager;
      }
      
      public function set delay(param1:Delay) : void
      {
         this._delay = param1;
      }
      
      public function destroy() : void
      {
         this._display.removeEventListener(MouseEvent.CLICK,this.onClick);
         this._display.removeEventListener(Event.ENTER_FRAME,this.onFrame);
         this._delay.destroy();
         DisplayUtils.recursiveStop(this._display);
      }
      
      protected function handleClicked(param1:String) : void
      {
      }
      
      protected function handleFrame() : void
      {
      }
      
      protected function gotoScreen(param1:String, param2:Object = null, param3:String = null) : void
      {
         this._manager.goto(param1,param2,param3);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         this.handleClicked(param1.target.name);
      }
      
      private function onFrame(param1:Event) : void
      {
         this.handleFrame();
      }
   }
}

