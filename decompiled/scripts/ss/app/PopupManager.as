package ss.app
{
   import org.fatlib.app.ScreenManager;
   import org.fatlib.events.CustomEvent;
   import ss.utils.Utils;
   
   public class PopupManager extends ScreenManager
   {
      
      public static var OPENED:String = "onPopupOpened";
      
      public static var CLOSED:String = "onPopupClosed";
      
      public function PopupManager()
      {
         super();
      }
      
      public function open(param1:String, param2:Object = null) : void
      {
         App.instance.screens.display.visible = false;
         goto(param1,param2);
         dispatchEvent(new CustomEvent(OPENED,{"name":param1}));
      }
      
      public function close() : void
      {
         App.instance.screens.display.visible = true;
         Utils.fadeFromBGColor(App.instance.screens.display);
         var _loc1_:String = currentScreenName;
         destroyScreen();
         dispatchEvent(new CustomEvent(CLOSED,{
            "name":_loc1_,
            "base":App.instance.screens.currentScreenName
         }));
      }
   }
}

