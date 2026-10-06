package ss.app.screens
{
   import org.fatlib.app.Screen;
   import org.fatlib.events.CustomEvent;
   import ss.app.App;
   import ss.app.GlobalUI;
   
   public class BasePopup extends Screen
   {
      
      public function BasePopup()
      {
         super();
         App.instance.globalUI.addEventListener(GlobalUI.ACTION,this.onGlobalUIAction);
      }
      
      override public function destroy() : void
      {
         App.instance.globalUI.removeEventListener(GlobalUI.ACTION,this.onGlobalUIAction);
         super.destroy();
      }
      
      private function onGlobalUIAction(param1:CustomEvent) : void
      {
         if(param1.data.action == "back")
         {
            App.instance.popups.close();
         }
      }
   }
}

