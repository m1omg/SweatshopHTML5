package ss.app.process
{
   import flash.net.URLLoader;
   import org.fatlib.Log;
   import org.fatlib.process.SyncProcess;
   import ss.app.App;
   
   public class ConfigureRemoteProcess extends SyncProcess
   {
      
      private var _loader:URLLoader;
      
      public function ConfigureRemoteProcess()
      {
         super();
      }
      
      override public function execute() : void
      {
         Log.log("[ConfigureRemoteProcess] execute");
         App.instance.tracking.init();
         App.instance.social.init();
      }
   }
}

