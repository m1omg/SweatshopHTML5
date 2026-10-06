package ss.game.components
{
   import flash.geom.Point;
   import ss.Values;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.core.Entity;
   import ss.game.entities.Belt;
   import ss.game.entities.Item;
   import ss.game.entities.MapEntity;
   
   public class ItemController extends Component
   {
      
      private var _hasReachedEnd:Boolean = false;
      
      public function ItemController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         var _loc1_:Belt = engine.resolveReference(this.item.beltRef);
         if(!_loc1_)
         {
            return;
         }
         this.item.tileEntryPoint = new Point().subtract(_loc1_.getMotionVector(this.item.position));
         this.item.tileExitPoint = _loc1_.getMotionVector(this.item.position);
         this.checkNodeTile(_loc1_);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Entity.ON_STATE_CHANGED:
               if(entity.state == Item.DONE_STATE)
               {
                  Game.messenger.broadcast(Messages.ITEM_COMPLETED,{"id":entity.id});
                  if(Values.CASH_ON_PACK)
                  {
                     this.payUser();
                  }
                  break;
               }
               if(entity.state == MapEntity.BURNING_STATE)
               {
                  this.item.workProgress = 0;
               }
         }
      }
      
      override public function update(param1:Number) : void
      {
         var _loc4_:Boolean = false;
         var _loc2_:Belt = engine.resolveReference(this.item.beltRef);
         if(!_loc2_)
         {
            return;
         }
         this.item.tileProgress += param1 * _loc2_.speed;
         var _loc3_:Boolean = false;
         while(this.item.tileProgress >= 1)
         {
            this.item.position = this.item.position.add(this.item.tileExitPoint);
            this.advanceTile();
            --this.item.tileProgress;
            _loc4_ = _loc2_.isEndNode(this.item.position);
            if(_loc4_)
            {
               this._hasReachedEnd = true;
            }
            if(this._hasReachedEnd && !_loc4_)
            {
               _loc3_ = true;
            }
         }
         if(_loc3_ || this._hasReachedEnd && this.item.tileProgress >= 0.5)
         {
            if(this.item.state == Item.DONE_STATE)
            {
               Game.messenger.broadcast(Commands.CREATE_ICON_TOOLTIP,{
                  "tile":this.item.position,
                  "icon":"delivery",
                  "offsetY":-Game.level.beltHeight
               });
               Game.messenger.broadcast(Messages.ITEM_DELIVERED,{"id":this.item.id});
               if(!Values.CASH_ON_PACK)
               {
                  this.payUser();
               }
            }
            else
            {
               Game.messenger.broadcast(Commands.CREATE_ICON_TOOLTIP,{
                  "tile":this.item.position,
                  "icon":"rejection",
                  "offsetY":-Game.level.beltHeight
               });
               Game.messenger.broadcast(Messages.ITEM_REJECTED,{"id":this.item.id});
            }
            engine.removeEntity(this.item.id);
         }
      }
      
      private function payUser() : void
      {
         var _loc1_:Number = Game.shop.getSellPrice(this.item.key,Game.level.world);
         var _loc2_:Number = Math.ceil(_loc1_ * (this.item.cashBonus / 100));
         Game.user.addCash(_loc1_ + _loc2_);
         Game.messenger.broadcast(Commands.CREATE_CASH_TOOLTIP,{
            "tile":this.item.position,
            "amount":_loc1_,
            "bonus":_loc2_,
            "offsetY":-Game.level.beltHeight
         });
      }
      
      private function advanceTile() : void
      {
         ++this.item.tileCount;
         var _loc1_:Belt = engine.resolveReference(this.item.beltRef);
         if(!_loc1_)
         {
            return;
         }
         this.item.tileEntryPoint = new Point(-this.item.tileExitPoint.x,-this.item.tileExitPoint.y);
         this.item.tileExitPoint = _loc1_.getMotionVector(this.item.position);
         this.item.direction = _loc1_.getDirection(this.item.position);
         this.checkNodeTile(_loc1_);
      }
      
      private function checkNodeTile(param1:Belt) : void
      {
         param1 = engine.resolveReference(this.item.beltRef);
         if(!param1)
         {
            return;
         }
         this.item.onNodeTile = param1.isStartNode(this.item.position) || param1.isEndNode(this.item.position);
      }
      
      private function get item() : Item
      {
         return entity as Item;
      }
   }
}

