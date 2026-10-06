package ss.game.components.ui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.utils.getTimer;
   import ss.Values;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.Animation;
   import ss.game.entities.DragInstance;
   import ss.game.factory.EntityFactory;
   import ss.utils.Utils;
   
   public class DragIconRenderer extends Animation
   {
      
      private var _container:Sprite;
      
      private var _icon:MovieClip;
      
      private var _oldMousePos:Point;
      
      private var _oscillation:Number;
      
      private var _mcToPause:MovieClip;
      
      public function DragIconRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         this._container = new Sprite();
         addElement(this._container).depth = DepthManager.getDepth(DepthManager.DRAGGABLE);
         this._oldMousePos = new Point();
         super.prepare();
      }
      
      override protected function handlePaused() : void
      {
         if(this._mcToPause)
         {
            this._mcToPause.stop();
         }
      }
      
      override protected function handleUnpaused() : void
      {
         if(this._mcToPause)
         {
            this._mcToPause.play();
         }
      }
      
      override public function render() : void
      {
         var _loc2_:Number = NaN;
         if(this.dragInstance.isDragging && !this._icon)
         {
            this._icon = this.createIcon();
            this._container.addChild(this._icon);
            this._oscillation = 15;
         }
         if(!this.dragInstance.isDragging && Boolean(this._icon))
         {
            this._container.removeChild(this._icon);
            this._icon = null;
            this._mcToPause = null;
         }
         var _loc1_:Point = Game.canvas.mousePosition;
         if(this.dragInstance.isDragging)
         {
            this._container.x = _loc1_.x;
            this._container.y = _loc1_.y;
            this._container.rotation = Math.sin(getTimer() / 300) * this._oscillation;
            this._oscillation *= 0.9999;
            _loc2_ = Math.abs(this._oldMousePos.x - _loc1_.x) / 2;
            this._oscillation += _loc2_;
            if(this._oscillation > 15)
            {
               this._oscillation = 15;
            }
            this._oldMousePos = _loc1_.clone();
            if(this.dragInstance.canDrop && this.dragInstance.canBuy)
            {
               this._icon.filters = [];
            }
            else
            {
               this._icon.filters = [Utils.desaturated()];
            }
         }
         super.render();
      }
      
      private function createIcon() : MovieClip
      {
         var _loc1_:MovieClip = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:MovieClip = null;
         var _loc2_:String = this.dragInstance.attributes.type;
         var _loc3_:String = this.dragInstance.attributes.category;
         var _loc4_:String = this.dragInstance.attributes.key;
         if(_loc3_ == EntityFactory.WORKER)
         {
            _loc5_ = "m";
            if(Math.random() < Values.FEMALE_CHANCE)
            {
               _loc5_ = "f";
            }
            _loc6_ = Utils.getUnitResourceName(_loc2_,_loc5_);
            _loc1_ = App.instance.resources.instantiateMovieClip(_loc6_,"CharacterSymbol");
            Utils.hideChildren(_loc1_);
            _loc1_["drag"].visible = true;
            _loc1_.scaleX = _loc1_.scaleY = Game.level.objectScale;
            this.dragInstance.gender = _loc5_;
            if(Values.WORKER_OUTLINES)
            {
               Utils.applyObjectFilter(_loc1_);
            }
            this._mcToPause = _loc1_["drag"];
         }
         else if(_loc3_ == EntityFactory.FEATURE)
         {
            _loc1_ = App.instance.resources.instantiateMovieClip("features",Utils.getFeatureSymbol(_loc4_));
            _loc1_.scaleX = _loc1_.scaleY = Game.level.objectScale;
            _loc1_.x = -_loc1_.width / 2;
            _loc1_.stop();
            _loc1_.y -= 20 * Game.level.objectScale;
            _loc1_["up"].visible = false;
            _loc1_["hit"].visible = false;
         }
         else if(_loc3_ == EntityFactory.OFFICER)
         {
            _loc7_ = Utils.getUnitResourceName(_loc2_);
            _loc8_ = App.instance.resources.instantiateMovieClip(_loc7_,"CharacterSymbol");
            _loc8_["hit"].visible = false;
            _loc8_.y = 20;
            _loc1_ = new MovieClip();
            _loc1_.scaleX = _loc1_.scaleY = Game.level.objectScale;
            _loc1_.addChild(_loc8_);
            _loc1_.stop();
         }
         return _loc1_;
      }
      
      private function get dragInstance() : DragInstance
      {
         return entity as DragInstance;
      }
   }
}

