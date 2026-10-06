package ss.app.process
{
   import com.adobe.serialization.json.JSON;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import org.fatlib.Log;
   import org.fatlib.process.AsyncProcess;
   import ss.Values;
   import ss.app.App;
   
   public class GetRemoteDataProcess extends AsyncProcess
   {
      
      private var _loader:URLLoader;
      
      public function GetRemoteDataProcess()
      {
         super();
      }
      
      override public function execute() : void
      {
         var _loc1_:String = null;
         Log.log("[GetRemoteDataProcess] execute");
         if(Values.SINGLE_LEVEL_MODE)
         {
            App.instance.session.currentLevelKey = App.instance.flashvars["level"];
         }
         if(Values.IS_LOCAL)
         {
            _loc1_ = "http://littleloud.com/live/sweatshop/editor/data.json.txt";
         }
         else
         {
            _loc1_ = "../data.json.txt";
         }
         if(App.instance.flashvars["src"])
         {
            _loc1_ = App.instance.flashvars["src"];
         }
         Log.log("[GetRemoteDataProcess] url=" + _loc1_);
         this._loader = new URLLoader();
         this._loader.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
         this._loader.addEventListener(Event.COMPLETE,this.onComplete);
         this._loader.load(new URLRequest(_loc1_));
      }
      
      private function onError(param1:IOErrorEvent) : void
      {
         this._loader.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
         this._loader.removeEventListener(Event.COMPLETE,this.onComplete);
         Log.error(param1);
      }
      
      private function onComplete(param1:Event) : void
      {
         var d:String = null;
         var e:Event = param1;
         Log.log("[GetRemoteDataProcess] loaded");
         this._loader.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
         this._loader.removeEventListener(Event.COMPLETE,this.onComplete);
         d = this._loader.data;
         try
         {
            App.instance.data = com.adobe.serialization.json.JSON.decode(this._loader.data);
            Log.log("[GetRemoteDataProcess] metadata:" + com.adobe.serialization.json.JSON.encode(App.instance.data["metadata"]));
         }
         catch(r:Error)
         {
            throw new Error("Invalid JSON:" + d.substr(0,40) + "...");
         }
         this._loader = null;
         done();
      }
   }
}

