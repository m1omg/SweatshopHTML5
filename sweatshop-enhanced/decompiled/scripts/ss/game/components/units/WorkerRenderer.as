package ss.game.components.units
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import org.fatlib.Log;
   import org.fatlib.utils.DisplayUtils;
   import org.fatlib.utils.MathUtils;
   import ss.Values;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.Animation;
   import ss.game.core.Entity;
   import ss.game.core.VisualElement;
   import ss.game.entities.Item;
   import ss.game.entities.Map;
   import ss.game.entities.MapEntity;
   import ss.game.entities.Unit;
   import ss.game.entities.Worker;
   import ss.utils.MouseHandlers;
   import ss.utils.Utils;
   
   public class WorkerRenderer extends Animation
   {
      
      public static const FRONT:String = "F";
      
      public static const LEFT:String = "L";
      
      public static const RIGHT:String = "R";
      
      public static const BACK:String = "B";
      
      public static const IDLE:String = "I";
      
      public static const HAPPY:String = "happy";
      
      public static const NEUTRAL:String = "neutral";
      
      public static const SAD:String = "sad";
      
      public static const NORMAL:String = "normal";
      
      public static const TIRED:String = "tired";
      
      public static const EXHAUSTED:String = "exhausted";
      
      public static const BURN:String = "burn";
      
      public static const SOOT:String = "soot";
      
      public static const GHOST:String = "ghost";
      
      public static const INJURY:String = "injury";
      
      public static const DISMISSED:String = "fired";
      
      private var _dir:String;
      
      private var _mood:String;
      
      private var _botMC:MovieClip;
      
      private var _topMC:MovieClip;
      
      private var _top:VisualElement;
      
      private var _bot:VisualElement;
      
      private var _walkRadius:Number = 0;
      
      private var _walkAngle:Number = 0;
      
      private var _directions:Object;
      
      private var _headOnTop:Boolean;
      
      private var _outlines:Boolean;
      
      private var _offsetTarget:Point;
      
      private var _lastWorkingTime:Number;
      
      private var _currentStatePlayesFromStart:Boolean;
      
      private var _lastSpecialState:String;
      
      private var _hit:VisualElement;
      
      public function WorkerRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         positionMode = TILE_BASED_POSITION;
         this.worker.renderOffset = new Point(Game.level.tileWidth * 0.5,Game.level.tileHeight * 0.5);
         var _loc1_:String = Utils.getUnitResourceName(this.worker.type,this.worker.gender);
         this._topMC = App.instance.resources.instantiateMovieClip(_loc1_,"CharacterSymbol");
         this._botMC = App.instance.resources.instantiateMovieClip(_loc1_,"CharacterSymbol");
         this._topMC.scaleX = this._topMC.scaleY = this._botMC.scaleX = this._botMC.scaleY = Game.level.objectScale;
         Utils.hideChildren(this._topMC);
         Utils.hideChildren(this._botMC);
         this._top = addElement(this._topMC);
         this._bot = addElement(this._botMC);
         this._headOnTop = Values.WORKER_HEAD_ON_TOP;
         this._outlines = Values.WORKER_OUTLINES;
         if(this._outlines)
         {
            Utils.applyObjectFilter(this._botMC,2);
            if(this._headOnTop)
            {
               Utils.applyObjectFilter(this._topMC,2);
            }
         }
         var _loc2_:Sprite = new Sprite();
         var _loc3_:Sprite = DisplayUtils.createCircle(12,0);
         _loc3_.height = 8;
         _loc2_.addChild(_loc3_);
         _loc2_.scaleX = _loc2_.scaleY = Game.level.objectScale;
         _loc2_.alpha = 0.3;
         addElement(_loc2_).depth = DepthManager.getDepth(DepthManager.SHADOW,entity.position);
         this._directions = {};
         this._directions[[0,1]] = FRONT;
         this._directions[[0,-1]] = BACK;
         this._directions[[1,0]] = RIGHT;
         this._directions[[-1,0]] = LEFT;
         var _loc4_:Point = new Point(entity.position.x - 1,entity.position.y);
         var _loc5_:Point = new Point(entity.position.x + 1,entity.position.y);
         var _loc6_:Point = new Point(entity.position.x,entity.position.y - 1);
         var _loc7_:Point = new Point(entity.position.x,entity.position.y + 1);
         var _loc8_:Map = engine.resolveReference(this.worker.mapRef);
         var _loc9_:Boolean = _loc8_.isBeltAt(_loc4_);
         var _loc10_:Boolean = _loc8_.isBeltAt(_loc5_);
         var _loc11_:Boolean = _loc8_.isBeltAt(_loc6_);
         var _loc12_:Boolean = _loc8_.isBeltAt(_loc7_);
         if((_loc12_) && !_loc10_)
         {
            this._directions[[1,1]] = FRONT;
         }
         else
         {
            this._directions[[1,1]] = RIGHT;
         }
         if(_loc12_ && !_loc9_)
         {
            this._directions[[-1,1]] = FRONT;
         }
         else
         {
            this._directions[[-1,1]] = LEFT;
         }
         if(_loc11_ && !_loc10_)
         {
            this._directions[[1,-1]] = BACK;
         }
         else
         {
            this._directions[[1,-1]] = RIGHT;
         }
         if(_loc11_ && !_loc9_)
         {
            this._directions[[-1,-1]] = BACK;
         }
         else
         {
            this._directions[[-1,-1]] = LEFT;
         }
         this.centreOffsetTarget();
         this.setDirection(IDLE);
         this.setMood(HAPPY);
         super.prepare();
         var _loc13_:MovieClip = App.instance.resources.instantiateMovieClip(_loc1_,"CharacterSymbol");
         _loc13_.scaleX = _loc13_.scaleY = Game.level.objectScale;
         Utils.hideChildren(_loc13_);
         DisplayUtils.recursiveStop(_loc13_);
         _loc13_["headI"].visible = true;
         _loc13_["bodyI"].visible = true;
         this._hit = addElement(_loc13_,true);
         this._hit.alpha = 0;
         MouseHandlers.add(this._hit,entity.id);
      }
      
      override public function destroy() : void
      {
         MouseHandlers.remove(this._hit);
         super.destroy();
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         super.receiveMessage(param1,param2);
         switch(param1)
         {
            case Entity.ON_STATE_CHANGED:
               this.stateUpdated();
         }
      }
      
      private function stateUpdated() : void
      {
         this._hit.visible = this.worker.selectable;
         switch(entity.state)
         {
            case Unit.NORMAL_STATE:
               this.clearSpecialState();
               this.setDirection(this._dir);
               this.setMood(this._mood);
               break;
            case Worker.TIRED_STATE:
               this.renderSpecial(TIRED);
               break;
            case Worker.INJURED_STATE:
               this.centreOffsetTarget();
               this.renderSpecial(INJURY,true);
               break;
            case Worker.EXHAUSTED_STATE:
               this.centreOffsetTarget();
               this.renderSpecial(EXHAUSTED);
               break;
            case Worker.DEAD_EXHAUSTION_STATE:
               this.renderSpecial(GHOST,true);
               break;
            case MapEntity.BURNING_STATE:
               this.centreOffsetTarget();
               this.renderSpecial(BURN);
               break;
            case MapEntity.SOOT_STATE:
               this.centreOffsetTarget();
               this.renderSpecial(SOOT,true);
               break;
            case Worker.DISMISSED_STATE:
               this.centreOffsetTarget();
               this.renderSpecial(DISMISSED);
               break;
            case Worker.LEVEL_DONE_STATE:
               this.centreOffsetTarget();
               this.renderSpecial(TIRED);
         }
      }
      
      override public function render() : void
      {
         offset = this.worker.renderOffset.clone();
         this._top.depth = DepthManager.getDepth(DepthManager.WORKER_TOP,entity.position,offset);
         this._bot.depth = DepthManager.getDepth(DepthManager.WORKER_BOT,entity.position,offset);
         this._hit.depth = DepthManager.getDepth(DepthManager.WORKER_TOP,entity.position,offset);
         this.worker.renderOffset.x += (this._offsetTarget.x - this.worker.renderOffset.x) / 5;
         this.worker.renderOffset.y += (this._offsetTarget.y - this.worker.renderOffset.y) / 5;
         switch(this.worker.state)
         {
            case Unit.NORMAL_STATE:
               this.renderNormal();
         }
         super.render();
      }
      
      private function renderNormal() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Item = null;
         var _loc5_:Point = null;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         for each(_loc1_ in [TIRED,EXHAUSTED])
         {
            this._botMC[_loc1_].visible = false;
            this._topMC[_loc1_].visible = false;
         }
         _loc2_ = this._dir;
         _loc3_ = this._mood;
         _loc4_ = engine.resolveReference(this.worker.currentItemRef);
         if(_loc4_)
         {
            _loc5_ = _loc4_.position.subtract(this.worker.position);
            _loc6_ = this._directions[[_loc5_.x,_loc5_.y]];
            if(_loc6_)
            {
               _loc2_ = _loc6_;
               this._offsetTarget = new Point(Game.level.tileWidth * 0.5,Game.level.tileHeight * 0.5);
               _loc7_ = Game.level.tileWidth * 0.2;
               _loc8_ = Game.level.tileHeight * 0.3;
               switch(_loc6_)
               {
                  case FRONT:
                     this._offsetTarget.y += _loc8_;
                     break;
                  case BACK:
                     this._offsetTarget.y -= _loc8_;
                     break;
                  case LEFT:
                     this._offsetTarget.x -= _loc7_;
                     break;
                  case RIGHT:
                     this._offsetTarget.x += _loc7_;
               }
            }
            this._lastWorkingTime = engine.timer.elapsed;
         }
         else
         {
            _loc2_ = IDLE;
            if(engine.timer.elapsed > this._lastWorkingTime + 0.5)
            {
               this._offsetTarget = new Point(Game.level.tileWidth * 0.5,Game.level.tileHeight * 0.5);
            }
         }
         if(this.worker.energy < Values.SAD_ENERGY_THRESHOLD)
         {
            _loc3_ = SAD;
         }
         else if(this.worker.energy < Values.NEUTRAL_ENERGY_THRESHOLD)
         {
            _loc3_ = NEUTRAL;
         }
         else
         {
            _loc3_ = HAPPY;
         }
         if(_loc3_ != this._mood)
         {
            this.setMood(_loc3_);
         }
         if(_loc2_ != this._dir)
         {
            this.setDirection(_loc2_);
            this.setMood(this._mood);
         }
      }
      
      private function clearSpecialState() : void
      {
         if(Boolean(this._lastSpecialState) && Boolean(this._botMC[this._lastSpecialState]))
         {
            this._botMC[this._lastSpecialState].visible = false;
         }
         this._lastSpecialState = null;
      }
      
      private function renderSpecial(param1:String, param2:Boolean = false) : void
      {
         if(!this._botMC[param1])
         {
            Log.error("State \"" + param1 + "\" not found on " + entity.id + " movieclip");
            return;
         }
         this._lastSpecialState = param1;
         Utils.hideChildren(this._topMC);
         Utils.hideChildren(this._botMC);
         this._botMC[param1].visible = true;
         if(param2)
         {
            this._botMC[param1].gotoAndPlay(1);
         }
         this._currentStatePlayesFromStart = param2;
      }
      
      private function setDirection(param1:String) : void
      {
         var _loc3_:String = null;
         this._dir = param1;
         var _loc2_:Boolean = this.worker.type == "superstar";
         for each(_loc3_ in [FRONT,BACK,LEFT,RIGHT,IDLE])
         {
            this._botMC["body" + _loc3_].visible = _loc3_ == this._dir;
            this._topMC["body" + _loc3_].visible = false;
            if(_loc3_ == BACK)
            {
               this._topMC["arms" + _loc3_].visible = false;
               this._botMC["arms" + _loc3_].visible = _loc3_ == this._dir;
               if(_loc2_ && _loc3_ != "I")
               {
                  this._topMC["lazer" + _loc3_].visible = false;
                  this._botMC["lazer" + _loc3_].visible = _loc3_ == this._dir;
               }
            }
            else
            {
               this._botMC["arms" + _loc3_].visible = false;
               this._topMC["arms" + _loc3_].visible = _loc3_ == this._dir;
               if(_loc2_ && _loc3_ != "I")
               {
                  this._botMC["lazer" + _loc3_].visible = false;
                  this._topMC["lazer" + _loc3_].visible = _loc3_ == this._dir;
               }
            }
            if(this._headOnTop)
            {
               this._topMC["head" + _loc3_].visible = _loc3_ == this._dir;
               this._botMC["head" + _loc3_].visible = false;
            }
            else
            {
               this._topMC["head" + _loc3_].visible = false;
               this._botMC["head" + _loc3_].visible = _loc3_ == this._dir;
            }
         }
         this._topMC["armsF"].visible = false;
         this._botMC["armsB"].visible = false;
         this._topMC["armsL"].visible = false;
         this._topMC["armsR"].visible = false;
         this._topMC["armsI"].visible = false;
         this._topMC["armsF"].stop();
         this._botMC["armsB"].stop();
         this._topMC["armsL"].stop();
         this._topMC["armsR"].stop();
         this._topMC["armsI"].stop();
         if(_loc2_)
         {
            this._topMC["lazerF"].visible = false;
            this._botMC["lazerB"].visible = false;
            this._topMC["lazerL"].visible = false;
            this._topMC["lazerR"].visible = false;
            this._topMC["lazerF"].stop();
            this._botMC["lazerB"].stop();
            this._topMC["lazerL"].stop();
            this._topMC["lazerR"].stop();
         }
         if(param1 == FRONT)
         {
            this._topMC["armsF"].visible = true;
            this._topMC["armsF"].gotoAndPlay(MathUtils.rollDice(20));
            if(this.worker.type == "superstar")
            {
               this._topMC["lazerF"].visible = true;
               this._topMC["lazerF"].play();
            }
         }
         else if(param1 == LEFT)
         {
            this._topMC["armsL"].visible = true;
            this._topMC["armsL"].gotoAndPlay(MathUtils.rollDice(20));
            if(this.worker.type == "superstar")
            {
               this._topMC["lazerL"].visible = true;
               this._topMC["lazerL"].play();
            }
         }
         else if(param1 == RIGHT)
         {
            this._topMC["armsR"].visible = true;
            this._topMC["armsR"].gotoAndPlay(MathUtils.rollDice(20));
            if(this.worker.type == "superstar")
            {
               this._topMC["lazerR"].visible = true;
               this._topMC["lazerR"].play();
            }
         }
         else if(param1 == BACK)
         {
            this._botMC["armsB"].visible = true;
            this._botMC["armsB"].gotoAndPlay(MathUtils.rollDice(20));
            if(this.worker.type == "superstar")
            {
               this._botMC["lazerB"].visible = true;
               this._botMC["lazerB"].play();
            }
         }
      }
      
      private function setMood(param1:String) : void
      {
         var m:String = param1;
         this._mood = m;
         try
         {
            if(this._headOnTop)
            {
               this._topMC["head" + this._dir].gotoAndStop(this._mood);
            }
            else
            {
               this._botMC["head" + this._dir].gotoAndStop(this._mood);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      override protected function handlePaused() : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:DisplayObject = null;
         var _loc1_:int = this._topMC.numChildren;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this._topMC.getChildAt(_loc2_);
            if(_loc3_.visible && _loc3_ is MovieClip)
            {
               (_loc3_ as MovieClip).stop();
            }
            _loc4_ = this._botMC.getChildAt(_loc2_);
            if(_loc4_.visible && _loc4_ is MovieClip)
            {
               (_loc4_ as MovieClip).stop();
            }
            _loc2_++;
         }
      }
      
      override protected function handleUnpaused() : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:DisplayObject = null;
         var _loc5_:MovieClip = null;
         var _loc1_:int = this._topMC.numChildren;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this._topMC.getChildAt(_loc2_);
            if(_loc3_.visible && _loc3_ is MovieClip)
            {
               (_loc3_ as MovieClip).play();
            }
            _loc4_ = this._botMC.getChildAt(_loc2_);
            if(_loc4_.visible && _loc4_ is MovieClip)
            {
               _loc5_ = _loc4_ as MovieClip;
               if(!(this._currentStatePlayesFromStart && _loc5_.currentFrame == _loc5_.totalFrames))
               {
                  (_loc5_ as MovieClip).play();
               }
            }
            _loc2_++;
         }
         if(entity.state == Unit.NORMAL_STATE)
         {
            this.setDirection(this._dir);
            this.setMood(this._mood);
         }
      }
      
      private function centreOffsetTarget() : void
      {
         this._offsetTarget = new Point(Game.level.tileWidth * 0.5,Game.level.tileHeight * 0.5);
      }
      
      private function get worker() : Worker
      {
         return entity as Worker;
      }
   }
}

