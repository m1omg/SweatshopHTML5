package ss.game.display
{
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.utils.Utils;
   
   public class IconPatch extends PatchBase
   {
      
      private var _attributes:Object;
      
      public function IconPatch(param1:MovieClip, param2:Object = null, param3:String = "normal")
      {
         super(param1);
         if(!param2)
         {
            param2 = {};
         }
         this._attributes = param2;
         _mc["over"].gotoAndStop(param3);
         _mc["up"].gotoAndStop(param3);
         Game.messenger.register(this,Messages.CASH_CHANGED);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         super.receiveMessage(param1,param2);
         switch(param1)
         {
            case Messages.CASH_CHANGED:
               this.refresh();
         }
      }
      
      override protected function applyIconEffect() : void
      {
         if(!isActive)
         {
            _mc["icon"].transform.colorTransform = new ColorTransform(0,0,0,0.6015625,0,0,0,0);
         }
      }
      
      override protected function handleMouseDown() : void
      {
         Game.messenger.broadcast(Commands.PICK_UP_ICON,this._attributes);
      }
      
      override public function refresh() : void
      {
         if(Game.user.cash >= _price)
         {
            _mc["button"].gotoAndStop("green");
            _mc["icon"].filters = [];
         }
         else
         {
            _mc["button"].gotoAndStop("red");
            _mc["icon"].filters = [Utils.desaturated()];
         }
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
            showLabel();
            _mc["over"].visible = true;
            _mc["up"].visible = false;
         }
         else
         {
            hideLabel();
            _mc["over"].visible = false;
            _mc["up"].visible = true;
         }
      }
   }
}

