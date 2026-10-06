package ss.app.screens
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.fatlib.Log;
   import org.fatlib.app.Screen;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.utils.MovieClipListener;
   import ss.app.App;
   import ss.app.GlobalUI;
   import ss.app.PopupManager;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.IMessageReceiver;
   import ss.game.factory.GameFactory;
   
   public class ClientScreen extends Screen implements IMessageReceiver
   {
      
      public static const SHOW_CLIENT_MSG:String = "SHOW_CLIENT_MSG";
      
      private var _sceneID:String;
      
      private var _mcl:MovieClipListener;
      
      public function ClientScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         Log.log("[CutSceneScreen] handleAdded");
         App.instance.globalUI.addEventListener(GlobalUI.ACTION,this.onAction);
         this._sceneID = _launchVars["id"];
         var _loc1_:MovieClip = App.instance.resources.instantiateMovieClip("clients","ClientsSymbol");
         _loc1_.buttonMode = true;
         _loc1_.useHandCursor = true;
         display.addChild(_loc1_);
         var _loc2_:MovieClip = _loc1_["clip"];
         GameFactory.setupClientScene(this._sceneID,_loc2_);
         Game.messenger.register(this,Messages.CHUNK_END);
         Game.engine.start();
         var _loc3_:String = this._sceneID.split("_")[1];
         Game.messenger.broadcast(SHOW_CLIENT_MSG,{"client":"client" + _loc3_});
         App.instance.popups.addEventListener(PopupManager.OPENED,this.onPopupOpened);
         App.instance.popups.addEventListener(PopupManager.CLOSED,this.onPopupClosed);
         this._mcl = new MovieClipListener(_loc2_);
         this._mcl.addEventListener(Event.CHANGE,this.onChange);
         this._mcl.mc.gotoAndPlay("enter");
      }
      
      private function mcReady() : void
      {
         Game.messenger.broadcast(Commands.TRIGGER_DIALOG_CHUNK,{"chunk":"onReady"});
      }
      
      private function mcDone() : void
      {
         gotoScreen(_launchVars["next"]);
      }
      
      public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Messages.CHUNK_END:
               Game.messenger.broadcast(Commands.HIDE_STORY_DIALOG);
               this._mcl.mc.gotoAndPlay("exit");
         }
      }
      
      override public function handleRemoved() : void
      {
         App.instance.globalUI.removeEventListener(GlobalUI.ACTION,this.onAction);
         this._mcl.removeEventListener(Event.CHANGE,this.onChange);
         this._mcl.destroy();
         App.instance.popups.removeEventListener(PopupManager.OPENED,this.onPopupOpened);
         App.instance.popups.removeEventListener(PopupManager.CLOSED,this.onPopupClosed);
         GameFactory.tearDown();
      }
      
      private function onPopupClosed(param1:Event) : void
      {
         Game.messenger.broadcast(Messages.USER_UNPAUSED);
      }
      
      private function onPopupOpened(param1:Event) : void
      {
         Game.messenger.broadcast(Messages.USER_PAUSED);
      }
      
      private function onAction(param1:CustomEvent) : void
      {
         switch(param1.data.action)
         {
            case "skip":
               Game.messenger.broadcast(Commands.SKIP_DIALOG);
         }
      }
      
      private function done() : void
      {
         var _loc1_:String = App.SELECT_SCREEN;
         if(_launchVars["next"])
         {
            _loc1_ = _launchVars["next"];
         }
         gotoScreen(_loc1_);
      }
      
      private function onChange(param1:Event) : void
      {
         switch(this._mcl.currentLabel)
         {
            case "enter_done":
               this._mcl.mc.stop();
               this.mcReady();
               break;
            case "exit_done":
               this._mcl.mc.stop();
               this.mcDone();
               break;
            case "whoosh":
               App.instance.audio.play("whoosh");
         }
      }
   }
}

