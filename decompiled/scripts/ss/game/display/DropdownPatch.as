package ss.game.display
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.utils.Utils;
   
   public class DropdownPatch extends PatchBase
   {
      
      public static const OVER:String = "onOver";
      
      public static const OUT:String = "onOut";
      
      public static const DOWN:String = "onDown";
      
      private var _menu:PatchCollection;
      
      private var _isOpen:Boolean = false;
      
      private var _isOverOpenArea:Boolean = false;
      
      public function DropdownPatch(param1:MovieClip, param2:MovieClip, param3:XML, param4:Array)
      {
         super(param1);
         this._menu = new PatchCollection(param2);
         this._menu.init(param3,param4);
         name = param3.@type;
         _mc["menuhit"].gotoAndStop(name);
         _mc["up"].gotoAndStop("normal");
         _mc["over"].gotoAndStop("normal");
         isActive = this._menu.anyAvailable;
         _mc.addEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         _mc.removeEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      override protected function handleMouseOver() : void
      {
         dispatchEvent(new Event(OVER));
      }
      
      override protected function handleMouseDown() : void
      {
         if(!this._isOpen)
         {
            dispatchEvent(new Event(DOWN));
         }
      }
      
      override protected function applyIconEffect() : void
      {
         _mc["arrow"].visible = isActive;
      }
      
      public function open() : void
      {
         this._isOpen = true;
         Game.messenger.broadcast(Messages.MENU_OPENED,{"name":name});
         if(_hilited)
         {
            _mc["hilite"].visible = false;
         }
         this.refresh();
         Utils.tweenInTooltip(this._menu.mc);
         this._isOverOpenArea = true;
      }
      
      public function close() : void
      {
         this._isOpen = false;
         Game.messenger.broadcast(Messages.MENU_CLOSED,{"name":name});
         if(_hilited)
         {
            _mc["hilite"].visible = true;
         }
         this.refresh();
      }
      
      override public function hilite(param1:Boolean, param2:String = null, param3:Boolean = false) : Boolean
      {
         var _loc4_:Boolean = false;
         if(this._menu)
         {
            _loc4_ = this._menu.hilite(param1,param2);
         }
         if(!param1)
         {
            super.hilite(param1,param2,param3);
         }
         if(_loc4_)
         {
            super.hilite(param1,null,param3);
         }
         return _loc4_;
      }
      
      override public function refresh() : void
      {
         if(isActive)
         {
            _mc["inactive"].visible = false;
         }
         else
         {
            _mc["over"].visible = false;
            _mc["up"].visible = false;
            _mc["inactive"].visible = true;
         }
         if(_isOver)
         {
            _mc["over"].visible = true;
            _mc["up"].visible = false;
         }
         else
         {
            _mc["over"].visible = false;
            _mc["up"].visible = true;
         }
         if(this._isOpen)
         {
            this._menu.visible = true;
            _mc["over"].visible = true;
            _mc["up"].visible = false;
         }
         else
         {
            this._menu.visible = false;
         }
      }
      
      private function onFrame(param1:Event) : void
      {
         if(!this._isOpen)
         {
            return;
         }
         var _loc2_:MovieClip = _mc["menuhit"];
         var _loc3_:Point = new Point(Game.canvas.display.mouseX,Game.canvas.display.mouseY);
         var _loc4_:Boolean = _loc2_.hitTestPoint(_loc3_.x,_loc3_.y,true);
         if(this.isOverOpenArea && !_loc4_)
         {
            dispatchEvent(new Event(OUT));
         }
         this._isOverOpenArea = _loc4_;
      }
      
      public function get isOverOpenArea() : Boolean
      {
         return this._isOverOpenArea;
      }
   }
}

