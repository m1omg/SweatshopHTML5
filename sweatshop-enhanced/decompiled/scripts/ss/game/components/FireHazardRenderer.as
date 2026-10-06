package ss.game.components
{
   import flash.display.MovieClip;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.Animation;
   import ss.game.entities.FireHazard;
   
   public class FireHazardRenderer extends Animation
   {
      
      private var _mc:MovieClip;
      
      private var _currentClip:MovieClip;
      
      public function FireHazardRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         super.prepare();
         positionMode = TILE_BASED_POSITION;
         this._mc = App.instance.resources.instantiateMovieClip("features","FireHazardSymbol");
         this._mc.scaleX = this._mc.scaleY = Game.level.objectScale;
         addElement(this._mc).depth = DepthManager.getDepth(DepthManager.FIRE_HAZARD,entity.position);
         this.refresh();
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         super.receiveMessage(param1,param2);
         switch(param1)
         {
            case FireHazard.ON_UPDATED:
               this.refresh();
         }
      }
      
      private function refresh() : void
      {
         if(this.hazard.isProtected)
         {
            this._mc["safe"].visible = true;
            this._mc["risk"].visible = false;
            this._mc["wait"].visible = false;
            this._currentClip = this._mc["safe"];
         }
         else if(this.hazard.isSparking)
         {
            this._mc["safe"].visible = false;
            this._mc["risk"].visible = true;
            this._mc["wait"].visible = false;
            this._currentClip = this._mc["risk"];
         }
         else
         {
            this._mc["safe"].visible = false;
            this._mc["risk"].visible = false;
            this._mc["wait"].visible = true;
            this._currentClip = this._mc["wait"];
         }
      }
      
      private function get hazard() : FireHazard
      {
         return entity as FireHazard;
      }
      
      override protected function handlePaused() : void
      {
         this._mc["risk"].stop();
      }
      
      override protected function handleUnpaused() : void
      {
         this._mc["risk"].play();
      }
   }
}

