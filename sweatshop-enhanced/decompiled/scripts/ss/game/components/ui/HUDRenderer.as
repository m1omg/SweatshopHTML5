package ss.game.components.ui
{
   import flash.display.MovieClip;
   import ss.Values;
   import ss.app.App;
   import ss.game.Commands;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Engine;
   import ss.game.core.Renderer;
   import ss.game.display.BeltSpeedPatch;
   import ss.game.display.PatchCollection;
   import ss.utils.Utils;
   
   public class HUDRenderer extends Renderer
   {
      
      private var HUDXML:Class = HUDRenderer_HUDXML;
      
      private var _panel:MovieClip;
      
      private var _buttons:Array;
      
      private var _menu:PatchCollection;
      
      private var _beltSpeed:BeltSpeedPatch;
      
      private var _isInteractive:Boolean;
      
      private var _oldTimeString:String;
      
      public function HUDRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         this._panel = App.instance.resources.instantiateMovieClip("hud","HUDSymbol");
         addElement(this._panel,true,true).depth = DepthManager.getDepth(DepthManager.CONTROL_PANEL);
         this._menu = new PatchCollection(this._panel);
         var _loc1_:XML = new XML(new this.HUDXML());
         if(Values.HUD_COMPACT)
         {
            _loc1_ = this.compactHUDXML();
         }
         this._menu.init(_loc1_,Game.level.newUnits);
         this._menu.visible = true;
         this._isInteractive = true;
         this._beltSpeed = new BeltSpeedPatch(this._panel["speed"]);
         Game.messenger.register(this,Engine.ENGINE_PAUSED,Engine.ENGINE_UNPAUSED,Messages.CASH_CHANGED,Commands.HILITE_ICON,Commands.UNHILITE_ICON,Messages.FAST_FORWARDED,Messages.ICON_DRAGGED,Messages.ICON_DROPPED,Messages.ICON_DISCARDED);
         this.updateCash();
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Engine.ENGINE_PAUSED:
               this._panel.mouseChildren = false;
               break;
            case Engine.ENGINE_UNPAUSED:
               this._panel.mouseChildren = this._isInteractive;
               break;
            case Messages.FAST_FORWARDED:
               this._isInteractive = false;
               this._panel.mouseChildren = false;
               break;
            case Messages.CASH_CHANGED:
               this.updateCash();
               break;
            case Commands.HILITE_ICON:
               this.hilite(true,param2.icon,param2.unhilite_on_click);
               break;
            case Commands.UNHILITE_ICON:
               this.hilite(false,param2.icon);
               break;
            case Messages.ICON_DRAGGED:
               this._menu.closeAll();
               this._menu.canOpenMenus = false;
               break;
            case Messages.ICON_DROPPED:
            case Messages.ICON_DISCARDED:
               this._menu.canOpenMenus = true;
               break;
            case Messages.BELT_SPEED_CHANGED:
               this._beltSpeed.refresh();
         }
      }
      
      private function hilite(param1:Boolean, param2:String, param3:Boolean = false) : void
      {
         this._menu.hilite(param1,param2,param3);
         this._beltSpeed.hilite(param1,param2,param3);
      }
      
      private function updateCash() : void
      {
         this._panel["cash"]["cash"].text = Utils.formatCash(Game.user.cash);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this._menu.destroy();
         this._beltSpeed.destroy();
      }
      
      override public function render() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this._panel["deliveries"].text = Game.user.delivered + "/" + Game.level.numItems;
         if(Game.level.allowedRejections > -1)
         {
            this._panel["rejections"].text = Game.user.rejected + "/" + Game.level.allowedRejections;
         }
         else
         {
            this._panel["rejections"].text = Game.user.rejected;
         }
         var _loc1_:int = Math.floor(Game.engine.timer.elapsed);
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         if(_loc1_ > 999)
         {
            _loc1_ = 999;
         }
         var _loc5_:String = _loc1_.toString();
         var _loc6_:MovieClip = this._panel["time"];
         this._panel["time_red"].visible = false;
         switch(_loc5_.length)
         {
            case 1:
               _loc2_ = _loc1_;
               _loc3_ = 10;
               _loc4_ = 10;
               break;
            case 2:
               _loc2_ = parseInt(_loc5_.substring(0,1));
               _loc3_ = parseInt(_loc5_.substring(1,2));
               _loc4_ = 10;
               break;
            case 3:
               _loc2_ = parseInt(_loc5_.substring(0,1));
               _loc3_ = parseInt(_loc5_.substring(1,2));
               _loc4_ = parseInt(_loc5_.substring(2,3));
         }
         this._oldTimeString = _loc5_;
         _loc6_["d1"].gotoAndStop(_loc2_ + 1);
         _loc6_["d2"].gotoAndStop(_loc3_ + 1);
         _loc6_["d3"].gotoAndStop(_loc4_ + 1);
         super.render();
      }
      
      private function compactHUDXML() : XML
      {
         var _loc7_:XML = null;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc1_:XML = <menu>
						
					<icon type="child" key="child_1" category="worker" resname="entity.child"/>
					<icon type="hat_maker" key="hat_maker_1" category="worker" resname="entity.hat_maker"/>
					<icon type="shirt_maker" key="shirt_maker_1" category="worker" resname="entity.shirt_maker"/>
					<icon type="bag_maker" key="bag_maker_1" category="worker" resname="entity.bag_maker"/>
					<icon type="shoe_maker" key="shoe_maker_1" category="worker" resname="entity.shoe_maker"/>
					<icon type="packer" key="packer_1" category="worker" resname="entity.packer"/>
					<icon type="engineer" key="engineer_1" category="officer" resname="entity.engineer"/>
					<icon type="fire_officer" key="fire_officer_1" category="officer" resname="entity.fire_officer"/>
					<icon type="superstar" key="superstar_1" category="worker" resname="entity.superstar"/>
				</menu>;
         var _loc2_:XML = <menu type="_special" resname="hud.special">
					</menu>;
         var _loc3_:XML = <menu type="_features" resname="hud.features">
					<icon type="water" key="water" category="feature" resname="entity.water" effect="entity.water.effect" color="cyan"/>
					<icon type="fan" key="fan" category="feature" resname="entity.fan" effect="entity.fan.effect" color="yellow"/>
					<icon type="radio" key="radio" category="feature" resname="entity.radio" effect="entity.radio.effect" color="orange"/>
					
					<icon type="cola" key="cola" category="feature" resname="entity.cola" effect="entity.cola.effect" color="cyan"/>
					<icon type="toilet" key="toilet" category="feature" resname="entity.toilet" effect="entity.toilet.effect" color="yellow"/>
					<icon type="sign" key="sign" category="feature" resname="entity.sign" effect="entity.sign.effect" color="orange"/>
					
					<icon type="juice" key="juice" category="feature" resname="entity.juice" effect="entity.juice.effect" color="cyan"/>
					<icon type="heater" key="heater" category="feature" resname="entity.heater" effect="entity.heater.effect" color="yellow"/>
					<icon type="tannoy" key="tannoy" category="feature" resname="entity.tannoy" effect="entity.tannoy.effect" color="orange"/>
				</menu>;
         var _loc4_:XML = new XML(<menu/>);
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         for each(_loc7_ in _loc1_.icon)
         {
            if(Game.level.getAvailibility(_loc7_.@type))
            {
               _loc5_.push(_loc7_);
            }
            else
            {
               _loc6_.push(_loc7_);
            }
         }
         _loc8_ = _loc5_.concat(_loc6_);
         _loc9_ = 0;
         while(_loc9_ < _loc8_.length)
         {
            if(_loc9_ <= 4)
            {
               _loc4_.appendChild(_loc8_[_loc9_]);
            }
            else
            {
               _loc2_.appendChild(_loc8_[_loc9_]);
            }
            _loc9_++;
         }
         _loc4_.appendChild(_loc2_);
         _loc4_.appendChild(_loc3_);
         return _loc4_;
      }
   }
}

