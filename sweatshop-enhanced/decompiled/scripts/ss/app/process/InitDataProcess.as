package ss.app.process
{
   import org.fatlib.Log;
   import org.fatlib.process.SyncProcess;
   import ss.app.App;
   
   public class InitDataProcess extends SyncProcess
   {
      
      public function InitDataProcess()
      {
         super();
      }
      
      override public function execute() : void
      {
         Log.log("[InitDataProcess] execute");
         App.instance.trophies.init(App.instance.data.trophies);
         App.instance.levels.init(App.instance.data.levels);
         App.instance.audio.init(App.instance.data.sfx,App.instance.data.music);
         App.instance.karma.init(App.instance.data.karma);
      }
   }
}

