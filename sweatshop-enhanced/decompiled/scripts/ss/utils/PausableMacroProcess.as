package ss.utils
{
   import org.fatlib.interfaces.IProcess;
   import org.fatlib.process.MacroProcess;
   
   public class PausableMacroProcess extends MacroProcess implements IPausable
   {
      
      public function PausableMacroProcess()
      {
         super();
      }
      
      override public function addProcess(param1:IProcess) : void
      {
         super.addProcess(param1);
      }
      
      public function pause() : void
      {
         if(_currentProcess is IPausable)
         {
            (_currentProcess as IPausable).pause();
         }
      }
      
      public function unpause() : void
      {
         if(_currentProcess is IPausable)
         {
            (_currentProcess as IPausable).unpause();
         }
      }
   }
}

