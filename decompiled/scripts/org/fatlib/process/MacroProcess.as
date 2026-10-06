package org.fatlib.process
{
   import flash.events.Event;
   import org.fatlib.interfaces.IProcess;
   
   public class MacroProcess extends AsyncProcess
   {
      
      protected var _processes:Array;
      
      protected var _currentProcess:IProcess;
      
      private var _autoExecute:Boolean = false;
      
      private var _autoContinue:Boolean = true;
      
      public function MacroProcess()
      {
         super();
         this._processes = [];
      }
      
      override public function execute() : void
      {
         this.startNextProcess();
      }
      
      public function addProcess(param1:IProcess) : void
      {
         this._processes.push(param1);
         if(this._processes.length == 1 && this._autoExecute)
         {
            this.execute();
         }
      }
      
      override public function destroy() : void
      {
         var _loc1_:IProcess = null;
         for each(_loc1_ in this._processes)
         {
            _loc1_.destroy();
         }
      }
      
      public function get autoContinue() : Boolean
      {
         return this._autoContinue;
      }
      
      public function set autoContinue(param1:Boolean) : void
      {
         this._autoContinue = param1;
      }
      
      public function get autoExecute() : Boolean
      {
         return this._autoExecute;
      }
      
      public function set autoExecute(param1:Boolean) : void
      {
         this._autoExecute = param1;
      }
      
      private function startNextProcess() : void
      {
         var _loc1_:AsyncProcess = null;
         if(this._processes.length == 0)
         {
            done();
            return;
         }
         this._currentProcess = this._processes[0] as IProcess;
         if(this._currentProcess is AsyncProcess)
         {
            _loc1_ = this._currentProcess as AsyncProcess;
            _loc1_.addEventListener(Event.COMPLETE,this.onSubprocessComplete);
            _loc1_.execute();
         }
         else
         {
            this._currentProcess.execute();
            this.subprocessComplete();
         }
      }
      
      private function onSubprocessComplete(param1:Event) : void
      {
         this.subprocessComplete();
      }
      
      private function subprocessComplete() : void
      {
         this.killCurrentProcess();
         this._processes.shift();
         if(this._autoContinue)
         {
            this.startNextProcess();
         }
      }
      
      private function killCurrentProcess() : void
      {
         var _loc1_:AsyncProcess = null;
         if(!this._currentProcess)
         {
            return;
         }
         if(this._currentProcess is AsyncProcess)
         {
            _loc1_ = this._currentProcess as AsyncProcess;
            _loc1_.removeEventListener(Event.COMPLETE,this.onSubprocessComplete);
            _loc1_.destroy();
         }
         this._currentProcess = null;
      }
   }
}

