package ss.remote
{
   import com.adobe.serialization.json.JSON;
   
   public class Shareable
   {
      
      public var type:String;
      
      public var id:String;
      
      public var imageFilestub:String;
      
      public var facebookCopy:String;
      
      public var twitterCopy:String;
      
      public function Shareable()
      {
         super();
      }
      
      public function toString() : String
      {
         return "[Shareable " + com.adobe.serialization.json.JSON.encode(this) + "]";
      }
   }
}

