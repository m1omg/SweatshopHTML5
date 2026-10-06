package ss.data
{
   import ss.Constants;
   import ss.utils.ScoreUtils;
   
   public class LevelState
   {
      
      public var hasWon:Boolean = false;
      
      public var unlocked:Boolean = false;
      
      public var hasRead:Boolean = false;
      
      public var score:int = 0;
      
      public function LevelState()
      {
         super();
      }
      
      public function encode() : Object
      {
         return {
            "unlocked":this.unlocked,
            "score":this.score,
            "hasWon":this.hasWon,
            "hasRead":this.hasRead
         };
      }
      
      public function decode(param1:Object) : void
      {
         this.unlocked = param1["unlocked"];
         this.score = param1["score"];
         this.hasRead = param1["hasRead"];
         this.hasWon = param1["hasWon"];
      }
      
      public function get medal() : String
      {
         var _loc1_:String = Constants.NO_MEDAL;
         if(this.hasWon)
         {
            _loc1_ = ScoreUtils.getMedal(this.score);
         }
         return _loc1_;
      }
   }
}

