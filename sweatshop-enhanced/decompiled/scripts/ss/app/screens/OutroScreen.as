package ss.app.screens
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import org.fatlib.Log;
   import org.fatlib.app.Screen;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.utils.MovieClipListener;
   import org.fatlib.utils.Tween;
   import ss.Values;
   import ss.app.App;
   import ss.app.GlobalUI;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.IMessageReceiver;
   import ss.game.factory.GameFactory;
   import ss.utils.Utils;
   
   public class OutroScreen extends Screen implements IMessageReceiver
   {
      
      private var _movieID:String;
      
      private var _mcl:MovieClipListener;
      
      private var _musicClean:SoundChannel;
      
      private var _musicDirty:SoundChannel;
      
      public var dirty:Number = -1;
      
      public var clean:Number = -1;
      
      public function OutroScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         Log.log("[OutroScreen] handleAdded");
         var _loc1_:MovieClip = App.instance.resources.instantiateMovieClip("outro","OutroScreenSymbol");
         display.addChild(_loc1_);
         this._movieID = _launchVars["id"];
         _loc1_.buttonMode = true;
         _loc1_.useHandCursor = true;
         display.addChild(_loc1_);
         GameFactory.setupOutroScene(this._movieID,_loc1_);
         Game.messenger.register(this,Messages.CHUNK_END);
         Game.engine.start();
         this._mcl = new MovieClipListener(_loc1_["anim"]);
         this._mcl.addEventListener(Event.CHANGE,this.onChange);
         this._mcl.mc.gotoAndPlay("enter");
         App.instance.globalUI.addEventListener(GlobalUI.ACTION,this.onAction);
         Utils.fadeFromBGColor(display);
      }
      
      private function onAction(param1:CustomEvent) : void
      {
         if(param1.data.action == "skip")
         {
            gotoScreen(App.END_CREDITS_SCREEN);
         }
      }
      
      private function mcReady() : void
      {
         Game.messenger.broadcast(Commands.TRIGGER_DIALOG_CHUNK,{"chunk":"onReady"});
      }
      
      private function mcDone() : void
      {
         gotoScreen(App.END_SCREEN);
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
      
      override protected function handleFrame() : void
      {
         this.checkFade();
      }
      
      override public function handleRemoved() : void
      {
         this._mcl.removeEventListener(Event.CHANGE,this.onChange);
         this._mcl.destroy();
         App.instance.globalUI.removeEventListener(GlobalUI.ACTION,this.onAction);
         if(this._musicDirty)
         {
            this._musicDirty.stop();
         }
         if(this._musicClean)
         {
            this._musicClean.stop();
         }
         GameFactory.tearDown();
      }
      
      private function onChange(param1:Event) : void
      {
         var _loc2_:String = this._mcl.currentLabel;
         switch(_loc2_)
         {
            case "window":
            case "limo_out":
               App.instance.audio.play(_loc2_);
               break;
            case "limo":
               App.instance.audio.play(_loc2_,0.4);
               break;
            case "crossfade":
               this.crossfade();
               break;
            case "music":
               this.startMusic();
               break;
            case "enter_done":
               this._mcl.mc.stop();
               this.mcReady();
               break;
            case "exit_done":
               this._mcl.mc.stop();
               this.mcDone();
         }
      }
      
      private function startMusic() : void
      {
         this._musicDirty = App.instance.audio.play("outro_loop_bass",0,"sfx",true);
         this._musicClean = App.instance.audio.play("outro_loop_treble",0,"sfx",true);
         this.dirty = 0;
         Tween.add(this,5000,{"dirty":1},Tween.LINEAR,this.setDirty,[-1]);
      }
      
      private function crossfade() : void
      {
         this.clean = 0;
         Tween.add(this,500,{"clean":1},Tween.EASE_OUT,this.setClean,[1]);
      }
      
      private function setDirty(param1:Number) : void
      {
         this.dirty = param1;
      }
      
      private function setClean(param1:Number) : void
      {
         this.dirty = param1;
      }
      
      private function checkFade() : void
      {
         if(Boolean(this._musicDirty) && this.dirty > -1)
         {
            this._musicDirty.soundTransform = new SoundTransform(this.dirty * Values.MUSIC_VOLUME);
         }
         if(Boolean(this._musicClean) && this.clean > -1)
         {
            this._musicClean.soundTransform = new SoundTransform(this.clean * Values.MUSIC_VOLUME);
         }
      }
   }
}

