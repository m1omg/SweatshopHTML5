package ss.game.core
{
   public class ThinkingComponent extends Component
   {
      
      public var interval:Number;
      
      private var _nextThinkTime:Number;
      
      private var _first:Boolean = true;
      
      public function ThinkingComponent()
      {
         super();
      }
      
      final override public function update(param1:Number) : void
      {
         if(this._first || engine.timer.elapsed > this._nextThinkTime)
         {
            this._first = false;
            this.think();
            this._nextThinkTime = engine.timer.elapsed + this.interval;
         }
      }
      
      protected function think() : void
      {
      }
   }
}

