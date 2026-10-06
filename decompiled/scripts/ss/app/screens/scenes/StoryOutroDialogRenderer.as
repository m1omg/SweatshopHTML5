package ss.app.screens.scenes
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.fatlib.Log;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.process.Callback;
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
   
   public class StoryOutroDialogRenderer extends Renderer implements IMessageReceiver
   {
      
      private var _dialogText:DialogTextController;
      
      private var _mc:MovieClip;
      
      private var _childMC:MovieClip;
      
      private var _bubbleMC:MovieClip;
      
      private var _macro:PausableMacroProcess;
      
      private var _userPaused:Boolean;
      
      private var _justSkipped:Boolean;
      
      private var _currentChar:String;
      
      public function StoryOutroDialogRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         this._mc = (entity as Story).mc;
         this._mc["hit"].alpha = 0;
         this._childMC = this._mc;
         this._childMC = this._mc["anim"]["char"];
         this._childMC.stop();
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
         this.setMood(_loc2_);
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
         App.instance.globalUI.hideSkip();
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
            this._macro.addProcess(new Callback(this.setMood,["neutral"]));
            this._macro.addProcess(new AnimationProcess(this._bubbleMC,"enter"));
         }
         else if(this._currentChar != param1)
         {
            this._macro.addProcess(new Callback(this.hideText));
            this._macro.addProcess(new AnimationProcess(this._bubbleMC,"exit"));
            this._macro.addProcess(new AnimationProcess(this._bubbleMC,"enter"));
         }
         this._macro.addProcess(new Callback(this.setMouseEnabled,[true]));
         this._macro.addProcess(new RenderLineProcess(this._dialogText,param2));
         this._macro.addProcess(new Callback(this.setMouseEnabled,[false]));
         this._macro.addProcess(new Callback(this.handleLineRenderered));
         this._macro.execute();
         this._currentChar = param1;
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
         this._macro.addProcess(new AnimationProcess(this._bubbleMC,"exit"));
         this._macro.addProcess(new Callback(this.hideDialog));
         this._macro.execute();
         this._currentChar = "";
      }
      
      private function setMood(param1:String) : void
      {
         var _loc2_:String = "child_" + param1;
         Log.log("[StoryClientDialogRenderer] setChar " + _loc2_);
         this._childMC.gotoAndStop(_loc2_);
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

