package ss.game.components
{
   import flash.display.MovieClip;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.Entity;
   import ss.game.core.Renderer;
   import ss.game.entities.Item;
   import ss.game.entities.MapEntity;
   
   public class ItemProgressBarRenderer extends Renderer
   {
      
      private var _progressBar:MovieClip;
      
      private var _barVisible:Boolean = true;
      
      public function ItemProgressBarRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         positionMode = TILE_BASED_POSITION;
         this._progressBar = App.instance.resources.instantiateMovieClip("hud","ItemProgressBarSymbol");
         this._progressBar.y = -24 * Game.level.objectScale;
         this._progressBar.stop();
         addElement(this._progressBar).depth = DepthManager.getDepth(DepthManager.ITEM_PROGRESS_BAR);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Entity.ON_STATE_CHANGED:
               if(entity.state == MapEntity.BURNING_STATE || entity.state == Item.DONE_STATE)
               {
                  this._barVisible = false;
               }
         }
      }
      
      override public function render() : void
      {
         offset = this.item.renderOffset.clone();
         this._progressBar.gotoAndStop(int(100 * this.item.workProgress / this.item.workComplexity));
         this._progressBar.visible = !this.item.onNodeTile && this._barVisible;
         if(this.item.tileCount == 1)
         {
            this._progressBar.alpha = this.item.tileProgress;
         }
         else
         {
            this._progressBar.alpha = 1;
         }
         super.render();
      }
      
      private function get item() : Item
      {
         return entity as Item;
      }
   }
}

