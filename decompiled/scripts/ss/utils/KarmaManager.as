package ss.utils
{
   import ss.Constants;
   import ss.data.KarmaRank;
   import ss.remote.Shareable;
   
   public class KarmaManager
   {
      
      private var _ranks:Array;
      
      public function KarmaManager()
      {
         super();
      }
      
      public static function hasGoodEnding(param1:int) : Boolean
      {
         return param1 >= -1;
      }
      
      public function init(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:KarmaRank = null;
         this._ranks = [];
         for each(_loc2_ in param1)
         {
            _loc3_ = new KarmaRank();
            _loc3_.shareable = new Shareable();
            _loc3_.shareable.id = _loc2_["key"];
            _loc3_.shareable.type = Constants.SHAREABLE_KARMA;
            _loc3_.shareable.facebookCopy = _loc2_["facebook_copy"];
            _loc3_.shareable.twitterCopy = _loc2_["twitter_copy"];
            _loc3_.shareable.imageFilestub = _loc2_["key"];
            _loc3_.title = _loc2_["title"];
            _loc3_.key = _loc2_["key"];
            _loc3_.min = _loc2_["min"];
            _loc3_.max = _loc2_["max"];
            this._ranks.push(_loc3_);
         }
      }
      
      public function getRank(param1:int) : KarmaRank
      {
         var _loc2_:KarmaRank = null;
         for each(_loc2_ in this._ranks)
         {
            if(param1 >= _loc2_.min && param1 <= _loc2_.max)
            {
               return _loc2_;
            }
         }
         return null;
      }
   }
}

