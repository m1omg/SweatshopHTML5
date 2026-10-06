package ss.app.screens.select
{
   import flash.display.BlendMode;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import org.fatlib.Log;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.interfaces.IDisplayable;
   import org.fatlib.utils.Tween;
   import ss.app.App;
   import ss.utils.IPausable;
   
   public class Weather implements IDisplayable, IDestroyable, IPausable
   {
      
      public static const NUM_DROPS:int = 150;
      
      public static const FALL_SPEED:Number = 75;
      
      public static const WIND_SPEED:Number = 5;
      
      public static const H_AREA:int = 750;
      
      public static const V_AREA:int = 500;
      
      private var _mc:MovieClip;
      
      private var _offset:int = 50;
      
      private var _drops:Vector.<MovieClip>;
      
      private var _active:Boolean;
      
      private var _inactiveCount:int;
      
      private var _lightning:MovieClip;
      
      private var _rainChannel:SoundChannel;
      
      private var _paused:Boolean;
      
      public function Weather(param1:MovieClip)
      {
         var _loc3_:MovieClip = null;
         super();
         this._mc = param1;
         this._mc.visible = false;
         this._drops = new Vector.<MovieClip>();
         this._lightning = App.instance.resources.instantiateMovieClip("ui","LightningSymbol");
         this._lightning.blendMode = BlendMode.OVERLAY;
         this._mc.addChild(this._lightning);
         var _loc2_:int = 0;
         while(_loc2_ < NUM_DROPS)
         {
            _loc3_ = App.instance.resources.instantiateMovieClip("ui","DropSymbol");
            this.resetDrop(_loc3_,false);
            _loc3_.scaleX = _loc3_.scaleY = Math.round((Math.random() * 1 + 0.3) * 10) / 10;
            this._drops.push(_loc3_);
            this._mc.addChild(_loc3_);
            _loc2_++;
         }
         this._mc.addEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      public function start() : void
      {
         Log.log("[Weather] start");
         this._mc.visible = true;
         this._mc.alpha = 0;
         this._active = true;
         Tween.add(this._mc,500,{"alpha":1});
         this._inactiveCount = 0;
         this._rainChannel = App.instance.audio.play("rain",1,"sfx",true);
      }
      
      public function stop() : void
      {
         Log.log("[Weather] stop");
         this._active = false;
         this._inactiveCount = 0;
         if(this._rainChannel)
         {
            this._rainChannel.stop();
         }
      }
      
      private function onFrame(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(this._paused)
         {
            return;
         }
         if(this._active && Math.random() < 0.02)
         {
            this._lightning.play();
            App.instance.audio.play("thunder");
         }
         if(this._inactiveCount >= NUM_DROPS)
         {
            return;
         }
         for each(_loc2_ in this._drops)
         {
            _loc2_.x -= WIND_SPEED;
            _loc2_.y += Math.random() * FALL_SPEED;
            if(_loc2_.y > V_AREA + _loc2_.height)
            {
               if(this._active)
               {
                  _loc2_["active"] = false;
                  this.resetDrop(_loc2_);
               }
               else
               {
                  if(!_loc2_["active"])
                  {
                     ++this._inactiveCount;
                  }
                  _loc2_["active"] = true;
               }
            }
         }
      }
      
      private function resetDrop(param1:MovieClip, param2:Boolean = true) : void
      {
         param1.x = Math.random() * (H_AREA + this._offset);
         if(param2)
         {
            param1.y = -param1.height - Math.random() * 100;
         }
         else
         {
            param1.y = Math.random() * V_AREA;
         }
      }
      
      public function destroy() : void
      {
         this._mc.removeEventListener(Event.ENTER_FRAME,this.onFrame);
         if(this._rainChannel)
         {
            this._rainChannel.stop();
         }
      }
      
      public function pause() : void
      {
         if(this._rainChannel)
         {
            this._rainChannel.soundTransform = new SoundTransform(0);
         }
         this._paused = true;
      }
      
      public function unpause() : void
      {
         this._paused = false;
         if(this._rainChannel)
         {
            this._rainChannel.soundTransform = new SoundTransform(1);
         }
      }
      
      public function get display() : DisplayObjectContainer
      {
         return this._mc;
      }
   }
}

