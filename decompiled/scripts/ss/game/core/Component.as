package ss.game.core
{
   import org.fatlib.utils.ClassUtils;
   
   public class Component implements IMessageReceiver
   {
      
      public var entity:Entity;
      
      public var name:String;
      
      public function Component()
      {
         super();
      }
      
      public function prepare() : void
      {
      }
      
      public function destroy() : void
      {
      }
      
      public function render() : void
      {
      }
      
      public function update(param1:Number) : void
      {
      }
      
      public function get engine() : Engine
      {
         return this.entity.engine;
      }
      
      public function toString() : String
      {
         return "[" + ClassUtils.getClassName(this) + "]";
      }
      
      public function receiveMessage(param1:String, param2:Object) : void
      {
      }
   }
}

