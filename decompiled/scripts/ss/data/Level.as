package ss.data
{
   import com.adobe.serialization.json.JSON;
   import org.fatlib.utils.ArrayUtils;
   import ss.Values;
   
   public class Level
   {
      
      public var key:String;
      
      public var world:int;
      
      public var musicTrack:String;
      
      public var fact:String;
      
      public var availableUnits:Array;
      
      public var newUnits:Array;
      
      public var mapData:Object;
      
      public var storyXML:XML;
      
      public var accidentRisk:Number = 0;
      
      public var accidentRiskSetting:int;
      
      public var skillModifier:Number = 0;
      
      public var staminaModifier:Number = 0;
      
      public var allowedRejections:int;
      
      public var startingCash:int;
      
      public var extraTime:int;
      
      public var mapWidth:int;
      
      public var mapHeight:int;
      
      public var tileWidth:int;
      
      public var tileHeight:int;
      
      public var objectScale:Number;
      
      public var beltHeight:Number;
      
      public var next:String;
      
      public var sceneBefore:String;
      
      public var sceneAfter:String;
      
      public var scoreFastFraction:Number;
      
      public var scoreProfitFraction:Number;
      
      public var numItems:int;
      
      public var slowestTime:Number;
      
      public var fastestTime:Number;
      
      public function Level(param1:String, param2:int)
      {
         super();
         this.world = param2;
         this.key = param1;
         var _loc3_:Object = Values.DIMENSIONS[param2];
         this.mapWidth = _loc3_["w"];
         this.mapHeight = _loc3_["h"];
         this.tileWidth = _loc3_["tw"];
         this.tileHeight = _loc3_["th"];
         this.objectScale = _loc3_["scale"];
         this.beltHeight = _loc3_["belt"];
      }
      
      public function toString() : String
      {
         return "[Level " + this.key + " " + com.adobe.serialization.json.JSON.encode(this) + "]";
      }
      
      public function getArea() : int
      {
         return this.mapWidth * this.mapHeight;
      }
      
      public function getAvailibility(param1:String) : Boolean
      {
         return ArrayUtils.contains(this.availableUnits,param1);
      }
      
      public function get title() : String
      {
         var _loc1_:String = this.storyXML.@title;
         if(!_loc1_)
         {
            _loc1_ = "[TITLE MISSING]";
         }
         return _loc1_;
      }
      
      public function get summary() : String
      {
         var _loc1_:String = this.storyXML.summary.children()[0];
         if(!_loc1_)
         {
            _loc1_ = "[SUMMARY MISSING]";
         }
         return _loc1_;
      }
   }
}

