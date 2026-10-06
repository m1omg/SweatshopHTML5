package ss.game.components
{
   import flash.display.MovieClip;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.Animation;
   import ss.game.core.Entity;
   import ss.game.core.VisualElement;
   import ss.game.entities.Feature;
   import ss.utils.MouseHandlers;
   import ss.utils.Utils;
   
   public class FeatureRenderer extends Animation
   {
      
      private var _mc:MovieClip;
      
      private var _vis:VisualElement;
      
      public function FeatureRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         positionMode = TILE_BASED_POSITION;
         var _loc1_:String = Utils.getFeatureSymbol(this.feature.key);
         this._mc = App.instance.resources.instantiateMovieClip("features",_loc1_);
         this._mc.scaleX = this._mc.scaleY = Game.level.objectScale;
         this._vis = addElement(this._mc);
         this._vis.depth = DepthManager.getDepth(DepthManager.WORKER_BOT,entity.position);
         if(this.feature.isAmbient)
         {
            this._mc["down"].visible = false;
            this._mc["up"].visible = true;
         }
         else
         {
            this._mc["down"].visible = true;
            this._mc["up"].visible = false;
            this._mc["up"].stop();
         }
         this._mc["hit"].alpha = 0;
         MouseHandlers.add(this._vis,entity.id);
         super.prepare();
      }
      
      override public function destroy() : void
      {
         MouseHandlers.remove(this._vis);
         super.destroy();
      }
      
      override public function render() : void
      {
         super.render();
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         super.receiveMessage(param1,param2);
         if(param1 == Entity.ON_STATE_CHANGED && !this.feature.isAmbient)
         {
            if(this.feature.isActivated)
            {
               this._mc["down"].visible = false;
               this._mc["up"].visible = true;
               this._mc["up"].play();
            }
            else
            {
               this._mc["down"].visible = true;
               this._mc["up"].visible = false;
               this._mc["up"].stop();
            }
         }
      }
      
      override protected function handlePaused() : void
      {
         if(this.feature.isActivated)
         {
            this._mc["up"].stop();
         }
      }
      
      override protected function handleUnpaused() : void
      {
         if(this.feature.isActivated)
         {
            this._mc["up"].play();
         }
      }
      
      private function get feature() : Feature
      {
         return entity as Feature;
      }
   }
}

