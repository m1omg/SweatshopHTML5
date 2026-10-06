package ss.data
{
   import org.fatlib.Log;
   import ss.Values;
   
   public class LevelResult
   {
      
      public static const UNFINISHED:String = "UNFINISHED";
      
      public static const WON:String = "WON";
      
      public static const LOST:String = "LOST";
      
      public var timeScore:Number;
      
      public var cashScore:Number;
      
      public var qualityScore:Number;
      
      public var isNewRecord:Boolean;
      
      private var _reason:String;
      
      private var _score:int = 0;
      
      private var _key:String;
      
      private var _state:String;
      
      public function LevelResult(param1:String)
      {
         super();
         this._key = param1;
         this._state = UNFINISHED;
      }
      
      public function get won() : Boolean
      {
         return this._state == WON;
      }
      
      public function get finished() : Boolean
      {
         return this._state != UNFINISHED;
      }
      
      public function markWon(param1:Number, param2:Number, param3:Number) : void
      {
         Log.log("[LevelResult] mark won");
         this._state = WON;
         this.timeScore = Math.ceil(param1 * Values.TIME_WEIGHT);
         this.cashScore = Math.ceil(param2 * Values.CASH_WEIGHT);
         this.qualityScore = Math.ceil(param3 * Values.QUALITY_WEIGHT);
         this._score = this.timeScore + this.cashScore + this.qualityScore;
      }
      
      public function markLost(param1:String) : void
      {
         Log.log("[LevelResult] mark lost");
         this._state = LOST;
         this._reason = param1;
      }
      
      public function toString() : String
      {
         return "[LevelResult " + this._state + "]";
      }
      
      public function get reason() : String
      {
         return this._reason;
      }
      
      public function get score() : int
      {
         return this._score;
      }
      
      public function get key() : String
      {
         return this._key;
      }
      
      public function get state() : String
      {
         return this._state;
      }
   }
}

