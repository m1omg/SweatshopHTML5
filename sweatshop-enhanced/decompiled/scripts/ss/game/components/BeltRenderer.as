package ss.game.components
{
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import org.fatlib.Log;
   import org.fatlib.utils.DisplayUtils;
   import ss.app.App;
   import ss.game.Commands;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Animation;
   import ss.game.core.IMessageReceiver;
   import ss.game.entities.Belt;
   import ss.game.entities.Environment;
   import ss.game.entities.Sequence;
   import ss.utils.Utils;
   
   public class BeltRenderer extends Animation implements IMessageReceiver
   {
      
      private var _cells:Object;
      
      private var _startMC1:MovieClip;
      
      private var _startMask1:Shape;
      
      private var _startMask2:Shape;
      
      private var _startMC2:MovieClip;
      
      public function BeltRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         var _loc1_:String = null;
         var _loc8_:MovieClip = null;
         var _loc12_:Sprite = null;
         var _loc13_:int = 0;
         var _loc14_:String = null;
         var _loc15_:MovieClip = null;
         var _loc16_:MovieClip = null;
         super.prepare();
         positionMode = TILE_BASED_POSITION;
         var _loc2_:int = Game.level.mapWidth;
         var _loc3_:int = Game.level.mapHeight;
         var _loc4_:int = Game.level.tileWidth;
         var _loc5_:int = Game.level.tileHeight;
         var _loc6_:int = Game.level.beltHeight;
         this._cells = {};
         var _loc7_:int = 0;
         while(_loc7_ < _loc3_)
         {
            _loc12_ = new Sprite();
            _loc13_ = 0;
            while(_loc13_ < _loc2_)
            {
               _loc1_ = this.belt.getDirection(new Point(_loc13_,_loc7_));
               if(_loc1_ != Belt.NONE)
               {
                  _loc14_ = this.belt.getTileSprite(new Point(_loc13_,_loc7_));
                  _loc15_ = new MovieClip();
                  _loc16_ = App.instance.resources.instantiateMovieClip("belt",_loc14_);
                  _loc16_.name = "content";
                  _loc15_.addChild(_loc16_);
                  _loc15_.scaleX = _loc15_.scaleY = Game.level.objectScale;
                  if(Game.level.world == 3)
                  {
                     _loc15_.width += 1;
                  }
                  _loc15_.x = _loc13_ * _loc4_;
                  _loc15_.y = (_loc7_ + 1) * _loc5_;
                  this._cells[_loc13_ + "_" + _loc7_] = _loc15_;
                  _loc12_.addChild(_loc15_);
               }
               _loc13_++;
            }
            addElement(_loc12_).depth = DepthManager.getDepth(DepthManager.BELT,new Point(0,_loc7_));
            _loc7_++;
         }
         this.updateEnvironment();
         var _loc9_:String = "StartN";
         var _loc10_:Point = this.belt.startNodes[1];
         var _loc11_:Point = this.belt.endNodes[1];
         _loc1_ = this.belt.getDirection(_loc10_);
         if(_loc1_ == Belt.LEFT)
         {
            _loc9_ = "StartW";
         }
         if(_loc1_ == Belt.RIGHT)
         {
            _loc9_ = "StartE";
         }
         if(_loc1_ == Belt.DOWN)
         {
            _loc9_ = "StartS";
         }
         _loc8_ = App.instance.resources.instantiateMovieClip("belt",_loc9_);
         _loc8_.scaleX = _loc8_.scaleY = Game.level.objectScale;
         _loc8_.x = _loc10_.x * _loc4_;
         _loc8_.y = (_loc10_.y + 1) * _loc5_;
         addElement(_loc8_).depth = DepthManager.getDepth(DepthManager.BELT_NODE,new Point(_loc10_.x,_loc10_.y));
         this._startMC1 = _loc8_;
         this._startMask1 = new Shape();
         this._startMC1["lcd"].addChild(this._startMask1);
         this._startMask1.x = this._startMC1["lcd"]["face"].x;
         this._startMask1.y = this._startMC1["lcd"]["face"].y;
         this._startMask1.rotation = -90;
         this._startMask1.graphics.clear();
         this._startMask1.graphics.beginFill(0);
         Utils.drawPieMask(this._startMask1.graphics,1,7);
         this._startMask1.graphics.endFill();
         this._startMC1["lcd"]["face"].mask = this._startMask1;
         this._startMC1["lcd"]["readout"].text = "*READY*";
         _loc9_ = "EndS";
         _loc1_ = this.belt.getDirection(_loc11_);
         if(_loc1_ == Belt.RIGHT)
         {
            _loc9_ = "EndW";
         }
         if(_loc1_ == Belt.LEFT)
         {
            _loc9_ = "EndE";
         }
         if(_loc1_ == Belt.DOWN)
         {
            _loc9_ = "EndN";
         }
         _loc8_ = App.instance.resources.instantiateMovieClip("belt",_loc9_);
         _loc8_.scaleX = _loc8_.scaleY = Game.level.objectScale;
         _loc8_.x = _loc11_.x * _loc4_;
         _loc8_.y = (_loc11_.y + 1) * _loc5_;
         addElement(_loc8_).depth = DepthManager.getDepth(DepthManager.BELT_NODE,new Point(_loc11_.x,_loc11_.y));
         if(Boolean(this.belt.startNodes[2]) && Utils.isActiveTile(this.belt.startNodes[2],Game.level.world))
         {
            _loc10_ = this.belt.startNodes[2];
            _loc1_ = this.belt.getDirection(_loc10_);
            _loc9_ = "StartN";
            if(_loc1_ == Belt.LEFT)
            {
               _loc9_ = "StartW";
            }
            if(_loc1_ == Belt.RIGHT)
            {
               _loc9_ = "StartE";
            }
            if(_loc1_ == Belt.DOWN)
            {
               _loc9_ = "StartS";
            }
            _loc8_ = App.instance.resources.instantiateMovieClip("belt",_loc9_);
            _loc8_.scaleX = _loc8_.scaleY = Game.level.objectScale;
            _loc8_.x = _loc10_.x * _loc4_;
            _loc8_.y = (_loc10_.y + 1) * _loc5_;
            addElement(_loc8_).depth = DepthManager.getDepth(DepthManager.BELT_NODE,new Point(_loc10_.y,_loc10_.y));
            this._startMC2 = _loc8_;
            this._startMask2 = new Shape();
            this._startMC2["lcd"].addChild(this._startMask2);
            this._startMask2.x = this._startMC1["lcd"]["face"].x;
            this._startMask2.y = this._startMC1["lcd"]["face"].y;
            this._startMask2.rotation = -90;
            this._startMask2.graphics.clear();
            this._startMask2.graphics.beginFill(0);
            Utils.drawPieMask(this._startMask2.graphics,1,7);
            this._startMask2.graphics.endFill();
            this._startMC2["lcd"]["face"].mask = this._startMask2;
            this._startMC2["lcd"]["readout"].text = "*READY*";
         }
         if(Boolean(this.belt.endNodes[2]) && Utils.isActiveTile(this.belt.endNodes[2],Game.level.world))
         {
            _loc11_ = this.belt.endNodes[2];
            _loc9_ = "EndS";
            _loc1_ = this.belt.getDirection(_loc11_);
            if(_loc1_ == Belt.RIGHT)
            {
               _loc9_ = "EndW";
            }
            if(_loc1_ == Belt.LEFT)
            {
               _loc9_ = "EndE";
            }
            if(_loc1_ == Belt.DOWN)
            {
               _loc9_ = "EndN";
            }
            _loc8_ = App.instance.resources.instantiateMovieClip("belt",_loc9_);
            _loc8_.scaleX = _loc8_.scaleY = Game.level.objectScale;
            _loc8_.x = _loc11_.x * _loc4_;
            _loc8_.y = (_loc11_.y + 1) * _loc5_;
            addElement(_loc8_).depth = DepthManager.getDepth(DepthManager.BELT_NODE,new Point(_loc11_.y,_loc11_.y));
         }
         this.showCogs(Belt.SLOW);
         Game.messenger.register(this,Commands.HILITE_BELT,Commands.UNHILITE_BELT,Messages.SEQUENCE_BROADCAST,Messages.ENVIRONMENT_CHANGED,Messages.BELT_SPEED_CHANGED);
      }
      
      override protected function handlePaused() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:MovieClip = null;
         for each(_loc1_ in this._cells)
         {
            _loc2_ = _loc1_.getChildByName("content") as MovieClip;
            if(_loc2_.getChildByName("cogs_fast"))
            {
               (_loc2_.getChildByName("cogs_fast") as MovieClip).stop();
            }
            if(_loc2_.getChildByName("cogs_slow"))
            {
               (_loc2_.getChildByName("cogs_slow") as MovieClip).stop();
            }
            DisplayUtils.recursiveStop(_loc2_);
         }
      }
      
      override protected function handleUnpaused() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:MovieClip = null;
         for each(_loc1_ in this._cells)
         {
            _loc2_ = _loc1_.getChildByName("content") as MovieClip;
            if(_loc2_.getChildByName("cogs_fast"))
            {
               (_loc2_.getChildByName("cogs_fast") as MovieClip).play();
            }
            if(Boolean(_loc2_.getChildByName("cogs_slow")) && this.belt.speedSetting == Belt.SLOW)
            {
               (_loc2_.getChildByName("cogs_slow") as MovieClip).play();
            }
            DisplayUtils.recursiveStop(_loc2_);
         }
      }
      
      private function showCogs(param1:String) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         Log.log("[BeltRenderer] showCogs " + param1);
         for each(_loc2_ in this._cells)
         {
            _loc3_ = _loc2_.getChildByName("content") as MovieClip;
            if(_loc3_.getChildByName("cogs_fast"))
            {
               (_loc3_.getChildByName("cogs_fast") as MovieClip).visible = param1 == Belt.FAST;
            }
            if(_loc3_.getChildByName("cogs_slow"))
            {
               (_loc3_.getChildByName("cogs_slow") as MovieClip).visible = param1 != Belt.FAST;
               if(param1 == Belt.STOPPED)
               {
                  (_loc3_.getChildByName("cogs_slow") as MovieClip).stop();
               }
               else
               {
                  (_loc3_.getChildByName("cogs_slow") as MovieClip).play();
               }
            }
            DisplayUtils.recursiveStop(_loc3_);
         }
      }
      
      override public function render() : void
      {
         var _loc2_:Graphics = null;
         super.render();
         var _loc1_:Sequence = engine.find("sequence") as Sequence;
         if(_loc1_.nextItemType != null)
         {
            this._startMC1["lcd"]["readout"].text = App.instance.text.getText("belt." + _loc1_.nextItemType);
            _loc2_ = this._startMask1.graphics;
            _loc2_.clear();
            _loc2_.beginFill(0);
            Utils.drawPieMask(_loc2_,_loc1_.nextItemTimeProgress,7);
            _loc2_.endFill();
            if(this._startMC2)
            {
               this._startMC2["lcd"]["readout"].text = App.instance.text.getText("belt." + _loc1_.nextItemType);
               _loc2_ = this._startMask2.graphics;
               _loc2_.clear();
               _loc2_.beginFill(0);
               Utils.drawPieMask(_loc2_,_loc1_.nextItemTimeProgress,7);
               _loc2_.endFill();
            }
         }
         else if(_loc1_.itemsRemaining <= 1)
         {
            this._startMC1["lcd"]["readout"].text = App.instance.text.getText("belt.done");
            this._startMask1.visible = false;
            if(this._startMC2)
            {
               this._startMC2["lcd"]["readout"].text = App.instance.text.getText("belt.done");
               this._startMask2.visible = false;
            }
         }
         else
         {
            this._startMC1["lcd"]["readout"].text = App.instance.text.getText("belt.ready");
            if(this._startMC2)
            {
               this._startMC2["lcd"]["readout"].text = App.instance.text.getText("belt.ready");
            }
         }
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         var _loc3_:String = null;
         var _loc4_:Point = null;
         var _loc5_:Sprite = null;
         super.receiveMessage(param1,param2);
         switch(param1)
         {
            case Commands.HILITE_BELT:
               _loc3_ = "red";
               if(param2.canBuy)
               {
                  _loc3_ = "green";
               }
               for each(_loc4_ in param2.tiles)
               {
                  this.hilite(_loc4_,_loc3_);
               }
               break;
            case Commands.UNHILITE_BELT:
               for each(_loc5_ in this._cells)
               {
                  this.unhilite(_loc5_);
               }
               break;
            case Messages.ENVIRONMENT_CHANGED:
               this.updateEnvironment();
               break;
            case Messages.BELT_SPEED_CHANGED:
               this.showCogs(this.belt.speedSetting);
         }
      }
      
      private function unhilite(param1:Sprite) : void
      {
         param1.transform.colorTransform = new ColorTransform();
      }
      
      private function hilite(param1:Point, param2:String = "green") : void
      {
         var _loc4_:ColorTransform = null;
         var _loc3_:Sprite = this._cells[param1.x + "_" + param1.y];
         if(param2 == "green")
         {
            _loc4_ = new ColorTransform(1,1,1,1,0,60,0);
         }
         else
         {
            _loc4_ = new ColorTransform(1,1,1,1,60,0,0);
         }
         if(Boolean(_loc3_) && Boolean(!this.belt.isEndNode(param1)) && !this.belt.isStartNode(param1))
         {
            _loc3_.transform.colorTransform = _loc4_;
         }
      }
      
      private function updateEnvironment() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Environment = null;
         var _loc5_:Boolean = false;
         var _loc6_:Sprite = null;
         var _loc7_:MovieClip = null;
         for(_loc1_ in this._cells)
         {
            _loc2_ = parseInt(_loc1_.split("_")[0]);
            _loc3_ = parseInt(_loc1_.split("_")[1]);
            _loc4_ = engine.find("environment") as Environment;
            _loc5_ = _loc4_.getValue(Environment.ACCIDENT_RISK,_loc2_,_loc3_) > 0;
            _loc6_ = this._cells[_loc1_];
            _loc7_ = _loc6_.getChildByName("content") as MovieClip;
            if(_loc5_)
            {
               _loc7_.gotoAndStop("rusty");
            }
            else
            {
               _loc7_.gotoAndStop("normal");
            }
         }
      }
      
      private function get belt() : Belt
      {
         return entity as Belt;
      }
   }
}

