package ss.utils
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import org.fatlib.display.Text;
   import org.fatlib.metrics.FPS;
   import org.fatlib.utils.DisplayUtils;
   import org.fatlib.utils.Tween;
   import ss.Constants;
   import ss.Values;
   import ss.app.App;
   
   public class Utils
   {
      
      public function Utils()
      {
         super();
      }
      
      public static function isNeighbouring(param1:Point, param2:Point) : Boolean
      {
         var _loc3_:Point = param1.subtract(param2);
         if(_loc3_.x == 0 && (_loc3_.y == 1 || _loc3_.y == -1))
         {
            return true;
         }
         if(_loc3_.y == 0 && (_loc3_.x == 1 || _loc3_.x == -1))
         {
            return true;
         }
         if((_loc3_.x == -1 || _loc3_.x == 1) && (_loc3_.y == -1 || _loc3_.y == 1))
         {
            return true;
         }
         return false;
      }
      
      public static function isAdjacent(param1:Point, param2:Point) : Boolean
      {
         var _loc3_:Point = param1.subtract(param2);
         if(_loc3_.x < 0)
         {
            _loc3_.x = -_loc3_.x;
         }
         if(_loc3_.y < 0)
         {
            _loc3_.y = -_loc3_.y;
         }
         if(_loc3_.x > 1 || _loc3_.y > 1)
         {
            return false;
         }
         return _loc3_.x * _loc3_.y == 0;
      }
      
      public static function drawCircle(param1:BitmapData, param2:int, param3:int, param4:int, param5:int, param6:Rectangle = null) : void
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc7_:int = -param4;
         while(_loc7_ <= param4)
         {
            _loc8_ = -param4;
            while(_loc8_ <= param4)
            {
               if(!(Boolean(param6) && !param6.containsPoint(new Point(param2 + _loc7_,param3 + _loc8_))))
               {
                  _loc9_ = _loc7_ * _loc7_ + _loc8_ * _loc8_;
                  if(_loc9_ < param4 * param4)
                  {
                     param1.setPixel32(param2 + _loc7_,param3 + _loc8_,param5);
                  }
               }
               _loc8_++;
            }
            _loc7_++;
         }
      }
      
      public static function hideChildren(param1:DisplayObjectContainer) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.numChildren)
         {
            param1.getChildAt(_loc2_).visible = false;
            _loc2_++;
         }
      }
      
      public static function applyObjectFilter(param1:DisplayObject, param2:int = 2) : void
      {
         var _loc3_:GlowFilter = new GlowFilter(2377287,1,param2,param2,10,2);
         param1.filters = [_loc3_];
      }
      
      public static function isActiveTile(param1:Point, param2:int) : Boolean
      {
         var _loc3_:Rectangle = Values.ACTIVE_TILE_AREAS[param2];
         return _loc3_.containsPoint(param1);
      }
      
      public static function getFeatureSymbol(param1:String) : String
      {
         switch(param1)
         {
            case "water":
               return "WaterSymbol";
            case "cola":
               return "ColaSymbol";
            case "juice":
               return "JuiceSymbol";
            case "heater":
               return "HeaterSymbol";
            case "fan":
               return "FanSymbol";
            case "toilet":
               return "ToiletSymbol";
            case "sign":
               return "SignSymbol";
            case "radio":
               return "RadioSymbol";
            case "tannoy":
               return "TannoySymbol";
            default:
               return "RadioSymbol";
         }
      }
      
      public static function getUnitResourceName(param1:String, param2:String = null) : String
      {
         var _loc3_:String = null;
         switch(param1)
         {
            case "hat_maker":
            case "shirt_maker":
            case "shoe_maker":
            case "bag_maker":
            case "child":
               _loc3_ = param1 + "_" + param2;
               break;
            default:
               _loc3_ = param1;
         }
         return _loc3_;
      }
      
      public static function formatCash(param1:Number, param2:Boolean = false) : String
      {
         var _loc3_:String = null;
         if(param1 < 0)
         {
            _loc3_ = "-$" + (-param1).toString();
         }
         else if(param2)
         {
            _loc3_ = "+$" + param1.toString();
         }
         else
         {
            _loc3_ = "$" + param1.toString();
         }
         return _loc3_;
      }
      
      public static function desaturated() : ColorMatrixFilter
      {
         return new ColorMatrixFilter([0.3086000084877014,0.6093999743461609,0.0820000022649765,0,0,0.3086000084877014,0.6093999743461609,0.0820000022649765,0,0,0.3086000084877014,0.6093999743461609,0.0820000022649765,0,0,0,0,0,1,0]);
      }
      
      public static function argbToHex(param1:int, param2:int, param3:int, param4:int) : int
      {
         return param4 + param3 * 256 + param2 * 65536 + param1 * 16777216;
      }
      
      public static function capitalize(param1:String) : String
      {
         var _loc2_:String = param1.substr(0,1);
         var _loc3_:String = param1.substr(1,param1.length);
         return _loc2_.toUpperCase() + _loc3_.toLowerCase();
      }
      
      public static function getItemSymbol(param1:String) : MovieClip
      {
         var _loc2_:Object = {
            "hat":"HatSymbol",
            "shirt":"ShirtSymbol",
            "shoes":"ShoesSymbol",
            "bag":"BagSymbol",
            "hat_special":"SpecialSymbol",
            "bag_special":"SpecialSymbol",
            "shoes_special":"SpecialSymbol",
            "shirt_special":"SpecialSymbol"
         };
         return App.instance.resources.instantiateMovieClip("item",_loc2_[param1]);
      }
      
      public static function getItemFirstFrame(param1:String, param2:int) : int
      {
         var _loc3_:int = 0;
         switch(param1)
         {
            case "hat":
            case "shirt":
            case "bag":
            case "shoes":
               _loc3_ = (param2 - 1) * 4;
               break;
            case "bag_special":
            case "shirt_special":
               _loc3_ = 0;
               break;
            case "shoes_special":
               _loc3_ = 4;
               break;
            case "hat_special":
               _loc3_ = 8;
         }
         return _loc3_;
      }
      
      public static function drawPieMask(param1:Graphics, param2:Number, param3:Number = 50, param4:Number = 0, param5:Number = 0, param6:Number = 0, param7:int = 3) : void
      {
         param1.moveTo(param4,param5);
         if(param7 < 3)
         {
            param7 = 3;
         }
         param3 /= Math.cos(1 / param7 * Math.PI);
         var _loc8_:int = Math.floor(param2 * param7);
         var _loc9_:int = 0;
         while(_loc9_ <= _loc8_)
         {
            lineToRadians(param1,_loc9_ / param7 * (Math.PI * 2) + param6,param3,param4,param5);
            _loc9_++;
         }
         if(param2 * param7 != _loc8_)
         {
            lineToRadians(param1,param2 * (Math.PI * 2) + param6,param3,param4,param5);
         }
      }
      
      public static function clamp(param1:Number, param2:Number, param3:Number) : Number
      {
         if(param1 < param2)
         {
            param1 = param2;
         }
         if(param1 > param3)
         {
            param1 = param3;
         }
         return param1;
      }
      
      public static function tweenIn(param1:MovieClip, param2:int = 100, param3:Number = 1, param4:Boolean = false) : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         param1.alpha = 0;
         var _loc5_:Number = param1.scaleX;
         var _loc6_:Number = param1.scaleY;
         param1.scaleX = _loc5_ * param3;
         param1.scaleY = _loc6_ * param3;
         if(param4)
         {
            _loc7_ = param1.x;
            _loc8_ = param1.y;
            param1.x = -(Constants.SCREEN_W * param3 - Constants.SCREEN_W) / 2;
            param1.y = -(Constants.SCREEN_H * param3 - Constants.SCREEN_H) / 2;
            Tween.add(param1,100,{
               "alpha":1,
               "scaleX":_loc5_,
               "scaleY":_loc6_,
               "x":_loc7_,
               "y":_loc8_
            });
         }
         else
         {
            Tween.add(param1,100,{
               "alpha":1,
               "scaleX":_loc5_,
               "scaleY":_loc6_
            });
         }
      }
      
      public static function tweenInTooltip(param1:MovieClip) : void
      {
         tweenIn(param1,100,1);
      }
      
      public static function tweenInPanel(param1:MovieClip, param2:Boolean = false) : void
      {
         tweenIn(param1,150,1.2,param2);
      }
      
      private static function lineToRadians(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         param1.lineTo(Math.cos(param2) * param3 + param4,Math.sin(param2) * param3 + param5);
      }
      
      public static function fadeFromBGColor(param1:DisplayObjectContainer, param2:int = 200) : void
      {
         var _loc3_:Sprite = DisplayUtils.createRectangle(0,0,700,600,Values.BG_COLOR);
         _loc3_.alpha = 1;
         param1.addChild(_loc3_);
         Tween.add(_loc3_,param2,{"alpha":0},null,param1.removeChild,[_loc3_]);
      }
      
      public static function createDebugInfo() : Sprite
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.addChild(DisplayUtils.createRectangle(0,0,50,30,16777215)).alpha = 0.6;
         var _loc2_:DisplayObject = _loc1_.addChild(new FPS(0));
         var _loc3_:Text = new Text("v" + Constants.VERSION);
         _loc3_.y = 12;
         _loc1_.addChild(_loc3_);
         _loc1_.mouseChildren = _loc1_.mouseEnabled = false;
         return _loc1_;
      }
   }
}

