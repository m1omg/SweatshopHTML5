package ss.utils
{
   import org.fatlib.process.AsyncProcess;
   import org.fatlib.utils.Delay;
   
   public class DelayProcess extends AsyncProcess
   {
      
      private var _interval:int;
      
      private var _delay:Delay;
      
      public function DelayProcess(param1:int)
      {
         super();
         this._interval = param1;
      }
      
      override public function execute() : void
      {
         this._delay = new Delay();
         this._delay.create(this._interval,this.delayDone);
      }
      
      private function delayDone() : void
      {
         this._delay.destroy();
         done();
      }
      
      override public function destroy() : void
      {
         if(this._delay)
         {
            this._delay.destroy();
         }
      }
   }
}

