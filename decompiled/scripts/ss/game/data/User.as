package ss.game.data
{
   import org.fatlib.interfaces.IDestroyable;
   import ss.game.Game;
   import ss.game.Messages;
   
   public class User implements IDestroyable
   {
      
      public var completed:int = 0;
      
      public var delivered:int = 0;
      
      public var rejected:int = 0;
      
      public var hasReadLevel:Boolean = false;
      
      private var _cash:Number;
      
      public function User(param1:Number, param2:Boolean)
      {
         super();
         this._cash = param1;
         this.hasReadLevel = param2;
      }
      
      public function get numDeadItems() : int
      {
         return this.completed + this.rejected;
      }
      
      public function get cash() : Number
      {
         return this._cash;
      }
      
      public function addCash(param1:Number) : void
      {
         this._cash += param1;
         Game.messenger.broadcast(Messages.CASH_CHANGED);
      }
      
      public function removeCash(param1:Number) : void
      {
         this._cash -= param1;
         Game.messenger.broadcast(Messages.CASH_CHANGED);
      }
      
      public function destroy() : void
      {
      }
   }
}

