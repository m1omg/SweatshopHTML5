package ss.game.components.units
{
   import ss.Values;
   import ss.game.components.BeltInfoController;
   import ss.game.core.Component;
   import ss.game.core.Entity;
   import ss.game.core.IMessageReceiver;
   import ss.game.entities.Item;
   import ss.game.entities.Unit;
   import ss.game.entities.Worker;
   import ss.game.factory.EntityFactory;
   import ss.utils.Utils;
   
   public class WorkerController extends Component implements IMessageReceiver
   {
      
      private var _packerExists:Boolean;
      
      public function WorkerController()
      {
         super();
      }
      
      override public function update(param1:Number) : void
      {
         var _loc3_:BeltInfoController = null;
         if(this.worker.state != Unit.NORMAL_STATE)
         {
            this.worker.isWorking = false;
            this.worker.currentItemRef = null;
            return;
         }
         var _loc2_:Item = engine.resolveReference(this.worker.currentItemRef);
         if(_loc2_)
         {
            _loc3_ = engine.resolveReference(this.worker.beltInfoRef);
            if(_loc3_)
            {
               this._packerExists = _loc3_.getPackerDownstreamOf(_loc2_.position);
            }
            this.applyWork(_loc2_,param1);
         }
         else
         {
            this.lookForItem();
         }
      }
      
      private function applyWork(param1:Item, param2:Number) : void
      {
         if(!this.itemWorkable(param1))
         {
            this.lookForItem();
            return;
         }
         if(Values.INTELIGENT_PACKING && this._packerExists && this.worker.type != "packer" && param1.state == Item.PACKING_STATE)
         {
            this.lookForItem();
            return;
         }
         var _loc3_:Number = this.getSkillOnItem(param1);
         param1.applyWork(_loc3_ * this.worker.skillTirednessMultiplier,param2,this.worker.cashBonusModifier);
      }
      
      private function lookForItem() : void
      {
         var _loc2_:Item = null;
         var _loc1_:Vector.<Entity> = engine.findByClass(Item);
         for each(_loc2_ in _loc1_)
         {
            if(this.itemWorkable(_loc2_))
            {
               if(!Values.INTELIGENT_PACKING)
               {
                  this.worker.currentItemRef = _loc2_.id;
                  this.worker.isWorking = true;
                  return;
               }
               if(!(this._packerExists && this.worker.type != "packer" && _loc2_.state == Item.PACKING_STATE))
               {
                  this.worker.currentItemRef = _loc2_.id;
                  this.worker.isWorking = true;
                  return;
               }
            }
         }
         this.worker.currentItemRef = null;
         this.worker.isWorking = false;
      }
      
      private function itemWorkable(param1:Item) : Boolean
      {
         return this.isInRange(param1) && (param1.state == Item.STITCHING_STATE || param1.state == Item.PACKING_STATE) && !param1.onNodeTile;
      }
      
      private function isInRange(param1:Item) : Boolean
      {
         return Utils.isNeighbouring(this.worker.position,param1.position);
      }
      
      private function getSkillOnItem(param1:Item) : Number
      {
         if(param1.state != Item.STITCHING_STATE)
         {
            return this.worker.skillPack + this.worker.skillModifier;
         }
         switch(param1.workType)
         {
            case EntityFactory.BAG:
               return this.worker.skillBag + this.worker.skillModifier;
            case EntityFactory.HAT:
               return this.worker.skillHat + this.worker.skillModifier;
            case EntityFactory.SHOES:
               return this.worker.skillShoes + this.worker.skillModifier;
            case EntityFactory.SHIRT:
               return this.worker.skillShirt + this.worker.skillModifier;
            default:
               return 0;
         }
      }
      
      private function get worker() : Worker
      {
         return entity as Worker;
      }
   }
}

