package ss.data
{
   import com.adobe.serialization.json.JSON;
   
   public class Stats
   {
      
      public var workersKilled:int = 0;
      
      public var workersInjured:int = 0;
      
      public var tiredWorkersRefreshed:int = 0;
      
      public var unitsHired:int = 0;
      
      public var unitsUpgraded:int = 0;
      
      public var featuresDeployed:int = 0;
      
      public var itemsCompleted:int = 0;
      
      public var typesHired:int = 0;
      
      public var childrenHated:int = 0;
      
      private var _deployed:Object;
      
      public function Stats()
      {
         super();
      }
      
      public static function fromObject(param1:Object) : Stats
      {
         var k:String = null;
         var o:Object = param1;
         var s:Stats = new Stats();
         for(k in o)
         {
            try
            {
               s[k] = o[k];
            }
            catch(e:Error)
            {
            }
         }
         return s;
      }
      
      public static function toObject(param1:Stats) : Object
      {
         return com.adobe.serialization.json.JSON.decode(com.adobe.serialization.json.JSON.encode(param1));
      }
      
      public function get workersDispatched() : int
      {
         return this.workersKilled + this.workersInjured;
      }
      
      public function get deployed() : Object
      {
         if(!this._deployed)
         {
            this._deployed = {};
         }
         return this._deployed;
      }
      
      public function addDeployed(param1:String) : void
      {
         if(!this._deployed)
         {
            this._deployed = {};
         }
         if(!this._deployed[param1])
         {
            this._deployed[param1] = 0;
         }
         ++this._deployed[param1];
      }
   }
}

