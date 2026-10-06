package org.fatlib.process
{
   import flash.errors.IllegalOperationError;
   
   public class Callback extends SyncProcess
   {
      
      private var _method:Function;
      
      private var _params:Array;
      
      public function Callback(param1:Function, param2:Array = null)
      {
         super();
         this._method = param1;
         if(param2 == null)
         {
            param2 = [];
         }
         this._params = param2;
         if(this._params.length > 6)
         {
            throw new IllegalOperationError("Can\'t pass more than 6 parameters");
         }
      }
      
      public static function executeNow(param1:Function = null, param2:Array = null) : void
      {
         if(param1 != null)
         {
            new Callback(param1,param2).execute();
         }
      }
      
      override public function destroy() : void
      {
         this._method = null;
         this._params = null;
      }
      
      override public function execute() : void
      {
         switch(this._params.length)
         {
            case 0:
               this._method();
               break;
            case 1:
               this._method(this._params[0]);
               break;
            case 2:
               this._method(this._params[0],this._params[1]);
               break;
            case 3:
               this._method(this._params[0],this._params[1],this._params[2]);
               break;
            case 4:
               this._method(this._params[0],this._params[1],this._params[2],this._params[3]);
               break;
            case 5:
               this._method(this._params[0],this._params[1],this._params[2],this._params[3],this._params[4]);
               break;
            case 6:
               this._method(this._params[0],this._params[1],this._params[2],this._params[3],this._params[4],this._params[5]);
               break;
            default:
               this._method(this._params[0],this._params[1],this._params[2],this._params[3],this._params[4],this._params[5]);
         }
      }
   }
}

