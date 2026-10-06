package ss.utils
{
   import ss.Constants;
   import ss.Values;
   
   public class ScoreUtils
   {
      
      public function ScoreUtils()
      {
         super();
      }
      
      public static function getMedal(param1:int) : String
      {
         var _loc2_:String = Constants.GOLD_MEDAL;
         if(param1 < Values.SILVER_PERCENT)
         {
            _loc2_ = Constants.BRONZE_MEDAL;
         }
         else if(param1 < Values.GOLD_PERCENT)
         {
            _loc2_ = Constants.SILVER_MEDAL;
         }
         return _loc2_;
      }
   }
}

