package ss.app.process
{
   import org.fatlib.Log;
   import org.fatlib.process.SyncProcess;
   import ss.Constants;
   import ss.Values;
   import ss.app.App;
   
   public class ConfigureContextProcess extends SyncProcess
   {
      
      public function ConfigureContextProcess()
      {
         super();
      }
      
      override public function execute() : void
      {
         Values.CURRENT_URL = App.instance.stage.loaderInfo.url.toLowerCase();
         Values.IS_LOCAL = Values.CURRENT_URL.indexOf("file") == 0;
         Values.IS_LIVE = Values.CURRENT_URL.indexOf("playsweatshop.com") != -1;
         if(Constants.FORCE_LIVE)
         {
            Values.IS_LIVE = true;
            Values.IS_LOCAL = false;
            Values.DEBUG_MODE = false;
            Log.ALLOW_LOGGING = false;
            return;
         }
         if(Values.IS_LOCAL || !Values.IS_LIVE && App.instance.flashvars["debug"] == "true")
         {
            Values.DEBUG_MODE = true;
         }
         Log.ALLOW_LOGGING = Values.DEBUG_MODE;
         Log.log("[ConfigureContextProcess] CURRENT_URL=" + Values.CURRENT_URL + ", IS_LOCAL=" + Values.IS_LOCAL + ", IS_LIVE=" + Values.IS_LIVE);
      }
   }
}

