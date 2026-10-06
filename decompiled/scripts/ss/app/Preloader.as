package ss.app
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.utils.getDefinitionByName;
   import org.fatlib.utils.DisplayUtils;
   import ss.utils.ContextMenuUtils;
   
   [SWF(width="700", height="545", backgroundColor="#c0c0c0", frameRate="25")]
   public class Preloader extends MovieClip
   {
      
      private var LoaderClass:Class = Preloader_LoaderClass;
      
      private var _mc:DisplayObject;
      
      public function Preloader()
      {
         super();
         if(stage)
         {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            ContextMenuUtils.init(this);
         }
         addEventListener(Event.ENTER_FRAME,this.checkFrame);
         loaderInfo.addEventListener(ProgressEvent.PROGRESS,this.progress);
         loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.ioError);
         this._mc = new this.LoaderClass();
         addChild(this._mc);
      }
      
      private function ioError(param1:IOErrorEvent) : void
      {
      }
      
      private function progress(param1:ProgressEvent) : void
      {
         var _loc2_:int = int(stage.loaderInfo.bytesLoaded);
         var _loc3_:int = stage.loaderInfo.parameters.hasOwnProperty("swfTotalBytes") ? int(Number(stage.loaderInfo.parameters.swfTotalBytes)) : int(stage.loaderInfo.bytesTotal);
         var _loc4_:Number = Math.floor(100 * _loc2_ / _loc3_);
         this._mc["clip"].gotoAndStop(_loc4_);
         this._mc["label"].text = _loc4_ + "%";
      }
      
      private function checkFrame(param1:Event) : void
      {
         if(currentFrame == totalFrames)
         {
            stop();
            this.loadingFinished();
         }
      }
      
      private function loadingFinished() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.checkFrame);
         loaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.progress);
         loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.ioError);
         DisplayUtils.recursiveStop(this._mc);
         removeChild(this._mc);
         this.startup();
      }
      
      private function startup() : void
      {
         var _loc1_:Class = getDefinitionByName("ss.app.Main") as Class;
         addChild(new _loc1_() as DisplayObject);
      }
   }
}

