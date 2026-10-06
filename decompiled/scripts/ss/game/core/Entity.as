package ss.game.core
{
   import flash.geom.Point;
   import org.fatlib.Log;
   import org.fatlib.utils.ClassUtils;
   
   public class Entity
   {
      
      public static const ON_STATE_CHANGED:String = "ON_STATE_CHANGED";
      
      public var id:String;
      
      public var age:Number = 0;
      
      public var engine:Engine;
      
      private var _state:String;
      
      private var _inited:Boolean = false;
      
      private var _components:Vector.<Component>;
      
      private var _position:Point = new Point();
      
      public function Entity()
      {
         super();
      }
      
      public function get position() : Point
      {
         return this._position.clone();
      }
      
      public function set position(param1:Point) : void
      {
         this._position = param1;
      }
      
      public function prepare() : void
      {
      }
      
      public function changeState(param1:String) : void
      {
         this._state = param1;
         this.broadcastLocalMessage(ON_STATE_CHANGED);
      }
      
      public function get state() : String
      {
         return this._state;
      }
      
      public function destroy() : void
      {
         var _loc1_:Component = null;
         for each(_loc1_ in this._components)
         {
            _loc1_.destroy();
         }
      }
      
      final public function init(param1:String = null) : void
      {
         var _loc2_:Component = null;
         if(this._inited)
         {
            throw new Error("already inited");
         }
         Log.log(this + " init as " + param1);
         if(param1)
         {
            this.id = param1;
         }
         this._inited = true;
         for each(_loc2_ in this._components)
         {
            _loc2_.prepare();
         }
      }
      
      final public function update(param1:Number) : void
      {
         var _loc2_:Component = null;
         if(!this._inited)
         {
            throw new Error("call init() before updating");
         }
         this.age += param1;
         for each(_loc2_ in this._components)
         {
            _loc2_.update(param1);
         }
      }
      
      final public function render() : void
      {
         var _loc1_:Component = null;
         if(!this._inited)
         {
            throw new Error("call init() before rendering");
         }
         for each(_loc1_ in this._components)
         {
            _loc1_.render();
         }
      }
      
      final public function addComponent(param1:Component, param2:String = null) : void
      {
         Log.log(this + " adding component " + param1);
         param1.entity = this;
         param1.name = param2;
         if(!this._components)
         {
            this._components = new Vector.<Component>();
         }
         this._components.push(param1);
         if(this._inited)
         {
            param1.prepare();
         }
      }
      
      final public function broadcastLocalMessage(param1:String, param2:Object = null) : void
      {
         var _loc3_:Component = null;
         for each(_loc3_ in this._components)
         {
            _loc3_.receiveMessage(param1,param2);
         }
      }
      
      final public function removeComponent(param1:String) : void
      {
         throw new Error("NYI");
      }
      
      final public function find(param1:String) : Component
      {
         var _loc2_:Component = null;
         for each(_loc2_ in this._components)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function toString() : String
      {
         if(this.id)
         {
            return "[Entity:" + ClassUtils.getClassName(this) + " " + this.id + "]";
         }
         return "[Entity:" + ClassUtils.getClassName(this) + "]";
      }
   }
}

