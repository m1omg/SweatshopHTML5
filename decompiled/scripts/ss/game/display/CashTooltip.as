package ss.game.display
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.utils.MovieClipListener;
   import ss.app.App;
   import ss.game.Game;
   import ss.game.core.Engine;
   import ss.utils.Utils;
   
   public class CashTooltip extends Tooltip
   {
      
      private var _mc:MovieClip;
      
      private var _mcl:MovieClipListener;
      
      public function CashTooltip(param1:Boolean = false)
      {
         super();
         this._mc = App.instance.resources.instantiateMovieClip("hud","TooltipSymbol");
         this._mc["tt"]["icon"].visible = false;
         addChild(this._mc);
         this._mcl = new MovieClipListener(this._mc);
         this._mcl.addEventListener(Event.CHANGE,this.onChange);
         if(param1)
         {
            Game.messenger.register(this,Engine.ENGINE_PAUSED,Engine.ENGINE_UNPAUSED);
            this._mc.gotoAndPlay("show");
         }
         else
         {
            this._mc.gotoAndStop("hold");
         }
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         if(param1 == Engine.ENGINE_PAUSED)
         {
            this._mc.stop();
         }
         if(param1 == Engine.ENGINE_UNPAUSED)
         {
            this._mc.play();
         }
      }
      
      public function set color(param1:int) : void
      {
         this._mc["tt"]["label"].textColor = param1;
         this._mc["tt"]["bonus"].textColor = param1;
      }
      
      public function setAmount(param1:Number, param2:Boolean = false, param3:Number = 0) : void
      {
         this._mc["tt"]["label"].text = Utils.formatCash(param1,param2);
         if(param3 != 0)
         {
            this._mc["tt"]["bonus"].text = "+" + param3;
            if(param1 < 10)
            {
               this._mc["tt"]["bonus"].x = 9;
            }
         }
         else
         {
            this._mc["tt"]["bonus"].text = "";
         }
      }
      
      private function onChange(param1:CustomEvent) : void
      {
         if(this._mcl.currentLabel == "show_done")
         {
            dispatchEvent(new Event(Event.COMPLETE));
            this._mc.stop();
         }
      }
      
      override public function destroy() : void
      {
         this._mcl.removeEventListener(Event.CHANGE,this.onChange);
         this._mcl.destroy();
         this._mc.stop();
         removeChild(this._mc);
      }
   }
}

