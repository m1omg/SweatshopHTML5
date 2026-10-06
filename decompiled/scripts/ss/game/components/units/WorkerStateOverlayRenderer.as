package ss.game.components.units
{
   import flash.display.MovieClip;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.Animation;
   import ss.game.core.Entity;
   import ss.game.core.VisualElement;
   import ss.game.entities.Unit;
   import ss.game.entities.Worker;
   
   public class WorkerStateOverlayRenderer extends Animation
   {
      
      private var _mc:MovieClip;
      
      private var _vis:VisualElement;
      
      private var _tired:MovieClip;
      
      public function WorkerStateOverlayRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         super.prepare();
         positionMode = TILE_BASED_POSITION;
         this._mc = new MovieClip();
         this._mc.scaleX = this._mc.scaleY = Game.level.objectScale;
         this._tired = App.instance.resources.instantiateMovieClip("hud","UnitOverlayTiredSymbol");
         this._tired.name = Worker.TIRED_STATE;
         this._tired.stop();
         this._tired.visible = false;
         this._mc.addChild(this._tired);
         this._vis = addElement(this._mc);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         super.receiveMessage(param1,param2);
         switch(param1)
         {
            case Entity.ON_STATE_CHANGED:
               if(entity.state == Worker.EXHAUSTED_STATE || entity.state == Worker.TIRED_STATE)
               {
                  this.show(entity.state);
                  break;
               }
               this.hide();
         }
      }
      
      override public function render() : void
      {
         offset = (entity as Unit).renderOffset.clone();
         this._vis.depth = DepthManager.getDepth(DepthManager.WORKER_EFFECT,entity.position,offset);
         super.render();
      }
      
      override protected function handlePaused() : void
      {
         this._tired.stop();
      }
      
      override protected function handleUnpaused() : void
      {
         if(entity.state == Worker.TIRED_STATE)
         {
            this._tired.play();
         }
      }
      
      private function hide() : void
      {
         this._tired.stop();
         this._mc.visible = false;
      }
      
      private function show(param1:String) : void
      {
         switch(param1)
         {
            case Worker.EXHAUSTED_STATE:
               this._mc.visible = true;
               this._tired.visible = false;
               this._tired.stop();
               break;
            case Worker.TIRED_STATE:
               this._mc.visible = true;
               this._tired.visible = true;
               this._tired.play();
               break;
            default:
               this._mc.visible = false;
               this._tired.visible = false;
               this._tired.stop();
         }
      }
   }
}

