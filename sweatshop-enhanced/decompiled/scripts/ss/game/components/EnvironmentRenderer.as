package ss.game.components
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import ss.Values;
   import ss.game.Commands;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.IMessageReceiver;
   import ss.game.core.Renderer;
   import ss.game.entities.Environment;
   import ss.utils.Utils;
   
   public class EnvironmentRenderer extends Renderer implements IMessageReceiver
   {
      
      private var _elements:Object;
      
      private var _bitmapData:Object;
      
      public function EnvironmentRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         var _loc1_:String = null;
         var _loc2_:BitmapData = null;
         var _loc3_:Bitmap = null;
         positionMode = SCREEN_BASED_POSITION;
         this._elements = {};
         this._bitmapData = {};
         for each(_loc1_ in this.environment.layers)
         {
            _loc2_ = new BitmapData(Game.level.mapWidth,Game.level.mapHeight,true,16711680);
            _loc3_ = new Bitmap(_loc2_);
            _loc3_.scaleX = Game.level.tileWidth;
            _loc3_.scaleY = Game.level.tileHeight;
            _loc3_.x = Game.canvas.tileOrigin.x;
            _loc3_.y = Game.canvas.tileOrigin.y;
            addElement(_loc3_).depth = DepthManager.getDepth(DepthManager.VALUE_MAP);
            this._bitmapData[_loc1_] = _loc2_;
            this._elements[_loc1_] = _loc3_;
         }
         this.redraw();
         this.hideAll();
         Game.messenger.register(this,Messages.ENVIRONMENT_CHANGED,Commands.SHOW_OVERLAY,Commands.HIDE_OVERLAY);
      }
      
      public function show(param1:String) : void
      {
         if(this._elements[param1])
         {
            this._elements[param1].visible = true;
         }
      }
      
      public function hideAll() : void
      {
         var _loc1_:DisplayObject = null;
         for each(_loc1_ in this._elements)
         {
            _loc1_.visible = false;
         }
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Messages.ENVIRONMENT_CHANGED:
               this.redraw();
               break;
            case Commands.SHOW_OVERLAY:
               this.hideAll();
               this.show(param2.layer);
               break;
            case Commands.HIDE_OVERLAY:
               this.hideAll();
         }
      }
      
      private function redraw() : void
      {
         this.drawAccidentLayer();
         this.drawFireLayer();
      }
      
      private function drawAccidentLayer() : void
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc1_:BitmapData = this._bitmapData[Environment.ACCIDENT_RISK];
         _loc1_.fillRect(_loc1_.rect.intersection(Values.ACTIVE_TILE_AREAS[Game.level.world]),0);
         var _loc2_:int = 0;
         while(_loc2_ < Game.level.mapWidth)
         {
            _loc3_ = 0;
            while(_loc3_ < Game.level.mapHeight)
            {
               if(Utils.isActiveTile(new Point(_loc2_,_loc3_),Game.level.world))
               {
                  _loc4_ = this.environment.getValue(Environment.ACCIDENT_RISK,_loc2_,_loc3_);
                  _loc5_ = 0;
                  if(_loc4_ <= 0)
                  {
                     _loc5_ = 570490624;
                  }
                  _loc1_.setPixel32(_loc2_,_loc3_,_loc5_);
               }
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      private function drawFireLayer() : void
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc1_:BitmapData = this._bitmapData[Environment.FIRE_RISK];
         _loc1_.fillRect(_loc1_.rect.intersection(Values.ACTIVE_TILE_AREAS[Game.level.world]),0);
         var _loc2_:int = 0;
         while(_loc2_ < Game.level.mapWidth)
         {
            _loc3_ = 0;
            while(_loc3_ < Game.level.mapHeight)
            {
               if(Utils.isActiveTile(new Point(_loc2_,_loc3_),Game.level.world))
               {
                  _loc4_ = this.environment.getValue(Environment.FIRE_RISK,_loc2_,_loc3_);
                  _loc5_ = this.environment.getValue(Environment.FIRE_PROTECTION,_loc2_,_loc3_);
                  _loc6_ = 587137024;
                  if(_loc5_ > 0)
                  {
                     _loc6_ = 570490624;
                  }
                  else if(_loc4_ == 0)
                  {
                     _loc6_ = 0;
                  }
                  _loc1_.setPixel32(_loc2_,_loc3_,_loc6_);
               }
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      private function get environment() : Environment
      {
         return entity as Environment;
      }
   }
}

