package ss.game.components.ui
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.utils.MovieClipListener;
   import ss.app.App;
   import ss.app.ConfirmPopup;
   import ss.game.Commands;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Renderer;
   import ss.utils.AudioUtils;
   
   public class PauseMenuRenderer extends Renderer
   {
      
      private var _mcl:MovieClipListener;
      
      private var _confirmRestart:ConfirmPopup;
      
      private var _confirmQuit:ConfirmPopup;
      
      private var _menu:MovieClip;
      
      public function PauseMenuRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = App.instance.resources.instantiateMovieClip("ui","PauseMenuSymbol");
         addElement(_loc1_,true,true).depth = DepthManager.getDepth(DepthManager.PAUSE_MENU);
         this._mcl = new MovieClipListener(_loc1_);
         this._mcl.addEventListener(Event.CHANGE,this.onChangeFrame);
         Game.messenger.register(this,Messages.USER_PAUSED,Messages.USER_UNPAUSED);
         this._menu = _loc1_["menu"];
         this._confirmRestart = new ConfirmPopup(this._menu["confirm_restart"],this._menu["restart"]);
         this._confirmQuit = new ConfirmPopup(this._menu["confirm_quit"],this._menu["quit"]);
         this._confirmQuit.addEventListener(ConfirmPopup.CLICK,this.onClickConfirm);
         this._confirmRestart.addEventListener(ConfirmPopup.CLICK,this.onClickConfirm);
         this._mcl.mc.addEventListener(MouseEvent.CLICK,this.onClick);
         this.hide();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this._mcl.removeEventListener(Event.CHANGE,this.onChangeFrame);
         this._mcl.mc.removeEventListener(MouseEvent.CLICK,this.onClick);
         this._mcl.destroy();
         this._confirmQuit.removeEventListener(ConfirmPopup.CLICK,this.onClickConfirm);
         this._confirmRestart.removeEventListener(ConfirmPopup.CLICK,this.onClickConfirm);
         this._confirmQuit.destroy();
         this._confirmRestart.destroy();
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Messages.USER_PAUSED:
               this.show();
               break;
            case Messages.USER_UNPAUSED:
               this.hide();
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         switch(param1.target.name)
         {
            case "close":
            case "resume":
               AudioUtils.uiClose();
               Game.messenger.broadcast(Commands.USER_INVOKE_TOGGLE_PAUSE);
               break;
            case "quit":
               AudioUtils.uiConfirm();
               this._confirmQuit.show();
               this._confirmRestart.hide();
               break;
            case "restart":
               AudioUtils.uiConfirm();
               this._confirmRestart.show();
               this._confirmQuit.hide();
         }
      }
      
      private function show() : void
      {
         this._mcl.mc.visible = true;
         this._mcl.mc.gotoAndPlay("show");
         this.deactivate();
      }
      
      private function deactivate() : void
      {
         this._menu.mouseChildren = this._menu.mouseEnabled = false;
      }
      
      private function activate() : void
      {
         this._menu.mouseChildren = this._menu.mouseEnabled = true;
      }
      
      private function hide() : void
      {
         this._mcl.mc.visible = false;
         this._mcl.mc.gotoAndStop("hide");
         this._confirmQuit.hide();
         this._confirmRestart.hide();
      }
      
      private function onClickConfirm(param1:CustomEvent) : void
      {
         if(param1.data.yes)
         {
            if(param1.target == this._confirmQuit)
            {
               Game.messenger.broadcast(Commands.HARD_QUIT);
            }
            else
            {
               Game.messenger.broadcast(Commands.HARD_RESTART);
            }
         }
         else
         {
            this._confirmQuit.hide();
            this._confirmRestart.hide();
         }
      }
      
      private function onChangeFrame(param1:Event) : void
      {
         if(this._mcl.currentLabel == "done")
         {
            this._mcl.mc.stop();
            this.activate();
         }
      }
   }
}

