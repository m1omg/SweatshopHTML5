package ss.app.process
{
   import com.adobe.serialization.json.JSON;
   import org.fatlib.process.SyncProcess;
   import ss.app.App;
   
   public class GetLocalDataProcess extends SyncProcess
   {
      
      private var _d:Class = GetLocalDataProcess__d;
      
      public function GetLocalDataProcess()
      {
         super();
      }
      
      override public function execute() : void
      {
         App.instance.data = com.adobe.serialization.json.JSON.decode(new this._d());
      }
   }
}

