package org.fatlib.ui
{
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   
   public class Key
   {
      
      private static var _keysDown:Object;
      
      private static var _inited:Boolean = false;
      
      private static var _wasd:Boolean = true;
      
      public function Key()
      {
         super();
      }
      
      public static function init(param1:Stage) : void
      {
         if(!_inited)
         {
            _keysDown = {};
            param1.addEventListener(KeyboardEvent.KEY_DOWN,keyPressed);
            param1.addEventListener(KeyboardEvent.KEY_UP,keyReleased);
            param1.addEventListener(Event.DEACTIVATE,clearKeys);
            _inited = true;
         }
      }
      
      public static function isDown(param1:uint) : Boolean
      {
         if(!_inited)
         {
            throw new Error("Key class has yet been inited.");
         }
         return Boolean(param1 in _keysDown);
      }
      
      public static function isCharDown(param1:String) : Boolean
      {
         if(!_inited)
         {
            throw new Error("Key class has yet been inited.");
         }
         return isDown(param1.charCodeAt(0));
      }
      
      public static function get left() : Boolean
      {
         return isDown(Keyboard.LEFT) || isDown(65) && _wasd;
      }
      
      public static function get right() : Boolean
      {
         return isDown(Keyboard.RIGHT) || isDown(68) && _wasd;
      }
      
      public static function get up() : Boolean
      {
         return isDown(Keyboard.UP) || isDown(87) && _wasd;
      }
      
      public static function get down() : Boolean
      {
         return isDown(Keyboard.DOWN) || isDown(83) && _wasd;
      }
      
      public static function get shift() : Boolean
      {
         return isDown(Keyboard.SHIFT);
      }
      
      public static function get ctrl() : Boolean
      {
         return isDown(Keyboard.CONTROL);
      }
      
      public static function get space() : Boolean
      {
         return isDown(Keyboard.SPACE);
      }
      
      public static function get enter() : Boolean
      {
         return isDown(Keyboard.ENTER);
      }
      
      public static function set wasd(param1:Boolean) : void
      {
         _wasd = param1;
      }
      
      private static function keyPressed(param1:KeyboardEvent) : void
      {
         _keysDown[param1.keyCode] = true;
      }
      
      private static function keyReleased(param1:KeyboardEvent) : void
      {
         if(param1.keyCode in _keysDown)
         {
            delete _keysDown[param1.keyCode];
         }
      }
      
      private static function clearKeys(param1:Event) : void
      {
         _keysDown = {};
      }
   }
}

