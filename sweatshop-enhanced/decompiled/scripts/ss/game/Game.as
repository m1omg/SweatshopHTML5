package ss.game
{
   import org.fatlib.assets.ResourceBank;
   import ss.data.Level;
   import ss.data.LevelResult;
   import ss.data.Stats;
   import ss.game.core.Canvas;
   import ss.game.core.Engine;
   import ss.game.core.Messenger;
   import ss.game.data.Shop;
   import ss.game.data.User;
   import ss.game.factory.EntityFactory;
   import ss.story.StoryEngine;
   
   public class Game
   {
      
      public static var engine:Engine;
      
      public static var level:Level;
      
      public static var factory:EntityFactory;
      
      public static var canvas:Canvas;
      
      public static var messenger:Messenger;
      
      public static var user:User;
      
      public static var shop:Shop;
      
      public static var resources:ResourceBank;
      
      public static var story:StoryEngine;
      
      public static var stats:Stats;
      
      public static var result:LevelResult;
      
      public function Game()
      {
         super();
      }
   }
}

