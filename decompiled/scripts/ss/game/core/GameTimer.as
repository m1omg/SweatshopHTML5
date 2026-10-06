package ss.game.core
{
   public class GameTimer
   {
      
      private var _running:Boolean;
      
      private var _realElapsed:Number = 0;
      
      private var _elapsed:Number = 0;
      
      public function GameTimer()
      {
         super();
      }
      
      public function update(param1:Number) : void
      {
         if(this._running)
         {
            this._elapsed += param1;
         }
         this._realElapsed += param1;
      }
      
      public function start() : void
      {
         this._running = true;
      }
      
      public function stop() : void
      {
         this._running = false;
      }
      
      public function get running() : Boolean
      {
         return this._running;
      }
      
      public function get realElapsed() : Number
      {
         return this._realElapsed;
      }
      
      public function get elapsed() : Number
      {
         return this._elapsed;
      }
   }
}

