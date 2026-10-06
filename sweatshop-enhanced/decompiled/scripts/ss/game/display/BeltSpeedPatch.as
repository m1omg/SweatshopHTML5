package ss.game.display
{
   import flash.display.MovieClip;
   import ss.app.App;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.entities.Belt;
   import ss.utils.Utils;
   
   public class BeltSpeedPatch extends HUDButton
   {
      
      private var _tooltip:MovieClip;
      
      public function BeltSpeedPatch(param1:MovieClip)
      {
         super(param1);
         name = param1.name;
         this.refresh();
         _mc["fast"].gotoAndStop("up");
         _mc["slow"].gotoAndStop("up");
         this._tooltip = _mc["tooltip"];
         this._tooltip.visible = false;
         Game.messenger.register(this,Messages.BELT_SPEED_CHANGED);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         super.receiveMessage(param1,param2);
         if(param1 == Messages.BELT_SPEED_CHANGED)
         {
            this.refresh();
         }
      }
      
      override protected function handleMouseDown() : void
      {
         Game.messenger.broadcast(Commands.TOGGLE_BELT_SPEED);
      }
      
      override protected function handleMouseOver() : void
      {
         this._tooltip.visible = true;
         Utils.tweenInTooltip(this._tooltip);
      }
      
      override protected function handleMouseOut() : void
      {
         this._tooltip.visible = false;
      }
      
      override public function hide() : void
      {
         _mc.mouseChildren = _mc.mouseEnabled = _mc.tabChildren = _mc.tabChildren = false;
         _mc.filters = [Utils.desaturated()];
      }
      
      override public function show() : void
      {
         _mc.mouseChildren = _mc.mouseEnabled = _mc.tabChildren = _mc.tabChildren = true;
         _mc.filters = [];
      }
      
      override public function refresh() : void
      {
         var _loc1_:Belt = Game.engine.find("belt") as Belt;
         if(!_loc1_)
         {
            return;
         }
         if(_loc1_.speedSetting == Belt.STOPPED)
         {
            this.hide();
            return;
         }
         this.show();
         var _loc2_:String = "hud.belt.fast";
         if(_loc1_.speedSetting == Belt.FAST)
         {
            _loc2_ = "hud.belt.slow";
         }
         this._tooltip["label"].text = App.instance.text.getText(_loc2_);
         _mc["fast"].visible = _loc1_.speedSetting == Belt.FAST || _loc1_.speedSetting == Belt.FAST_FORWARD;
         _mc["slow"].visible = _loc1_.speedSetting == Belt.SLOW;
         if(_isOver)
         {
            _mc["fast"].gotoAndStop("over");
            _mc["slow"].gotoAndStop("over");
         }
         else
         {
            _mc["fast"].gotoAndStop("up");
            _mc["slow"].gotoAndStop("up");
         }
      }
   }
}

