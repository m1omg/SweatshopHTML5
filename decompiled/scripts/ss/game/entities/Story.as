package ss.game.entities
{
   import flash.display.MovieClip;
   import ss.game.core.Entity;
   
   public class Story extends Entity
   {
      
      public static const CLIENT_SCENE:String = "client";
      
      public static const OUTRO_SCENE:String = "outro";
      
      public static const GAME:String = "game";
      
      public var context:String;
      
      public var mc:MovieClip;
      
      public function Story()
      {
         super();
      }
   }
}

