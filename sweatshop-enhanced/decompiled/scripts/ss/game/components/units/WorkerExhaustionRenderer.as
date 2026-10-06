package ss.game.components.units
{
   import flash.display.MovieClip;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.Entity;
   import ss.game.core.Renderer;
   import ss.game.entities.Worker;
   
   public class WorkerExhaustionRenderer extends Renderer
   {
      
      private var _mc:MovieClip;
      
      private var _exhausted:Boolean;
      
      private var _oldSecondsLeft:int;
      
      public function WorkerExhaustionRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         positionMode = TILE_BASED_POSITION;
         this._mc = App.instance.resources.instantiateMovieClip("hud","UnitExhaustionCounterSymbol");
         this._mc.scaleX = this._mc.scaleY = Game.level.objectScale;
         if(this.worker.type == "child")
         {
            this._mc.y += 10 * Game.level.objectScale;
         }
         addElement(this._mc).depth = DepthManager.getDepth(DepthManager.ITEM_PROGRESS_BAR);
         this._mc.stop();
         this._mc.visible = false;
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Entity.ON_STATE_CHANGED:
               this._exhausted = entity.state == Worker.EXHAUSTED_STATE;
               if(!this._exhausted)
               {
                  this._mc.stop();
                  this._mc.visible = false;
               }
               else
               {
                  this._mc.visible = true;
                  this._oldSecondsLeft = -1;
               }
         }
      }
      
      override public function render() : void
      {
         if(!this._exhausted)
         {
            return;
         }
         var _loc1_:int = Math.ceil(this.worker.dieFromExhaustionTime - engine.timer.elapsed);
         if(_loc1_ != this._oldSecondsLeft)
         {
            this._mc["digit"]["label"].text = _loc1_;
            this._mc.gotoAndPlay(1);
            this._oldSecondsLeft = _loc1_;
         }
         offset = this.worker.renderOffset.clone();
         super.render();
      }
      
      private function get worker() : Worker
      {
         return entity as Worker;
      }
   }
}

