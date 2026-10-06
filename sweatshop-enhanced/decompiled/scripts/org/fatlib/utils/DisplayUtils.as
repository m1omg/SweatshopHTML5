package org.fatlib.utils
{
   import flash.display.*;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import org.fatlib.interfaces.IIterator;
   import org.fatlib.iterators.ArrayIterator;
   import org.fatlib.iterators.ChildIterator;
   
   public class DisplayUtils
   {
      
      public function DisplayUtils()
      {
         super();
      }
      
      public static function recursiveStop(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObjectContainer = null;
         var _loc3_:int = 0;
         var _loc4_:DisplayObject = null;
         if(param1 is MovieClip)
         {
            (param1 as MovieClip).stop();
         }
         if(param1 is DisplayObjectContainer)
         {
            _loc2_ = param1 as DisplayObjectContainer;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.numChildren)
            {
               _loc4_ = _loc2_.getChildAt(_loc3_);
               recursiveStop(_loc4_);
               _loc3_++;
            }
         }
      }
      
      public static function hasFrame(param1:MovieClip, param2:String) : Boolean
      {
         var _loc3_:IIterator = new ArrayIterator(param1.currentLabels);
         while(_loc3_.hasNext)
         {
            if((_loc3_.next as FrameLabel).name == param2)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function removeChildren(param1:DisplayObjectContainer) : void
      {
         var _loc2_:ChildIterator = new ChildIterator(param1);
         while(_loc2_.hasNext)
         {
            param1.removeChild(_loc2_.next as DisplayObject);
         }
      }
      
      public static function createCircle(param1:Number = 5, param2:int = 10066329, param3:Boolean = false) : Sprite
      {
         var _loc4_:Sprite = new Sprite();
         _loc4_.graphics.clear();
         if(param3)
         {
            _loc4_.graphics.lineStyle(1,0);
         }
         _loc4_.graphics.beginFill(param2);
         _loc4_.graphics.drawCircle(0,0,param1);
         _loc4_.graphics.endFill();
         return _loc4_;
      }
      
      public static function createRectangle(param1:Number, param2:Number, param3:Number, param4:Number, param5:int = 0, param6:Boolean = false) : Sprite
      {
         var _loc7_:Sprite = new Sprite();
         _loc7_.graphics.clear();
         if(param6)
         {
            _loc7_.graphics.lineStyle(1,0);
         }
         _loc7_.graphics.beginFill(param5);
         _loc7_.graphics.drawRect(param1,param2,param3,param4);
         _loc7_.graphics.endFill();
         return _loc7_;
      }
      
      public static function centreTo(param1:DisplayObject, param2:DisplayObject) : void
      {
         param1.x = param2.x + param2.width / 2 - param1.width / 2;
         param1.y = param2.y + param2.height / 2 - param1.height / 2;
      }
      
      public static function centreToParent(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObjectContainer = param1.parent;
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:Number = _loc2_.width / 2;
         var _loc4_:Number = _loc2_.height / 2;
         param1.x = _loc3_ - param1.width / 2;
         param1.y = _loc4_ - param1.height / 2;
      }
      
      public static function centre(param1:DisplayObject) : void
      {
         param1.x = -(param1.width / 2);
         param1.y = -(param1.height / 2);
      }
      
      public static function assignTabOrder(param1:DisplayObjectContainer) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:InteractiveObject = null;
         var _loc8_:Rectangle = null;
         var _loc9_:Point = null;
         var _loc10_:Number = NaN;
         var _loc2_:Array = getChildren(param1);
         var _loc3_:Array = [];
         for each(_loc4_ in _loc2_)
         {
            if(_loc4_ is InteractiveObject)
            {
               if((_loc4_ as InteractiveObject).tabEnabled)
               {
                  _loc3_.push(_loc4_);
               }
            }
         }
         _loc5_ = [];
         _loc6_ = 0;
         while(_loc6_ < _loc3_.length)
         {
            _loc7_ = _loc3_[_loc6_];
            _loc8_ = _loc7_.getRect(_loc7_.parent);
            _loc9_ = new Point(_loc8_.left + _loc7_.width / 2,_loc8_.top + _loc7_.height / 2);
            _loc9_ = _loc7_.localToGlobal(_loc9_);
            _loc10_ = _loc9_.y + _loc9_.x / _loc7_.stage.height;
            _loc5_.push({
               "obj":_loc7_,
               "score":_loc10_
            });
            _loc6_++;
         }
         _loc5_.sortOn("score",Array.NUMERIC);
         _loc6_ = 0;
         while(_loc6_ < _loc5_.length)
         {
            _loc7_ = _loc5_[_loc6_]["obj"];
            _loc7_.tabIndex = _loc6_;
            _loc6_++;
         }
      }
      
      public static function quickBlitText(param1:String, param2:BitmapData, param3:Point = null, param4:int = 16711680) : void
      {
         if(param3 == null)
         {
            param3 = new Point();
         }
         var _loc5_:TextField = new TextField();
         _loc5_.autoSize = TextFieldAutoSize.LEFT;
         _loc5_.text = param1;
         _loc5_.textColor = param4;
         var _loc6_:Matrix = new Matrix();
         _loc6_.translate(param3.x,param3.y);
         param2.draw(_loc5_,_loc6_);
      }
      
      public static function blit(param1:BitmapData, param2:BitmapData, param3:Rectangle = null, param4:Matrix = null, param5:ColorTransform = null) : void
      {
         var _loc6_:Boolean = false;
         if(param3 == null)
         {
            param3 = param1.rect;
         }
         if(param4 == null)
         {
            param4 = new Matrix();
         }
         if(param5 == null)
         {
            _loc6_ = true;
            param5 = new ColorTransform();
         }
         if(param4.a == 1 && param4.b == 0 && param4.c == 0 && param4.d == 1 && _loc6_)
         {
            param2.copyPixels(param1,param3,new Point(int(param4.tx),int(param4.ty)));
         }
         else
         {
            param2.draw(param1,param4,param5);
         }
      }
      
      private static function getChildren(param1:DisplayObjectContainer, param2:Array = null) : Array
      {
         var _loc4_:DisplayObject = null;
         if(!param2)
         {
            param2 = [];
         }
         var _loc3_:IIterator = new ChildIterator(param1);
         while(_loc3_.hasNext)
         {
            _loc4_ = _loc3_.next;
            param2.push(_loc4_);
            if(_loc4_ is DisplayObjectContainer)
            {
               param2.concat(getChildren(_loc4_ as DisplayObjectContainer,param2));
            }
         }
         return param2;
      }
   }
}

