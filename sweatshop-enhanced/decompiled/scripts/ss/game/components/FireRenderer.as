package ss.game.components
{
   import flash.display.MovieClip;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.core.Animation;
   import ss.game.core.Entity;
   import ss.game.core.VisualElement;
   import ss.game.entities.MapEntity;
   
   public class FireRenderer extends Animation
   {
      
      private var _vis:VisualElement;
      
      private var _mc:MovieClip;
      
      public function FireRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         super.prepare();
         positionMode = TILE_BASED_POSITION;
         this._mc = App.instance.resources.instantiateMovieClip("hud","FireSymbol");
         this._vis = addElement(this._mc,false);
         this._mc.visible = false;
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         super.receiveMessage(param1,param2);
         switch(param1)
         {
            case Entity.ON_STATE_CHANGED:
               if(entity.state == MapEntity.BURNING_STATE)
               {
                  this._mc.visible = true;
                  break;
               }
               this._mc.visible = false;
         }
      }
      
      override protected function handlePaused() : void
      {
         this._mc.stop();
      }
      
      override protected function handleUnpaused() : void
      {
         this._mc.play();
      }
      
      override public function render() : void
      {
         if(!this._mc.visible)
         {
            return;
         }
         this._vis.depth = DepthManager.getDepth(DepthManager.ITEM_FIRE,entity.position,(entity as MapEntity).renderOffset);
         offset = (entity as MapEntity).renderOffset;
         super.render();
      }
   }
}

