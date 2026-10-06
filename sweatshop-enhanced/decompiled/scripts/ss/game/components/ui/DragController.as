package ss.game.components.ui
{
   import flash.geom.Point;
   import ss.Constants;
   import ss.Values;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.entities.DragInstance;
   import ss.game.entities.Map;
   import ss.utils.Utils;
   
   public class DragController extends Component
   {
      
      public function DragController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Commands.PICK_UP_ICON,Messages.MOUSE_UP);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Commands.PICK_UP_ICON:
               this.attach(param2);
               break;
            case Messages.MOUSE_UP:
               if(this.dragInstance.isDragging)
               {
                  this.release();
               }
         }
      }
      
      override public function update(param1:Number) : void
      {
         this.dragInstance.mouseTile = Game.canvas.mouseTile.clone().add(new Point(Values.DRAG_TILE_X_OFFSET,Values.DRAG_TILE_Y_OFFSET));
         if(!this.dragInstance.isDragging)
         {
            return;
         }
         this.dragInstance.canDrop = this.getCanDrop();
         this.dragInstance.canBuy = this.getCanBuy();
      }
      
      private function attach(param1:Object) : void
      {
         this.dragInstance.isDragging = true;
         this.dragInstance.attributes = param1;
         this.dragInstance.staticData = Game.factory.getRow(param1.category,param1.key);
         this.dragInstance.price = Game.shop.getBuyPrice(param1.key,Game.level.world);
         Game.messenger.broadcast(Messages.ICON_DRAGGED);
      }
      
      private function release() : void
      {
         var _loc1_:Point = null;
         var _loc2_:Boolean = false;
         this.dragInstance.isDragging = false;
         if(this.dragInstance.canDrop && this.dragInstance.canBuy)
         {
            _loc1_ = this.dragInstance.mouseTile;
            _loc2_ = Game.factory.create(this.dragInstance.attributes.key,_loc1_.x,_loc1_.y,{"gender":this.dragInstance.gender});
            if(_loc2_)
            {
               Game.user.removeCash(this.dragInstance.price);
               Game.messenger.broadcast(Commands.CREATE_CASH_TOOLTIP,{
                  "tile":_loc1_,
                  "amount":-this.dragInstance.price,
                  "color":Constants.RED,
                  "offsetY":-30 * Game.level.objectScale
               });
               Game.messenger.broadcast(Messages.ICON_DROPPED);
            }
         }
         else
         {
            Game.messenger.broadcast(Messages.ICON_DISCARDED);
         }
      }
      
      private function getCanDrop() : Boolean
      {
         var _loc1_:Map = engine.resolveReference(this.dragInstance.mapRef);
         if(!_loc1_)
         {
            return false;
         }
         var _loc2_:Point = this.dragInstance.mouseTile;
         if(!Utils.isActiveTile(_loc2_,Game.level.world))
         {
            return false;
         }
         switch(this.dragInstance.attributes.category)
         {
            case "worker":
               return _loc1_.canPlaceWorker(_loc2_);
            default:
               return _loc1_.isEmpty(_loc2_);
         }
      }
      
      private function getCanBuy() : Boolean
      {
         return Game.user.cash >= this.dragInstance.price;
      }
      
      private function get dragInstance() : DragInstance
      {
         return entity as DragInstance;
      }
   }
}

