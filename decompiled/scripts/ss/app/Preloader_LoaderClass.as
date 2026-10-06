package ss.app
{
   import flash.display.DisplayObject;
   import mx.core.SpriteAsset;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol32")]
   public class Preloader_LoaderClass extends SpriteAsset
   {
      
      public var clip:DisplayObject;
      
      public var label:DisplayObject;
      
      public function Preloader_LoaderClass()
      {
         super();
      }
   }
}

