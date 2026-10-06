package ss.game.components.ui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import org.fatlib.utils.MathUtils;
   import ss.Constants;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Entity;
   import ss.game.core.IMessageReceiver;
   import ss.game.core.Renderer;
   import ss.game.entities.Feature;
   import ss.game.entities.MapEntity;
   import ss.game.entities.Selection;
   import ss.game.entities.Unit;
   import ss.utils.Utils;
   
   public class SelectionPopupRenderer extends Renderer implements IMessageReceiver
   {
      
      private static var USE_ACTIVE:String = "USE_ACTIVE";
      
      private static var USE_INACTIVE_CANT_AFFORD:String = "USE_INACTIVE_CANT_AFFORD";
      
      private static var USE_INACTIVE_UNAVAILABLE:String = "USE_INACTIVE_UNAVAILABLE";
      
      private static var USE_INACTIVE_LEVEL_MAX:String = "USE_INACTIVE_LEVEL_MAX";
      
      private var _useState:String;
      
      private var _mc:MovieClip;
      
      private var _sellMC:MovieClip;
      
      private var _useMC:MovieClip;
      
      private var _selectedUnitScreenPosition:Point;
      
      public function SelectionPopupRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         this._mc = App.instance.resources.instantiateMovieClip("hud","SelectMenuSymbol");
         this._mc.visible = false;
         addElement(this._mc,true,true).depth = DepthManager.getDepth(DepthManager.SELECT_POPUP);
         this._mc["select_hit"].alpha = 0;
         this._mc.gotoAndStop("normal");
         this._useMC = this._mc["star"];
         this._sellMC = this._mc["sell"];
         Game.messenger.register(this,Messages.DEPLOYABLE_SELECTED,Messages.DEPLOYABLE_DESELECTED,Messages.CASH_CHANGED,Messages.FEATURE_ACTIVATED,Messages.FEATURE_DEACTIVATED,Messages.MOUSE_DOWN,Messages.MENU_OPENED,Messages.ICON_DRAGGED);
         this._mc.addEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      override public function destroy() : void
      {
         this._mc.removeEventListener(MouseEvent.CLICK,this.onClick);
         super.destroy();
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Messages.DEPLOYABLE_SELECTED:
               this.show();
               this.refresh();
               break;
            case Messages.DEPLOYABLE_DESELECTED:
            case Messages.MENU_OPENED:
            case Messages.ICON_DRAGGED:
               this.hide();
               break;
            case Messages.CASH_CHANGED:
            case Messages.FEATURE_ACTIVATED:
            case Messages.FEATURE_DEACTIVATED:
               if(this._mc.visible)
               {
                  this.refresh();
               }
               break;
            case Messages.MOUSE_DOWN:
               this.handleMouseDown(param2.tile,param2.point,param2.target);
         }
      }
      
      override public function render() : void
      {
         if(!this._mc.visible)
         {
            return;
         }
         var _loc1_:MovieClip = this._useMC["select_action"];
         var _loc2_:MovieClip = this._sellMC["select_sell"];
         var _loc3_:MovieClip = this._mc["select_close"];
         var _loc4_:Point = Game.canvas.mousePosition;
         if(this._useState != USE_ACTIVE)
         {
            _loc1_.gotoAndStop("inactive");
            (this._useMC["use_label"] as TextField).textColor = Constants.DARK_GREY;
            if(this._useState == USE_INACTIVE_CANT_AFFORD)
            {
               this._useMC["select_price"].visible = true;
               this._useMC["select_price"].gotoAndStop("red");
            }
            else if(this._useState == USE_INACTIVE_UNAVAILABLE || this._useState == USE_INACTIVE_LEVEL_MAX)
            {
               this._useMC["select_price"].visible = false;
            }
            _loc1_.buttonMode = false;
            _loc1_.mouseEnabled = false;
         }
         else
         {
            _loc1_.buttonMode = true;
            _loc1_.mouseEnabled = true;
            if(_loc1_.hitTestPoint(_loc4_.x,_loc4_.y,true))
            {
               _loc1_.gotoAndStop("over");
            }
            else
            {
               _loc1_.gotoAndStop("up");
            }
            (this._useMC["use_label"] as TextField).textColor = Constants.YELLOW;
            this._useMC["select_price"].visible = true;
            this._useMC["select_price"].gotoAndStop("green");
         }
         if(_loc2_.hitTestPoint(_loc4_.x,_loc4_.y,true))
         {
            _loc2_.gotoAndStop("over");
         }
         else
         {
            _loc2_.gotoAndStop("up");
         }
         if(_loc3_.hitTestPoint(_loc4_.x,_loc4_.y,true))
         {
            _loc3_.gotoAndStop("over");
         }
         else
         {
            _loc3_.gotoAndStop("up");
         }
         if(Boolean(this._selectedUnitScreenPosition) && MathUtils.distance(_loc4_,this._selectedUnitScreenPosition) > 225)
         {
            this.broadcastDeselectMessage();
         }
         super.render();
      }
      
      private function broadcastDeselectMessage() : void
      {
         entity.broadcastLocalMessage(Selection.DESELECTED_MSG);
      }
      
      private function handleMouseDown(param1:Point, param2:Point, param3:String) : void
      {
         if(!this.selection.currentlySelectedID)
         {
            return;
         }
         var _loc4_:Entity = engine.find(this.selection.currentlySelectedID);
         var _loc5_:Boolean = this._mc.hitTestPoint(param2.x,param2.y,true);
         var _loc6_:Boolean = _loc4_.position.equals(param1);
         var _loc7_:Boolean = this.selection.currentlySelectedID == param3;
         if(!(_loc5_ || _loc7_ || _loc6_))
         {
            this.broadcastDeselectMessage();
         }
      }
      
      private function hide() : void
      {
         this._mc.visible = false;
      }
      
      private function show() : void
      {
         var _loc1_:MapEntity = engine.find(this.selection.currentlySelectedID) as MapEntity;
         if(!_loc1_)
         {
            return;
         }
         this._selectedUnitScreenPosition = Game.canvas.tileToScreen(_loc1_.position);
         if(this._mc.visible == false)
         {
            Utils.tweenInTooltip(this._mc);
         }
         this._mc.visible = true;
         var _loc2_:Point = Game.canvas.tileToScreen(_loc1_.position);
         var _loc3_:Boolean = _loc2_.y > 220;
         var _loc4_:Number = -40 * Game.level.objectScale;
         if(!_loc3_)
         {
            _loc4_ = Game.level.tileHeight + 120 * Game.level.objectScale;
         }
         this._mc["label"].text = App.instance.text.getText("entity." + _loc1_.type);
         this._mc.x = _loc2_.x + Game.level.tileWidth / 2;
         this._mc.y = _loc2_.y + _loc4_;
         this._mc["bg_up"].visible = _loc3_;
         this._mc["bg_down"].visible = !_loc3_;
         var _loc5_:MovieClip = this._sellMC["select_sell"];
         var _loc6_:MovieClip = this._mc["select_close"];
         _loc5_.buttonMode = true;
         _loc6_.buttonMode = true;
         if(_loc1_ is Feature)
         {
            this._sellMC["sell_label"].text = App.instance.text.getText("selection.feature.sell");
            if((_loc1_ as Feature).isAmbient)
            {
               this._mc.gotoAndStop("ambient");
               this._useMC.visible = false;
            }
            else
            {
               this._useMC.visible = true;
               this._useMC["use_label"].text = App.instance.text.getText("selection.feature.action");
               this._mc.gotoAndStop("normal");
            }
         }
         else
         {
            this._useMC.visible = true;
            this._mc.gotoAndStop("normal");
            this._useMC["use_label"].text = App.instance.text.getText("selection.unit.action");
            this._sellMC["sell_label"].text = App.instance.text.getText("selection.unit.sell");
         }
         this.refresh(_loc1_);
      }
      
      private function refresh(param1:MapEntity = null) : void
      {
         if(!param1)
         {
            param1 = engine.find(this.selection.currentlySelectedID) as MapEntity;
         }
         if(!param1)
         {
            return;
         }
         var _loc2_:Number = Game.shop.getActionPrice(param1.key,Game.level.world);
         this._useMC["select_price"]["price"]["price"].text = Utils.formatCash(_loc2_);
         var _loc3_:Boolean = Game.user.cash >= _loc2_;
         if(param1 is Unit)
         {
            if(!(param1 as Unit).canLevelUp)
            {
               this._useState = USE_INACTIVE_LEVEL_MAX;
               this._useMC["use_label"].text = App.instance.text.getText("selection.unit.max");
            }
            else if(!(param1 as Unit).getCanLevelUpRightNow())
            {
               this._useState = USE_INACTIVE_UNAVAILABLE;
            }
            else if(!_loc3_)
            {
               this._useState = USE_INACTIVE_CANT_AFFORD;
            }
            else
            {
               this._useState = USE_ACTIVE;
            }
         }
         else if(param1 is Feature)
         {
            if(!(param1 as Feature).isActivated && _loc3_)
            {
               this._useState = USE_ACTIVE;
            }
            else
            {
               this._useState = USE_INACTIVE_CANT_AFFORD;
            }
         }
         else
         {
            this._useState = USE_ACTIVE;
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         switch(param1.target.name)
         {
            case Selection.ACTION_BUTTON:
            case Selection.CLOSE_BUTTON:
            case Selection.SELL_BUTTON:
               _loc2_ = {"button":param1.target.name};
         }
         if(_loc2_)
         {
            entity.broadcastLocalMessage(Selection.POPUP_CLICKED_MSG,_loc2_);
         }
      }
      
      private function get selection() : Selection
      {
         return entity as Selection;
      }
   }
}

