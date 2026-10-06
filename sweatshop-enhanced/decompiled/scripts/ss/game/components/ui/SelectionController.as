package ss.game.components.ui
{
   import flash.geom.Point;
   import ss.Constants;
   import ss.Values;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.core.IMessageReceiver;
   import ss.game.entities.Feature;
   import ss.game.entities.MapEntity;
   import ss.game.entities.Selection;
   import ss.game.entities.Unit;
   
   public class SelectionController extends Component implements IMessageReceiver
   {
      
      public function SelectionController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Messages.MOUSE_DOWN,Messages.DEPLOYABLE_CLICKED);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Messages.DEPLOYABLE_CLICKED:
               this.select(param2.id);
               break;
            case Selection.DESELECTED_MSG:
               this.deselect();
               break;
            case Selection.POPUP_CLICKED_MSG:
               this.popupClicked(param2.button);
         }
      }
      
      override public function update(param1:Number) : void
      {
         var _loc2_:MapEntity = engine.find(this.selection.currentlySelectedID) as MapEntity;
         if(Boolean(_loc2_) && !_loc2_.selectable)
         {
            this.deselect();
         }
      }
      
      private function popupClicked(param1:String) : void
      {
         switch(param1)
         {
            case Selection.ACTION_BUTTON:
               this.handleActionClicked();
               break;
            case Selection.CLOSE_BUTTON:
               this.deselect();
               break;
            case Selection.SELL_BUTTON:
               this.handleSellClicked();
         }
      }
      
      private function select(param1:String) : void
      {
         var _loc2_:MapEntity = engine.find(param1) as MapEntity;
         if(!_loc2_ || !_loc2_.selectable)
         {
            return;
         }
         var _loc3_:Point = _loc2_.position;
         if(this.selection.currentlySelectedID == param1 && Values.DOUBLE_CLICK_SELECTION_TO_USE)
         {
            this.handleActionClicked();
         }
         else
         {
            this.deselect();
            this.selection.currentlySelectedID = param1;
            Game.messenger.broadcast(Messages.DEPLOYABLE_SELECTED,{
               "id":param1,
               "tile":_loc3_,
               "type":_loc2_.type
            });
         }
      }
      
      private function deselect() : void
      {
         Game.messenger.broadcast(Messages.DEPLOYABLE_DESELECTED,{"id":this.selection.currentlySelectedID});
         this.selection.currentlySelectedID = null;
      }
      
      private function get selection() : Selection
      {
         return entity as Selection;
      }
      
      private function handleSellClicked() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:MapEntity = engine.find(this.selection.currentlySelectedID) as MapEntity;
         if(_loc1_)
         {
            if(_loc1_ is Unit)
            {
               _loc2_ = Game.shop.getSellPrice((_loc1_ as Unit).key,Game.level.world);
            }
            else
            {
               if(!(_loc1_ is Feature))
               {
                  return;
               }
               _loc2_ = Game.shop.getSellPrice((_loc1_ as Feature).key,Game.level.world);
            }
            _loc1_.remove();
            this.deselect();
         }
      }
      
      private function handleActionClicked() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Feature = null;
         var _loc1_:MapEntity = engine.find(this.selection.currentlySelectedID) as MapEntity;
         if(_loc1_)
         {
            if(_loc1_ is Unit)
            {
               this.handleUpgrade(_loc1_ as Unit);
            }
            else if(_loc1_ is Feature)
            {
               _loc3_ = _loc1_ as Feature;
               if(!(_loc3_.isActivated || _loc3_.isAmbient))
               {
                  this.handleUse(_loc1_ as Feature);
               }
            }
         }
      }
      
      private function handleUse(param1:Feature) : void
      {
         if(param1.isActivated)
         {
            return;
         }
         var _loc2_:Number = Game.shop.getActionPrice(param1.type,Game.level.world);
         if(Game.user.cash < _loc2_)
         {
            return;
         }
         Game.user.removeCash(_loc2_);
         Game.messenger.broadcast(Commands.ACTIVATE_FEATURE,{"id":param1.id});
         Game.messenger.broadcast(Commands.CREATE_CASH_TOOLTIP,{
            "tile":param1.position,
            "amount":-_loc2_,
            "color":Constants.RED
         });
         this.deselect();
      }
      
      private function handleUpgrade(param1:Unit) : void
      {
         var _loc2_:Number = Game.shop.getActionPrice(param1.key,Game.level.world);
         if(!param1.getCanLevelUpRightNow())
         {
            return;
         }
         if(Game.user.cash < _loc2_)
         {
            return;
         }
         Game.user.removeCash(_loc2_);
         var _loc3_:Point = param1.position;
         Game.messenger.broadcast(Commands.CREATE_CASH_TOOLTIP,{
            "tile":param1.position,
            "amount":-_loc2_,
            "color":Constants.RED,
            "offsetY":-30 * Game.level.objectScale
         });
         Game.factory.levelUp(param1);
         this.deselect();
      }
   }
}

