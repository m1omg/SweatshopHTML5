package org.fatlib.app
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import org.fatlib.Log;
   import org.fatlib.display.Text;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.interfaces.IDisplayable;
   
   public class ScreenManager extends EventDispatcher implements IDisplayable, IDestroyable
   {
      
      public static const SCREEN_INITED:String = "onScreenInited";
      
      public static const SCREEN_ADDED:String = "onScreenAdded";
      
      protected var _currentScreen:Screen;
      
      protected var _classReferences:Object;
      
      protected var _display:DisplayObjectContainer;
      
      public function ScreenManager()
      {
         super();
         Log.log("[ScreenManager] init");
         this._display = new Sprite();
         this._classReferences = {};
      }
      
      public function get display() : DisplayObjectContainer
      {
         return this._display;
      }
      
      public function destroy() : void
      {
         this.destroyScreen();
         this._classReferences = null;
      }
      
      public function register(param1:String, param2:Class) : void
      {
         Log.log("[ScreenManager] registering screen " + param1 + " -> " + param2);
         this._classReferences[param1] = param2;
      }
      
      public function goto(param1:String, param2:Object = null, param3:String = null) : void
      {
         this.destroyScreen();
         Log.log("[ScreenManager] showing screen " + param1);
         if(param2 == null)
         {
            param2 = {};
         }
         this._currentScreen = this.createScreen(param1);
         this._currentScreen.launchVars = param2;
         this._display.addChild(this._currentScreen.display);
         if(this.display.stage)
         {
            this.display.stage.focus = this.display.stage;
         }
         dispatchEvent(new CustomEvent(ScreenManager.SCREEN_INITED,{"name":param1}));
         this._currentScreen.handleAdded();
         dispatchEvent(new CustomEvent(ScreenManager.SCREEN_ADDED,{"name":param1}));
      }
      
      public function get currentScreenName() : String
      {
         return this._currentScreen.screenName;
      }
      
      protected function destroyScreen() : void
      {
         if(!this._currentScreen)
         {
            return;
         }
         this._currentScreen.handleRemoved();
         this._display.removeChild(this._currentScreen.display);
         this._currentScreen.destroy();
         this._currentScreen = null;
      }
      
      protected function createScreen(param1:String) : Screen
      {
         var _loc2_:Screen = null;
         var _loc3_:Class = this._classReferences[param1];
         if(_loc3_)
         {
            _loc2_ = new _loc3_();
         }
         else
         {
            _loc2_ = this.createPlaceholderScreen(param1);
         }
         _loc2_.manager = this;
         _loc2_.screenName = param1;
         return _loc2_;
      }
      
      protected function createPlaceholderScreen(param1:String) : Screen
      {
         var _loc2_:Screen = new Screen();
         var _loc3_:String = "Placeholder for screen " + param1;
         _loc2_.display.addChild(new Text(_loc3_));
         return _loc2_;
      }
   }
}

