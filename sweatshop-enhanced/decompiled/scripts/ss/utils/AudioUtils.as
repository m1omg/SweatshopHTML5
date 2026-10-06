package ss.utils
{
   import ss.app.App;
   
   public class AudioUtils
   {
      
      public function AudioUtils()
      {
         super();
      }
      
      public static function uiClick() : void
      {
         App.instance.audio.trigger("UI_CLICK_2");
      }
      
      public static function uiOpen() : void
      {
         App.instance.audio.trigger("UI_CLICK_3");
      }
      
      public static function uiClose() : void
      {
         App.instance.audio.trigger("UI_CLICK_2");
      }
      
      public static function uiNav() : void
      {
         App.instance.audio.trigger("UI_CLICK_2");
      }
      
      public static function uiConfirm() : void
      {
         App.instance.audio.trigger("UI_CLICK_1");
      }
      
      public static function uiYes() : void
      {
         App.instance.audio.trigger("UI_CLICK_2");
      }
      
      public static function uiNo() : void
      {
         App.instance.audio.trigger("UI_CLICK_2");
      }
   }
}

