package ss.game.display
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.utils.MovieClipListener;
   import ss.app.App;
   
   public class IconTooltip extends Tooltip
   {
      
      private var _mc:MovieClip;
      
      private var _mcl:MovieClipListener;
      
      public function IconTooltip(param1:String)
      {
         super();
         this._mc = App.instance.resources.instantiateMovieClip("hud","TooltipSymbol");
         this._mc["tt"]["label"].visible = false;
         this._mc["tt"]["bonus"].visible = false;
         this._mc["tt"]["icon"].gotoAndStop(param1);
         addChild(this._mc);
         this._mcl = new MovieClipListener(this._mc);
         this._mcl.addEventListener(Event.CHANGE,this.onChange);
         this._mc.gotoAndPlay("show");
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

