package ss.game.components.units
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import org.fatlib.utils.DisplayUtils;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.Animation;
   import ss.game.core.VisualElement;
   import ss.game.entities.MapEntity;
   import ss.game.entities.Officer;
   import ss.utils.MouseHandlers;
   import ss.utils.Utils;
   
   public class OfficerRenderer extends Animation
   {
      
      private var _mc:MovieClip;
      
      private var _vis:VisualElement;
      
      private var _hit:VisualElement;
      
      public function OfficerRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         super.prepare();
         positionMode = TILE_BASED_POSITION;
         var _loc1_:String = Utils.getUnitResourceName(this.officer.type,"m");
         this._mc = App.instance.resources.instantiateMovieClip(_loc1_,"CharacterSymbol");
         this._mc.scaleX = this._mc.scaleY = Game.level.objectScale;
         this._mc["hit"].visible = false;
         this._vis = addElement(this._mc);
         this._vis.depth = DepthManager.getDepth(DepthManager.WORKER_BOT,entity.position);
         var _loc2_:Sprite = DisplayUtils.createCircle(12,0);
         _loc2_.height = 8;
         _loc2_.alpha = 0.3;
         addElement(_loc2_).depth = DepthManager.getDepth(DepthManager.SHADOW,entity.position);
         offset = new Point(Game.level.tileWidth * 0.5,Game.level.tileHeight * 0.5);
         (entity as MapEntity).renderOffset = offset.clone();
         var _loc3_:MovieClip = App.instance.resources.instantiateMovieClip(_loc1_,"CharacterSymbol");
         _loc3_.scaleX = _loc3_.scaleY = Game.level.objectScale;
         _loc3_["char"].visible = false;
         _loc3_["char"].stop();
         _loc3_.alpha = 0;
         this._hit = addElement(_loc3_,true);
         this._hit.depth = this._vis.depth;
         MouseHandlers.add(this._hit,entity.id);
      }
      
      override public function destroy() : void
      {
         MouseHandlers.remove(this._hit);
         super.destroy();
      }
      
      override protected function handlePaused() : void
      {
         this._mc["char"].stop();
      }
      
      override protected function handleUnpaused() : void
      {
         this._mc["char"].play();
      }
      
      private function get officer() : Officer
      {
         return entity as Officer;
      }
   }
}

