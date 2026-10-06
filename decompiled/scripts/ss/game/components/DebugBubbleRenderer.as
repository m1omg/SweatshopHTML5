package ss.game.components
{
   import com.adobe.serialization.json.JSON;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import org.fatlib.display.Text;
   import org.fatlib.utils.DisplayUtils;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.IMessageReceiver;
   import ss.game.core.Renderer;
   import ss.game.core.VisualElement;
   
   public class DebugBubbleRenderer extends Renderer implements IMessageReceiver
   {
      
      private var _mc:MovieClip;
      
      private var _tf:TextField;
      
      private var _v:VisualElement;
      
      private var _touched:Boolean;
      
      public function DebugBubbleRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Messages.DEPLOYABLE_SELECTED,Messages.DEPLOYABLE_DESELECTED);
         this._mc = new MovieClip();
         var _loc1_:Point = Game.canvas.mousePosition;
         this._mc.x = 705;
         this._mc.y = 5;
         this._mc.addChild(DisplayUtils.createRectangle(0,0,200,20,16777215,false));
         this._mc.addChild(new Text(entity.id));
         var _loc2_:TextField = new TextField();
         _loc2_.defaultTextFormat = new TextFormat(null,null,10040115);
         _loc2_.text = "close";
         _loc2_.background = true;
         _loc2_.backgroundColor = 16777215;
         _loc2_.x = 170;
         _loc2_.selectable = false;
         _loc2_.autoSize = TextFieldAutoSize.LEFT;
         _loc2_.name = "close";
         this._mc.addChild(_loc2_);
         this._tf = new TextField();
         this._tf.defaultTextFormat = new TextFormat(null,null,0);
         this._tf.background = true;
         this._tf.backgroundColor = 13421772;
         this._tf.width = 200;
         this._tf.y = 20;
         this._tf.autoSize = TextFieldAutoSize.LEFT;
         offset.x = 50;
         offset.y = -100;
         this._tf.multiline = true;
         this._tf.wordWrap = true;
         this._mc.addChild(this._tf);
         this._v = addElement(this._mc,true);
         this._tf.selectable = false;
         this.hide();
         this._mc.addEventListener(MouseEvent.CLICK,this.onStartDrag,false,0,true);
         this._mc.addEventListener(MouseEvent.MOUSE_UP,this.onEndDrag,false,0,true);
         this._mc.filters = [new GlowFilter(0,1,2,2,4)];
      }
      
      private function onStartDrag(param1:MouseEvent) : void
      {
         if(param1.target.name == "close")
         {
            this.hide();
         }
         else
         {
            this._touched = true;
            this._mc.startDrag();
         }
      }
      
      private function onEndDrag(param1:MouseEvent) : void
      {
         this._mc.stopDrag();
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Messages.DEPLOYABLE_SELECTED:
               if(param2.id == entity.id)
               {
                  this.show();
                  this.focus();
               }
               else
               {
                  if(!this._touched)
                  {
                     this.hide();
                  }
                  this.unfocus();
               }
               break;
            case Messages.DEPLOYABLE_DESELECTED:
               if(!this._touched)
               {
                  this.hide();
               }
         }
      }
      
      private function hide() : void
      {
         this._mc.visible = false;
         this._touched = false;
      }
      
      private function show() : void
      {
         this._mc.visible = true;
      }
      
      private function focus() : void
      {
         this._v.depth = 10001;
      }
      
      private function unfocus() : void
      {
         this._v.depth = 10000;
      }
      
      override public function render() : void
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:* = undefined;
         super.render();
         if(this._mc.visible)
         {
            _loc1_ = "";
            _loc2_ = [];
            for(_loc3_ in com.adobe.serialization.json.JSON.decode(com.adobe.serialization.json.JSON.encode(entity)))
            {
               _loc5_ = entity[_loc3_];
               if(_loc5_ is Number)
               {
                  _loc5_ = this.trunc(_loc5_);
               }
               if(_loc5_ is Point)
               {
                  _loc5_ = "[" + this.trunc(_loc5_.x) + "," + this.trunc(_loc5_.y) + "]";
               }
               _loc2_.push({
                  "label":_loc3_,
                  "value":_loc5_
               });
            }
            _loc2_.sortOn("label");
            for each(_loc4_ in _loc2_)
            {
               _loc1_ += _loc4_.label + "=" + _loc4_.value + "\n";
            }
            this._tf.text = _loc1_;
         }
      }
      
      private function trunc(param1:Number) : String
      {
         return param1.toString().substr(0,5);
      }
   }
}

