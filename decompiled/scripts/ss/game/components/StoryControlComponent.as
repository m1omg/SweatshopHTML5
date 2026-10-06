package ss.game.components
{
   import com.adobe.serialization.json.JSON;
   import flash.events.Event;
   import flash.media.SoundChannel;
   import org.fatlib.Log;
   import org.fatlib.utils.ArrayUtils;
   import ss.Constants;
   import ss.app.App;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.core.IMessageReceiver;
   import ss.game.entities.Story;
   import ss.game.entities.Worker;
   
   public class StoryControlComponent extends Component implements IMessageReceiver
   {
      
      private var _countData:Object = {};
      
      private var _skipping:Boolean;
      
      private var _stingChannel:SoundChannel;
      
      private var _stingChunk:String;
      
      private var _willQuit:Boolean;
      
      private var _changedMusic:Boolean;
      
      public function StoryControlComponent()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Commands.SKIP_DIALOG,Messages.DIALOG_LINE_RENDERED,Messages.DEPLOYABLE_ADDED,Messages.ITEM_DELIVERED,Messages.ITEM_REJECTED,Messages.LEVEL_END,Messages.WORKER_STATE_CHANGED,Commands.TRIGGER_DIALOG_CHUNK);
         App.instance.audio.addEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
      }
      
      override public function destroy() : void
      {
         App.instance.audio.removeEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
         super.destroy();
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Commands.TRIGGER_DIALOG_CHUNK:
               this.trigger(param2.chunk);
               break;
            case Messages.LEVEL_END:
               if(Game.result.won)
               {
                  this.playStingThenTrigger("win","onWin");
               }
               else if(Game.result.reason == Constants.TOO_MANY_REJECTIONS)
               {
                  this.playStingThenTrigger("fail","onRejections");
               }
               else
               {
                  this.playStingThenTrigger("fail","onTimeUp");
               }
               break;
            case Messages.ITEM_REJECTED:
               this.handleItemRejected();
               break;
            case Messages.ITEM_DELIVERED:
               this.handleItemDelivered();
               break;
            case Messages.DEPLOYABLE_ADDED:
               this.handleDeployableAdded(param2.type);
               break;
            case Messages.WORKER_STATE_CHANGED:
               this.handleWorkerStateChanged(param2.state);
               break;
            case Messages.DIALOG_LINE_RENDERED:
               this.renderNextLine();
               break;
            case Commands.SKIP_DIALOG:
               Game.messenger.broadcast(Messages.DIALOG_SKIPPED);
               this._skipping = true;
               this.renderNextLine();
         }
      }
      
      private function playStingThenTrigger(param1:String, param2:String) : void
      {
         Game.messenger.broadcast(Commands.STORY_INVOKE_PAUSE);
         App.instance.audio.stopMusic();
         this._stingChannel = App.instance.audio.play(param1);
         this._stingChannel.addEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
         this._stingChunk = param2;
      }
      
      private function onSoundComplete(param1:Event) : void
      {
         if(this._stingChannel)
         {
            this.trigger(this._stingChunk);
            this._stingChunk = null;
            this._stingChannel.removeEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
            this._stingChannel = null;
         }
      }
      
      private function handleWorkerStateChanged(param1:String) : void
      {
         var _loc2_:String = "";
         switch(param1)
         {
            case Worker.TIRED_STATE:
               _loc2_ = "onTired";
               break;
            case Worker.EXHAUSTED_STATE:
               _loc2_ = "onExhausted";
               break;
            case Worker.DEAD_EXHAUSTION_STATE:
               _loc2_ = "onDead";
         }
         if(_loc2_ == "")
         {
            return;
         }
         var _loc3_:String = "state_" + param1 + "_count";
         if(!this._countData[_loc3_])
         {
            this._countData[_loc3_] = 0;
         }
         ++this._countData[_loc3_];
         this.trigger(_loc2_,{"count":this._countData[_loc3_]});
      }
      
      private function handleDeployableAdded(param1:String) : void
      {
         var _loc2_:String = "added_" + param1 + "_count";
         if(!this._countData[_loc2_])
         {
            this._countData[_loc2_] = 0;
         }
         ++this._countData[_loc2_];
         this.trigger("onDeploy",{
            "type":param1,
            "count":this._countData[_loc2_]
         });
      }
      
      private function handleItemRejected() : void
      {
         var _loc1_:String = "rejections_count";
         if(!this._countData[_loc1_])
         {
            this._countData[_loc1_] = 0;
         }
         ++this._countData[_loc1_];
         this.trigger("onRejection",{"count":this._countData[_loc1_]});
      }
      
      private function handleItemDelivered() : void
      {
         var _loc1_:String = "delivery_count";
         if(!this._countData[_loc1_])
         {
            this._countData[_loc1_] = 0;
         }
         ++this._countData[_loc1_];
         this.trigger("onDelivery",{"count":this._countData[_loc1_]});
      }
      
      private function trigger(param1:String, param2:Object = null) : void
      {
         if(Game.story.trigger(param1,param2))
         {
            this._skipping = false;
            this._changedMusic = false;
            Game.messenger.broadcast(Commands.STORY_INVOKE_PAUSE);
            Game.messenger.broadcast(Messages.CHUNK_START,{"chunk":Game.story.currentChunkType});
            this.renderNextLine();
         }
      }
      
      private function renderNextLine() : void
      {
         var _loc1_:XML = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         if(Game.story.hasNextLine)
         {
            _loc1_ = Game.story.getNextLine();
            _loc2_ = _loc1_.name().toString();
            _loc3_ = _loc1_.children()[0];
            switch(_loc2_)
            {
               case "broadcast":
                  this.broadcast(_loc3_);
                  this.renderNextLine();
                  break;
               case "child":
               case "boss":
               case "client1":
               case "client2":
               case "client3":
                  if(!this._skipping)
                  {
                     Game.messenger.broadcast(Commands.SHOW_STORY_DIALOG);
                     Game.messenger.broadcast(Commands.RENDER_STORY_LINE,{
                        "line":_loc1_,
                        "char":_loc2_
                     });
                  }
                  else
                  {
                     this.renderNextLine();
                  }
                  break;
               case "music":
                  if(_loc3_ == "none")
                  {
                     Game.messenger.broadcast(Commands.STOP_MUSIC);
                  }
                  else
                  {
                     Game.messenger.broadcast(Commands.PLAY_MUSIC,{"track":_loc3_});
                  }
                  this._changedMusic = true;
                  this.renderNextLine();
                  break;
               case "trophy":
                  App.instance.trophies.unlockTrophy(_loc3_);
                  this.renderNextLine();
                  break;
               case "comment":
                  this.renderNextLine();
                  break;
               case "quit":
                  this._willQuit = true;
                  this.renderNextLine();
                  break;
               default:
                  Log.warn("[StoryControlComponent] NYI - " + _loc1_.toXMLString());
                  this.renderNextLine();
            }
         }
         else if((entity as Story).context == Story.GAME)
         {
            Game.messenger.broadcast(Commands.HIDE_STORY_DIALOG);
            _loc4_ = ArrayUtils.contains(["onWin","onTimeUp","onRejections"],Game.story.currentChunkType);
            _loc5_ = Game.story.currentChunkType == "onStart";
            Game.messenger.broadcast(Messages.CHUNK_END,{"chunk":Game.story.currentChunkType});
            if(Boolean(Game.level) && (Boolean(_loc5_ || this._changedMusic)) && !_loc4_)
            {
               Game.messenger.broadcast(Commands.PLAY_MUSIC,{"track":Game.level.musicTrack});
            }
            if(Boolean(Game.level) && _loc5_)
            {
               App.instance.session.markRead(Game.level.key);
            }
            if(this._willQuit)
            {
               Game.messenger.broadcast(Commands.QUIT_LEVEL);
            }
            else
            {
               Game.messenger.broadcast(Commands.STORY_INVOKE_UNPAUSE);
            }
         }
         else
         {
            Game.messenger.broadcast(Messages.CHUNK_END);
         }
         engine.render();
      }
      
      private function broadcast(param1:String) : void
      {
         var body:Object = null;
         var text:String = param1;
         var s:Array = text.split(" ");
         var subject:String = s[0];
         if(s[1])
         {
            try
            {
               body = com.adobe.serialization.json.JSON.decode(s[1]);
            }
            catch(r:Error)
            {
               Log.error("[StoryControlComponent] JSON error trying to parse \'" + text + "\'");
            }
         }
         Game.messenger.broadcast(subject,body);
      }
   }
}

