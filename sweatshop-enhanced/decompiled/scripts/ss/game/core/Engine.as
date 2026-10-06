package ss.game.core
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import org.fatlib.Log;
   import org.fatlib.interfaces.IDestroyable;
   import ss.Values;
   import ss.game.Game;
   
   public class Engine implements IDestroyable
   {
      
      public static const ENGINE_STARTED:String = "ENGINE_STARTED";
      
      public static const ENGINE_PAUSED:String = "ENGINE_PAUSED";
      
      public static const ENGINE_UNPAUSED:String = "ENGINE_UNPAUSED";
      
      public var timeScale:Number = 1;
      
      private var _entities:Vector.<Entity>;
      
      private var _tick:Timer;
      
      private var _oldTime:int;
      
      private var _paused:Boolean;
      
      private var _frameDispatcher:Sprite;
      
      private var _timer:GameTimer;
      
      public function Engine()
      {
         super();
         Log.log("[Engine]");
         this._entities = new Vector.<Entity>();
         this._frameDispatcher = new Sprite();
         this._timer = new GameTimer();
      }
      
      public function start() : void
      {
         this._tick = new Timer(30);
         this._tick.addEventListener(TimerEvent.TIMER,this.onTick);
         this._tick.start();
         this._oldTime = getTimer();
         this._paused = false;
         this._frameDispatcher.addEventListener(Event.ENTER_FRAME,this.onFrame);
         this._timer.start();
         if(Game.messenger)
         {
            Game.messenger.broadcast(ENGINE_STARTED);
         }
      }
      
      private function onTick(param1:TimerEvent) : void
      {
         var _loc2_:int = getTimer();
         var _loc3_:int = _loc2_ - this._oldTime;
         if(!this._paused)
         {
            if(Values.FIXED_TIMESTEP)
            {
               this.update(0.03 * this.timeScale);
            }
            else
            {
               this.update(_loc3_ * 0.001 * this.timeScale);
            }
         }
         this._oldTime = _loc2_;
      }
      
      private function onFrame(param1:Event) : void
      {
         if(!this._paused)
         {
            this.render();
         }
      }
      
      public function update(param1:Number) : void
      {
         var _loc2_:Entity = null;
         this._timer.update(param1);
         for each(_loc2_ in this._entities)
         {
            _loc2_.update(param1);
         }
      }
      
      public function render(param1:Boolean = false) : void
      {
         var _loc2_:Entity = null;
         for each(_loc2_ in this._entities)
         {
            _loc2_.render();
         }
         if(Game.canvas)
         {
            Game.canvas.render();
         }
         if(param1)
         {
            Game.canvas.forceDepthSort(true);
         }
      }
      
      public function construct(param1:Class = null) : Entity
      {
         if(!param1)
         {
            param1 = Entity;
         }
         var _loc2_:Entity = new param1();
         _loc2_.engine = this;
         _loc2_.prepare();
         this._entities.push(_loc2_);
         return _loc2_;
      }
      
      public function removeEntity(param1:String) : void
      {
         var _loc2_:Entity = this.find(param1);
         if(_loc2_)
         {
            _loc2_.destroy();
            this._entities.splice(this._entities.indexOf(_loc2_),1);
         }
      }
      
      public function resolveReference(param1:String) : *
      {
         var _loc3_:Entity = null;
         var _loc4_:Component = null;
         if(!param1 || param1.length == 0)
         {
            return null;
         }
         var _loc2_:Array = param1.split(".");
         if(_loc2_.length == 1)
         {
            return this.find(_loc2_[0]);
         }
         _loc3_ = this.find(_loc2_[0]);
         if(_loc3_)
         {
            _loc4_ = _loc3_.find(_loc2_[1]);
         }
         if(_loc4_)
         {
            return _loc4_;
         }
         return null;
      }
      
      public function destroy() : void
      {
         var _loc1_:Entity = null;
         for each(_loc1_ in this._entities)
         {
            _loc1_.destroy();
         }
         this._entities = null;
         this._tick.removeEventListener(TimerEvent.TIMER,this.onTick);
         this._frameDispatcher.removeEventListener(Event.ENTER_FRAME,this.onFrame);
         this._tick = null;
         this._frameDispatcher = null;
      }
      
      public function get paused() : Boolean
      {
         return this._paused;
      }
      
      public function get timer() : GameTimer
      {
         return this._timer;
      }
      
      public function pause() : void
      {
         this._paused = true;
         if(Game.messenger)
         {
            Game.messenger.broadcast(ENGINE_PAUSED);
         }
         this.render();
         if(Game.canvas)
         {
            Game.canvas.forceDepthSort(true);
         }
      }
      
      public function unpause() : void
      {
         this._paused = false;
         if(Game.messenger)
         {
            Game.messenger.broadcast(ENGINE_UNPAUSED);
         }
         if(Game.canvas)
         {
            Game.canvas.forceDepthSort(true);
         }
      }
      
      public function togglePause() : void
      {
         if(this._paused)
         {
            this.unpause();
         }
         else
         {
            this.pause();
         }
      }
      
      public function find(param1:String) : Entity
      {
         var _loc2_:Entity = null;
         for each(_loc2_ in this._entities)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function findByClass(param1:Class) : Vector.<Entity>
      {
         var _loc3_:Entity = null;
         var _loc2_:Vector.<Entity> = new Vector.<Entity>();
         for each(_loc3_ in this._entities)
         {
            if(_loc3_ is param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
   }
}

