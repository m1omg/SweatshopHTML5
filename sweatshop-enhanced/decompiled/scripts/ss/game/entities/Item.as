package ss.game.entities
{
   import flash.geom.Point;
   import ss.Values;
   
   public class Item extends MapEntity
   {
      
      public static const STITCHING_STATE:String = "STITCHING_STATE";
      
      public static const PACKING_STATE:String = "PACKING_STATE";
      
      public static const DONE_STATE:String = "DONE_STATE";
      
      public var workComplexity:Number;
      
      public var workProgress:Number;
      
      public var workType:String;
      
      public var cashBonus:int;
      
      public var onNodeTile:Boolean;
      
      public var tileEntryPoint:Point;
      
      public var tileExitPoint:Point;
      
      public var tileProgress:Number;
      
      public var tileCount:int;
      
      public var direction:String;
      
      public var beltRef:String;
      
      public function Item()
      {
         super();
      }
      
      override public function prepare() : void
      {
         this.workProgress = 0;
         this.tileProgress = 0;
         this.cashBonus = 0;
         renderOffset = new Point();
         this.tileEntryPoint = new Point();
         this.tileExitPoint = new Point();
         flammability = Values.ITEM_FLAMMABILITY;
         changeState(STITCHING_STATE);
         this.tileCount = 0;
         this.direction = "";
      }
      
      public function applyWork(param1:Number, param2:Number, param3:Number = 0) : void
      {
         if(this.workProgress >= this.workComplexity)
         {
            return;
         }
         this.cashBonus = param3;
         this.workProgress += param1 * param2;
         if(this.workProgress >= this.workComplexity)
         {
            this.workProgress = this.workComplexity;
            changeState(DONE_STATE);
         }
         if(state == STITCHING_STATE && this.workProgress > Values.STITCH_FRACTION * this.workComplexity)
         {
            changeState(PACKING_STATE);
         }
      }
   }
}

