package ss.app
{
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   
   public class KarmaMeter
   {
      
      public function KarmaMeter()
      {
         super();
      }
      
      public static function configure(param1:MovieClip, param2:int) : void
      {
         var _loc3_:Rectangle = MovieClip(param1["bounds"]).getRect(param1);
         var _loc4_:MovieClip = param1["needle"];
         var _loc5_:int = int(App.instance.trophies.getKarmaRange()[0]);
         var _loc6_:int = int(App.instance.trophies.getKarmaRange()[1]);
         var _loc7_:int = _loc6_ - _loc5_;
         var _loc8_:Number = (param2 - _loc5_) / _loc7_;
         _loc4_.x = _loc3_.right - _loc3_.width * _loc8_;
      }
   }
}

