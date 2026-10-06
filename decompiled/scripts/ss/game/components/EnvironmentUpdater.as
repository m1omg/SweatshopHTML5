package ss.game.components
{
   import org.fatlib.interfaces.IIterator;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.core.Entity;
   import ss.game.core.IMessageReceiver;
   import ss.game.data.Effect;
   import ss.game.data.IEffector;
   import ss.game.entities.Environment;
   
   public class EnvironmentUpdater extends Component implements IMessageReceiver
   {
      
      public function EnvironmentUpdater()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Messages.BELT_SPEED_CHANGED,Messages.DEPLOYABLE_ADDED,Messages.DEPLOYABLE_REMOVED,Messages.FEATURE_ACTIVATED,Messages.FEATURE_DEACTIVATED,Messages.UNIT_UPGRADED,Commands.FORCE_UPDATE_ENVIRONMENT);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         this.refresh();
      }
      
      private function refresh() : void
      {
         var _loc2_:IEffector = null;
         var _loc3_:IIterator = null;
         var _loc4_:Effect = null;
         this.map.resetToBase();
         var _loc1_:Vector.<Entity> = engine.findByClass(IEffector);
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = _loc2_.getActiveEffectsIterator();
            if(_loc3_)
            {
               while(_loc3_.hasNext)
               {
                  _loc4_ = _loc3_.next;
                  this.map.applyEffect(_loc4_);
               }
            }
         }
         Game.messenger.broadcast(Messages.ENVIRONMENT_CHANGED);
      }
      
      private function get map() : Environment
      {
         return entity as Environment;
      }
   }
}

