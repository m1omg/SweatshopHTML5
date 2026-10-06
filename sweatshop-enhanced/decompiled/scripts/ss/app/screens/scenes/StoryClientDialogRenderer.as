package ss.app.screens.scenes
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.fatlib.Log;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.process.Callback;
   import ss.Values;
   import ss.app.App;
   import ss.app.screens.ClientScreen;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.IMessageReceiver;
   import ss.game.core.Renderer;
   import ss.game.entities.Story;
   import ss.story.AnimationProcess;
   import ss.story.DialogTextController;
   import ss.story.RenderLineProcess;
   import ss.utils.PausableMacroProcess;
   
   public class StoryClientDialogRenderer extends Renderer implements IMessageReceiver
   {
      
      private var _dialogText:DialogTextController;
      
      private var _mc:MovieClip;
      
      private var _bossMC:MovieClip;
      
      private var _clientMC:MovieClip;
      
      private var _bubbleMC:MovieClip;
      
      private var _currentChar:String;
      
      private var _macro:PausableMacroProcess;
      
      private var _userPaused:Boolean;
      
      private var _justSkipped:Boolean;
      
      public function StoryClientDialogRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         this._mc = (entity as Story).mc;
         this._mc["hit"].alpha = 0;
         this._clientMC = this._mc["client"];
         this._bossMC = this._mc["boss"];
         this._clientMC.stop();
         this._bossMC.stop();
         this._bubbleMC = this._mc["bubble"];
         this._bubbleMC.stop();
         this._bubbleMC.useHandCursor = this._bubbleMC.buttonMode = true;
         this._currentChar = "";
         Game.messenger.register(this,Commands.RENDER_STORY_LINE,Commands.SHOW_STORY_DIALOG,Commands.HIDE_STORY_DIALOG,Messages.USER_PAUSED,Messages.USER_UNPAUSED,Messages.DIALOG_SKIPPED,ClientScreen.SHOW_CLIENT_MSG);
         this._dialogText = new DialogTextController(this._mc["text"]["text"],this._mc["cont"]);
         this._dialogText.addEventListener(DialogTextController.CHANGE_MOOD,this.onChangeMood);
         this._mc["text"].mouseEnabled = this._mc["text"].mouseChildren = false;
         this._mc["cont"].mouseEnabled = this._mc["cont"].mouseChildren = false;
         this._mc.addEventListener(MouseEvent.CLICK,this.onMouseDown,true);
         this.setMouseEnabled(false);
         this.checkSkipVisible();
      }
      
      private function onChangeMood(param1:CustomEvent) : void
      {
         var _loc2_:String = param1.data["mood"];
         this.setChar(this._currentChar,_loc2_);
      }
      
      override public function destroy() : void
      {
         this._mc.removeEventListener(MouseEvent.CLICK,this.onMouseDown);
         this._dialogText.removeEventListener(DialogTextController.CHANGE_MOOD,this.onChangeMood);
         this._dialogText.destroy();
         if(this._macro)
         {
            this._macro.destroy();
         }
         super.destroy();
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Commands.RENDER_STORY_LINE:
               this.renderLine(param2.char,param2.line);
               this.checkSkipVisible();
               break;
            case ClientScreen.SHOW_CLIENT_MSG:
               this._clientMC.gotoAndStop(param2.client);
               break;
            case Commands.SHOW_STORY_DIALOG:
               this.showDialog();
               this.checkSkipVisible();
               break;
            case Commands.HIDE_STORY_DIALOG:
               this.closeDialog();
               this.checkSkipVisible();
               break;
            case Messages.USER_PAUSED:
               if(this._macro)
               {
                  this._macro.pause();
               }
               this._userPaused = true;
               this.checkSkipVisible();
               break;
            case Messages.USER_UNPAUSED:
               if(this._macro)
               {
                  this._macro.unpause();
               }
               this._userPaused = false;
               this.checkSkipVisible();
               break;
            case Messages.DIALOG_SKIPPED:
               this._justSkipped = true;
               this.checkSkipVisible();
         }
      }
      
      private function checkSkipVisible() : void
      {
         var _loc1_:Boolean = false;
         if(Game.user.hasReadLevel || Values.SINGLE_LEVEL_MODE)
         {
            _loc1_ = true;
         }
         if(!this._mc.visible)
         {
            _loc1_ = false;
         }
         if(this._userPaused)
         {
            _loc1_ = false;
         }
         if(this._justSkipped)
         {
            _loc1_ = false;
         }
         if(_loc1_)
         {
            App.instance.globalUI.showSkip();
         }
         else
         {
            App.instance.globalUI.hideSkip();
         }
      }
      
      private function renderLine(param1:String, param2:XML) : void
      {
         if(this._macro)
         {
            this._macro.destroy();
         }
         this._macro = new PausableMacroProcess();
         this._macro.autoExecute = false;
         this._macro.autoContinue = true;
         this.checkSkipVisible();
         if(this._currentChar == "")
         {
            this._macro.addProcess(new Callback(this.setChar,[param1]));
            this._macro.addProcess(new Callback(this.setBubblePointer,[param1]));
            this._macro.addProcess(new AnimationProcess(this._bubbleMC,"enter",param1));
         }
         else if(this._currentChar != param1)
         {
            this._macro.addProcess(new Callback(this.hideText));
            this._macro.addProcess(new AnimationProcess(this._bubbleMC,"exit",this._currentChar));
            this._macro.addProcess(new Callback(this.setBubblePointer,[param1]));
            this._macro.addProcess(new AnimationProcess(this._bubbleMC,"enter",param1));
         }
         this._macro.addProcess(new Callback(this.setMouseEnabled,[true]));
         this._macro.addProcess(new RenderLineProcess(this._dialogText,param2));
         this._macro.addProcess(new Callback(this.setMouseEnabled,[false]));
         this._macro.addProcess(new Callback(this.handleLineRenderered));
         this._macro.execute();
         this._currentChar = param1;
      }
      
      private function setBubblePointer(param1:String) : void
      {
         this._bubbleMC["bubble"]["boss"].visible = param1 == "boss";
         this._bubbleMC["bubble"]["client"].visible = param1 != "boss";
      }
      
      private function showDialog() : void
      {
         this._justSkipped = false;
         this._mc.visible = true;
         this.setMouseEnabled(false);
         this.checkSkipVisible();
      }
      
      private function hideDialog() : void
      {
         this.checkSkipVisible();
      }
      
      private function closeDialog() : void
      {
         this._justSkipped = true;
         this.checkSkipVisible();
         if(this._macro)
         {
            this._macro.destroy();
         }
         this._macro = new PausableMacroProcess();
         this._macro.autoExecute = false;
         this._macro.autoContinue = true;
         this._macro.addProcess(new Callback(this.hideText));
         this._macro.addProcess(new AnimationProcess(this._bubbleMC,"exit",this._currentChar));
         this._macro.addProcess(new Callback(this.hideDialog));
         this._macro.execute();
         this._currentChar = "";
      }
      
      private function setChar(param1:String, param2:String = "prev") : void
      {
         if(param2 == "prev")
         {
            param2 = "neutral";
         }
         var _loc3_:String = param1 + "_" + param2;
         Log.log("[StoryClientDialogRenderer] setChar " + _loc3_);
         if(this._currentChar == "boss")
         {
            this._bossMC.gotoAndStop(_loc3_);
         }
         else
         {
            this._clientMC.gotoAndStop(_loc3_);
         }
      }
      
      private function hideText() : void
      {
         this._dialogText.hide();
      }
      
      private function setMouseEnabled(param1:Boolean) : void
      {
         this._mc.mouseChildren = this._mc.mouseEnabled = param1;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._dialogText.next();
      }
      
      private function handleLineRenderered() : void
      {
         Game.messenger.broadcast(Messages.DIALOG_LINE_RENDERED);
      }
   }
}

