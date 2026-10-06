package ss.game.entities
{
   import org.fatlib.interfaces.IIterable;
   import org.fatlib.interfaces.IIterator;
   import org.fatlib.iterators.ArrayIterator;
   import ss.game.core.Entity;
   import ss.game.data.SequenceElement;
   
   public class Sequence extends Entity implements IIterable
   {
      
      public var beltRef:String;
      
      public var nextItemType:String;
      
      public var nextItemTimeProgress:Number;
      
      public var itemsRemaining:int;
      
      private var _elements:Array;
      
      public function Sequence()
      {
         super();
      }
      
      override public function prepare() : void
      {
         this._elements = [];
      }
      
      public function get length() : int
      {
         return this._elements.length;
      }
      
      public function getElement(param1:int) : SequenceElement
      {
         return this._elements[param1];
      }
      
      public function addElement(param1:SequenceElement) : void
      {
         var _loc2_:SequenceElement = new SequenceElement();
         this._elements.push(param1);
      }
      
      public function addElementAt(param1:SequenceElement, param2:int) : void
      {
         this._elements.splice(param2,0,param1);
      }
      
      public function removeElementAt(param1:int) : void
      {
         this._elements.splice(param1,1);
      }
      
      public function duplicate(param1:int) : void
      {
         this.addElementAt(this.getElement(param1).clone() as SequenceElement,param1);
      }
      
      public function swap(param1:int, param2:int) : void
      {
         var _loc3_:SequenceElement = this.getElement(param1);
         this._elements[param1] = this.getElement(param2);
         this._elements[param2] = _loc3_;
      }
      
      public function moveElementUp(param1:int) : Boolean
      {
         if(param1 > 0)
         {
            this.swap(param1,param1 - 1);
            return true;
         }
         return false;
      }
      
      public function moveElementDown(param1:int) : Boolean
      {
         if(param1 < this._elements.length - 1)
         {
            this.swap(param1,param1 + 1);
            return true;
         }
         return false;
      }
      
      public function getLastItemTime() : Number
      {
         var _loc3_:SequenceElement = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._elements.length)
         {
            _loc3_ = this._elements[_loc2_];
            _loc1_ += _loc3_.predelay;
            _loc1_ += (_loc3_.amount - 1) * _loc3_.interval;
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getItemCount() : int
      {
         var _loc3_:SequenceElement = null;
         var _loc1_:int = 0;
         var _loc2_:IIterator = this.getIterator();
         while(_loc2_.hasNext)
         {
            _loc3_ = _loc2_.next;
            _loc1_ += _loc3_.amount;
         }
         return _loc1_;
      }
      
      public function getIterator() : IIterator
      {
         return new ArrayIterator(this._elements);
      }
      
      public function hasItem(param1:String) : Boolean
      {
         var _loc2_:IIterator = this.getIterator();
         while(_loc2_.hasNext)
         {
            if((_loc2_.next as SequenceElement).type == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function save() : Object
      {
         return this._elements;
      }
      
      public function load(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:SequenceElement = null;
         var _loc4_:String = null;
         this._elements = [];
         for each(_loc2_ in param1 as Array)
         {
            _loc3_ = new SequenceElement();
            for(_loc4_ in _loc2_)
            {
               _loc3_[_loc4_] = _loc2_[_loc4_];
            }
            this._elements.push(_loc3_);
         }
      }
   }
}

