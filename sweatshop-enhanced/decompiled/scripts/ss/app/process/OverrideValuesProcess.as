package ss.app.process
{
   import org.fatlib.Log;
   import org.fatlib.process.SyncProcess;
   import ss.Values;
   import ss.app.App;
   
   public class OverrideValuesProcess extends SyncProcess
   {
      
      public function OverrideValuesProcess()
      {
         super();
      }
      
      override public function execute() : void
      {
         var values:Object;
         var k:String = null;
         var v:* = undefined;
         Log.log("[OverrideValuesProcess] execute");
         values = App.instance.data["values"];
         for(k in values)
         {
            v = values[k];
            try
            {
               Values[k] = v;
               Log.log("[OverrideValuesProcess] Overriding " + k + " with " + v);
            }
            catch(r:Error)
            {
               Log.error("[OverrideValuesProcess] Couldn\'t override a value called " + k);
            }
         }
      }
   }
}

