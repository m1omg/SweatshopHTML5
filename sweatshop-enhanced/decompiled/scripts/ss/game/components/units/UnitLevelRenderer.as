package ss.game.components.units
{
   import flash.display.MovieClip;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.Entity;
   import ss.game.core.Renderer;
   import ss.game.core.VisualElement;
   import ss.game.entities.MapEntity;
   import ss.game.entities.Unit;
   import ss.game.entities.Worker;
   
   public class UnitLevelRenderer extends Renderer
   {
      
      private var _stars:MovieClip;
      
      private var _vis:VisualElement;
      
      public function UnitLevelRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         positionMode = TILE_BASED_POSITION;
         this._stars = App.instance.resources.instantiateMovieClip("hud","Stars");
         if(this.unit.type == "child")
         {
            this._stars.y += 15 * Game.level.objectScale;
         }
         this._stars.scaleX = this._stars.scaleY = Game.level.objectScale;
         this._vis = addElement(this._stars);
         this.refresh();
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         if(param1 == Unit.ON_RESET)
         {
            this.refresh();
         }
         else if(param1 == Entity.ON_STATE_CHANGED)
         {
            switch(entity.state)
            {
               case Worker.DEAD_EXHAUSTION_STATE:
               case Worker.DISMISSED_STATE:
               case Worker.INJURED_STATE:
               case MapEntity.BURNING_STATE:
               case MapEntity.SOOT_STATE:
                  this._vis.visible = false;
            }
         }
      }
      
      private function refresh() : void
      {
         this._stars.gotoAndStop("level" + this.unit.level);
      }
      
      override public function render() : void
      {
         offset = this.unit.renderOffset.clone();
         this._vis.depth = DepthManager.getDepth(DepthManager.WORKER_STARS,entity.position,offset);
         super.render();
      }
      
      private function get unit() : Unit
      {
         return entity as Unit;
      }
   }
}

