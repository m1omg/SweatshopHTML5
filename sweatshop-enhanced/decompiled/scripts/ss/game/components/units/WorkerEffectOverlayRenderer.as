package ss.game.components.units
{
   import flash.display.MovieClip;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Animation;
   import ss.game.core.Entity;
   import ss.game.core.VisualElement;
   import ss.game.entities.Environment;
   import ss.game.entities.Unit;
   import ss.game.entities.Worker;
   
   public class WorkerEffectOverlayRenderer extends Animation
   {
      
      private var _mc:MovieClip;
      
      private var _overlays:Object;
      
      private var _vis:VisualElement;
      
      public function WorkerEffectOverlayRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         super.prepare();
         positionMode = TILE_BASED_POSITION;
         this._mc = new MovieClip();
         this._mc.scaleX = this._mc.scaleY = Game.level.objectScale;
         this._overlays = {};
         this.addOverlay(Environment.CASH_BONUS,"UnitOverlayCashSymbol");
         this.addOverlay(Environment.RECHARGE_MODIFIER,"UnitOverlayEnergySymbol");
         this.addOverlay(Environment.SKILL_MODIFIER,"UnitOverlaySkillSymbol");
         Game.messenger.register(this,Messages.FEATURE_ACTIVATED);
         this._vis = addElement(this._mc);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         super.receiveMessage(param1,param2);
         switch(param1)
         {
            case Worker.ON_EFFECTED:
               this.showEffect(param2.type);
               break;
            case Entity.ON_STATE_CHANGED:
               this.handleStateChanged(entity.state);
         }
      }
      
      private function handleStateChanged(param1:String) : void
      {
      }
      
      private function addOverlay(param1:String, param2:String) : void
      {
         var _loc3_:MovieClip = App.instance.resources.instantiateMovieClip("hud",param2);
         _loc3_.stop();
         _loc3_.visible = false;
         this._overlays[param1] = _loc3_;
         this._mc.addChild(_loc3_);
      }
      
      override protected function handlePaused() : void
      {
         var _loc1_:MovieClip = null;
         for each(_loc1_ in this._overlays)
         {
            _loc1_.stop();
         }
      }
      
      override protected function handleUnpaused() : void
      {
         var _loc1_:MovieClip = null;
         for each(_loc1_ in this._overlays)
         {
            if(_loc1_.visible && _loc1_.currentFrame != _loc1_.totalFrames)
            {
               _loc1_.play();
            }
         }
      }
      
      override public function render() : void
      {
         offset = (entity as Unit).renderOffset.clone();
         this._vis.depth = DepthManager.getDepth(DepthManager.WORKER_EFFECT,entity.position,offset);
         super.render();
      }
      
      private function showEffect(param1:String) : void
      {
         switch(param1)
         {
            case Environment.SKILL_MODIFIER:
            case Environment.CASH_BONUS:
               if(entity.state != Unit.NORMAL_STATE)
               {
                  return;
               }
               break;
            case Environment.RECHARGE_MODIFIER:
               if(entity.state != Unit.NORMAL_STATE && entity.state != Worker.TIRED_STATE && entity.state != Worker.EXHAUSTED_STATE)
               {
                  return;
               }
         }
         if(!this._overlays[param1])
         {
            return;
         }
         var _loc2_:MovieClip = this._overlays[param1];
         _loc2_.visible = true;
         _loc2_.play();
      }
   }
}

