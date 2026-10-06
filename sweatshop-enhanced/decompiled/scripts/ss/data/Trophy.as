package ss.data
{
   import ss.remote.Shareable;
   
   public class Trophy
   {
      
      public var id:String;
      
      public var name:String;
      
      public var description:String;
      
      public var karma:int;
      
      public var requirements:Object;
      
      public var context:String;
      
      public var shareable:Shareable;
      
      public var vanillaCopy:String;
      
      public function Trophy()
      {
         super();
      }
      
      public function toString() : String
      {
         return "[Trophy " + this.id + ": \"" + this.name + "\"]";
      }
      
      public function get karmaHTMLText() : String
      {
         var _loc1_:String = "";
         switch(this.karma)
         {
            case 1:
               _loc1_ = "GOOD+";
               break;
            case 2:
               _loc1_ = "GOOD++";
               break;
            case 3:
               _loc1_ = "GOOD+++";
               break;
            case 4:
               _loc1_ = "GOOD+++";
               break;
            case -1:
               _loc1_ = "EVIL+";
               break;
            case -2:
               _loc1_ = "EVIL++";
               break;
            case -3:
               _loc1_ = "EVIL+++";
               break;
            case -4:
               _loc1_ = "EVIL+++";
         }
         if(this.karma < 0)
         {
            _loc1_ = "<font color=\"#EC4643\">" + _loc1_ + "</font>";
         }
         else if(this.karma > 0)
         {
            _loc1_ = "<font color=\"#FFFFFF\">" + _loc1_ + "</font>";
         }
         return _loc1_;
      }
   }
}

