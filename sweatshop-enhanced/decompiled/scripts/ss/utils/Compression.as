package ss.utils
{
   import com.dynamicflash.util.Base64;
   import flash.utils.ByteArray;
   
   public class Compression
   {
      
      public function Compression()
      {
         super();
      }
      
      public static function compress(param1:String) : String
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         _loc2_.compress();
         return Base64.encodeByteArray(_loc2_);
      }
      
      public static function uncompress(param1:String) : String
      {
         var _loc2_:ByteArray = Base64.decodeToByteArray(param1);
         _loc2_.uncompress();
         return _loc2_.toString();
      }
   }
}

