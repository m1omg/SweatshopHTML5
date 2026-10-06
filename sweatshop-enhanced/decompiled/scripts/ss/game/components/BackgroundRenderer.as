package ss.game.components
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import org.fatlib.utils.MathUtils;
   import ss.app.App;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.Renderer;
   import ss.utils.Utils;
   
   public class BackgroundRenderer extends Renderer
   {
      
      public function BackgroundRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc14_:Number = NaN;
         var _loc15_:BitmapData = null;
         var _loc1_:MovieClip = App.instance.resources.instantiateMovieClip("world" + Game.level.world,"BGSymbol");
         addElement(_loc1_).depth = DepthManager.getDepth(DepthManager.ENVIRONMENT_BG);
         var _loc2_:MovieClip = App.instance.resources.instantiateMovieClip("world" + Game.level.world,"FGSymbol");
         addElement(_loc2_).depth = DepthManager.getDepth(DepthManager.ENVIRONMENT_FG);
         var _loc3_:int = Game.level.tileWidth;
         var _loc4_:int = Game.level.tileHeight;
         var _loc5_:BitmapData = new BitmapData(_loc3_ * Game.level.mapWidth,_loc4_ * Game.level.tileHeight);
         var _loc8_:int = 0;
         var _loc9_:BitmapData = App.instance.resources.instantiateBitmapData("world" + Game.level.world,"TilesSymbol");
         var _loc10_:BitmapData = App.instance.resources.instantiateBitmapData("world" + Game.level.world,"TilesSymbol");
         _loc10_.colorTransform(_loc10_.rect,new ColorTransform(0.85,0.85,0.85));
         if(_loc9_.height > Game.level.tileHeight)
         {
            _loc14_ = Game.level.tileHeight / _loc9_.height;
            _loc15_ = _loc9_.clone();
            _loc9_.draw(_loc15_,new Matrix(_loc14_,0,0,_loc14_));
         }
         var _loc11_:Rectangle = new Rectangle(-2,0,Game.level.mapWidth + 2,Game.level.mapHeight + 2);
         _loc6_ = _loc11_.left;
         while(_loc6_ < _loc11_.right)
         {
            _loc7_ = _loc11_.top;
            while(_loc7_ < _loc11_.bottom)
            {
               _loc8_ = 0;
               if((_loc6_ + _loc7_) / 2 == int((_loc6_ + _loc7_) / 2))
               {
                  _loc8_ = 1;
               }
               if(MathUtils.rollDice(10) == 1)
               {
                  _loc8_ += 2;
               }
               if(Utils.isActiveTile(new Point(_loc6_,_loc7_),Game.level.world))
               {
                  _loc5_.copyPixels(_loc9_,new Rectangle(_loc8_ * _loc3_,0,_loc3_,_loc4_),new Point(_loc6_ * _loc3_,_loc7_ * _loc4_));
               }
               else
               {
                  _loc5_.copyPixels(_loc10_,new Rectangle(_loc8_ * _loc3_,0,_loc3_,_loc4_),new Point(_loc6_ * _loc3_,_loc7_ * _loc4_));
               }
               _loc7_++;
            }
            _loc6_++;
         }
         var _loc12_:Bitmap = new Bitmap(_loc5_);
         var _loc13_:Point = Game.canvas.tileToScreen(new Point());
         _loc12_.x = _loc13_.x;
         _loc12_.y = _loc13_.y;
         addElement(_loc12_).depth = DepthManager.getDepth(DepthManager.ENVIRONMENT_TILES);
      }
   }
}

