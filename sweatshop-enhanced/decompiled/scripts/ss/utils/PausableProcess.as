package ss.utils
{
   import org.fatlib.process.AsyncProcess;
   
   public class PausableProcess extends AsyncProcess implements IPausable
   {
      
      public function PausableProcess()
      {
         super();
      }
      
      public function pause() : void
      {
      }
      
      public function unpause() : void
      {
      }
   }
}

