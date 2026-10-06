package ss.game.components
{
   import org.fatlib.interfaces.IIterator;
   import ss.Values;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.data.SequenceElement;
   import ss.game.entities.Belt;
   import ss.game.entities.Sequence;
   
   public class SequencerController extends Component
   {
      
      private var _dualBelts:Boolean;
      
      public var beltNum:int = 1;
      
      private var _items:Array;
      
      private var _nextDispatchTime:Number;
      
      private var _adjustedAge:Number;
      
      private var _lastBroadcastTime:int;
      
      private var _currentInterval:Number;
      
      public function SequencerController()
      {
         super();
      }
      
      override public function prepare() : void
      {
         var _loc2_:SequenceElement = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         this._dualBelts = parseInt(Game.level.key) >= 20;
         var _loc1_:IIterator = this.sequence.getIterator();
         this._items = [];
         while(_loc1_.hasNext)
         {
            _loc2_ = _loc1_.next;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.amount)
            {
               _loc4_ = {"type":_loc2_.type};
               if(_loc3_ == 0)
               {
                  _loc4_["delay"] = _loc2_.predelay;
               }
               else
               {
                  _loc4_["delay"] = _loc2_.interval;
               }
               this._items.push(_loc4_);
               _loc3_++;
            }
         }
         this._adjustedAge = 0;
         if(this._items.length > 0)
         {
            this._nextDispatchTime = this._items[0]["delay"];
            this._currentInterval = this._nextDispatchTime;
         }
         this.sequence.itemsRemaining = this._items.length;
      }
      
      override public function update(param1:Number) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         this.sequence.itemsRemaining = this._items.length;
         if(this._items.length == 0)
         {
            return;
         }
         var _loc2_:Belt = engine.resolveReference(this.sequence.beltRef);
         if(!_loc2_)
         {
            return;
         }
         this._adjustedAge += param1 * (_loc2_.speed / Values.SLOW_BELT_SPEED);
         if(this._adjustedAge > this._nextDispatchTime)
         {
            _loc3_ = this._items.shift();
            _loc4_ = _loc3_["type"];
            if(this._dualBelts)
            {
               this.beltNum = 3 - this.beltNum;
            }
            Game.factory.createItem(_loc4_,_loc2_.startNodes[this.beltNum].x,_loc2_.startNodes[this.beltNum].y);
            Game.messenger.broadcast(Messages.ITEM_SPAWNED,{"type":_loc4_});
            if(this._items.length > 0)
            {
               this._nextDispatchTime = this._adjustedAge + this._items[0]["delay"];
               this._currentInterval = this._nextDispatchTime - this._adjustedAge;
            }
         }
         if(this._items.length > 0)
         {
            this.sequence.nextItemType = this._items[0]["type"];
            this.sequence.nextItemTimeProgress = (this._nextDispatchTime - this._adjustedAge) / this._currentInterval;
         }
         else
         {
            this.sequence.nextItemType = null;
         }
      }
      
      private function get sequence() : Sequence
      {
         return entity as Sequence;
      }
   }
}

