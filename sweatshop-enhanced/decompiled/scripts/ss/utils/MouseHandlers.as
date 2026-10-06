package ss.utils
{
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.VisualElement;
   
   public class MouseHandlers
   {
      
      private static var _index:Dictionary;
      
      public function MouseHandlers()
      {
         super();
      }
      
      public static function add(param1:VisualElement, param2:String) : void
      {
         if(!_index)
         {
            _index = new Dictionary();
         }
         if(_index[param1])
         {
            throw new Error(param1.name + " aleady has mouse handlers!");
         }
         param1.mouseEnabled = true;
         param1.mouseChildren = false;
         param1.useHandCursor = true;
         param1.buttonMode = true;
         param1.addEventListener(MouseEvent.MOUSE_OVER,onOver);
         param1.addEventListener(MouseEvent.MOUSE_OUT,onOut);
         param1.addEventListener(MouseEvent.CLICK,onClick);
         _index[param1] = param2;
      }
      
      public static function remove(param1:VisualElement) : void
      {
         if(!_index[param1])
         {
            throw new Error(param1.name + " doesnt have mouse handlers added!");
         }
         param1.removeEventListener(MouseEvent.MOUSE_OVER,onOver);
         param1.removeEventListener(MouseEvent.MOUSE_OUT,onOut);
         param1.removeEventListener(MouseEvent.CLICK,onClick);
         _index[param1] = null;
         delete _index[param1];
      }
      
      private static function onOver(param1:MouseEvent) : void
      {
         var _loc2_:String = _index[param1.target];
         Game.messenger.broadcast(Messages.DEPLOYABLE_MOUSE_OVER,{"id":_loc2_});
      }
      
      private static function onOut(param1:MouseEvent) : void
      {
         var _loc2_:String = _index[param1.target];
         Game.messenger.broadcast(Messages.DEPLOYABLE_MOUSE_OUT,{"id":_loc2_});
      }
      
      private static function onClick(param1:MouseEvent) : void
      {
         var _loc2_:String = _index[param1.target];
         Game.messenger.broadcast(Messages.DEPLOYABLE_CLICKED,{"id":_loc2_});
      }
      
      public static function flush() : void
      {
         var _loc1_:* = undefined;
         for(_loc1_ in _index)
         {
            remove(_loc1_);
         }
      }
   }
}

