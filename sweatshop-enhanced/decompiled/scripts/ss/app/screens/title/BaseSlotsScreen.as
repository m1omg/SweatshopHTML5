package ss.app.screens.title
{
   import flash.display.MovieClip;
   import org.fatlib.app.Screen;
   
   public class BaseSlotsScreen extends Screen
   {
      
      public function BaseSlotsScreen()
      {
         super();
      }
      
      public function get mc() : MovieClip
      {
         return (manager as SlotsScreenManager).mc[screenName];
      }
      
      public function get slotsManager() : SlotsScreenManager
      {
         return manager as SlotsScreenManager;
      }
   }
}

