package ss.game.components
{
   import flash.display.MovieClip;
   import org.fatlib.utils.MathUtils;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Animation;
   import ss.game.core.Entity;
   import ss.game.entities.Environment;
   import ss.game.entities.MapEntity;
   
   public class BoxRenderer extends Animation
   {
      
      private var _mc:MovieClip;
      
      private var _currentClip:MovieClip;
      
      public function BoxRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         super.prepare();
         (entity as MapEntity).selectable = false;
         positionMode = TILE_BASED_POSITION;
         var _loc1_:int = MathUtils.rollDice(4);
         this._mc = App.instance.resources.instantiateMovieClip("features","Box" + _loc1_ + "Symbol");
         this._mc.scaleX = this._mc.scaleY = Game.level.objectScale;
         addElement(this._mc).depth = DepthManager.getDepth(DepthManager.WORKER_BOT,entity.position);
         Game.messenger.register(this,Messages.ENVIRONMENT_CHANGED);
         this.show("normal");
         this.checkRisk();
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         super.receiveMessage(param1,param2);
         switch(param1)
         {
            case Entity.ON_STATE_CHANGED:
               this.refresh();
               break;
            case Messages.ENVIRONMENT_CHANGED:
               this.checkRisk();
         }
      }
      
      private function checkRisk() : void
      {
         if(entity.state == MapEntity.BURNING_STATE || entity.state == MapEntity.SOOT_STATE)
         {
            return;
         }
         var _loc1_:Environment = engine.find("environment") as Environment;
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:Number = _loc1_.getValue(Environment.FIRE_PROTECTION,entity.position.x,entity.position.y);
         if(_loc2_ > 0)
         {
            entity.changeState("safe");
         }
         else
         {
            entity.changeState("normal");
         }
      }
      
      private function refresh() : void
      {
         switch(entity.state)
         {
            case MapEntity.BURNING_STATE:
               this.show("burn");
               break;
            case MapEntity.SOOT_STATE:
               this.show("soot");
               break;
            case "normal":
            case "safe":
               this.show(entity.state);
         }
      }
      
      private function show(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:MovieClip = null;
         for each(_loc2_ in ["normal","safe","soot","burn"])
         {
            _loc3_ = this._mc[_loc2_];
            if(_loc2_ == param1)
            {
               this._currentClip = _loc3_;
               _loc3_.visible = true;
               _loc3_.play();
            }
            else
            {
               _loc3_.visible = false;
               _loc3_.stop();
            }
         }
      }
      
      override protected function handlePaused() : void
      {
         this._currentClip.stop();
      }
      
      override protected function handleUnpaused() : void
      {
         if(entity.state == MapEntity.SOOT_STATE && this._currentClip.currentFrame == this._currentClip.totalFrames)
         {
            return;
         }
         this._currentClip.play();
      }
   }
}

