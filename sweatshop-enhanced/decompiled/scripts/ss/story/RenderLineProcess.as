package ss.story
{
   import flash.events.Event;
   import ss.utils.PausableProcess;
   
   public class RenderLineProcess extends PausableProcess
   {
      
      private var _dialogText:DialogTextController;
      
      private var _line:XML;
      
      public function RenderLineProcess(param1:DialogTextController, param2:XML)
      {
         super();
         this._dialogText = param1;
         this._dialogText.addEventListener(Event.COMPLETE,this.onComplete);
         this._line = param2;
      }
      
      override public function pause() : void
      {
         this._dialogText.pause();
      }
      
      override public function unpause() : void
      {
         this._dialogText.unpause();
      }
      
      override public function execute() : void
      {
         super.execute();
         this._dialogText.renderLine(this._line);
      }
      
      private function onComplete(param1:Event) : void
      {
         done();
      }
      
      override public function destroy() : void
      {
         this._dialogText.removeEventListener(Event.COMPLETE,this.onComplete);
         super.destroy();
      }
   }
}

