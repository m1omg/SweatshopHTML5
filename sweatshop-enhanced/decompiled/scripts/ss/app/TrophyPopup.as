package ss.app
{
   import flash.display.MovieClip;
   import org.fatlib.process.MacroProcess;
   import org.fatlib.utils.Delay;
   
   public class TrophyPopup
   {
      
      private var _delay:Delay;
      
      private var _mc:MovieClip;
      
      private var _queue:MacroProcess;
      
      public function TrophyPopup(param1:MovieClip)
      {
         super();
         this._mc = param1;
         this._delay = new Delay();
         this._queue = new MacroProcess();
         this._queue.autoContinue = true;
         this._queue.autoExecute = true;
         this._mc["badge"].stop();
         this._mc["title"].stop();
         this._mc.stop();
         this._mc.visible = false;
         this._mc["hit"].alpha = 0;
         this._mc["hit"].buttonMode = true;
         this._mc["hit"].useHandCursor = true;
      }
      
      public function open(param1:String) : void
      {
         this._queue.addProcess(new ShowTrophyProcess(this._mc,param1));
         this._queue.addProcess(new FadeOutTrophyProcess(this._mc));
      }
   }
}

import flash.display.MovieClip;
import flash.events.MouseEvent;
import org.fatlib.process.AsyncProcess;
import org.fatlib.utils.Delay;
import org.fatlib.utils.DisplayUtils;
import org.fatlib.utils.Tween;
import ss.app.App;
import ss.data.Trophy;

class ShowTrophyProcess extends AsyncProcess
{
   
   private var _mc:MovieClip;
   
   private var _delay:Delay;
   
   private var _id:String;
   
   public function ShowTrophyProcess(param1:MovieClip, param2:String)
   {
      super();
      this._mc = param1;
      this._id = param2;
      this._delay = new Delay();
   }
   
   override public function execute() : void
   {
      this._mc.alpha = 1;
      this._mc.visible = true;
      this._mc["badge"].gotoAndStop(this._id);
      DisplayUtils.recursiveStop(this._mc["badge"]);
      this._mc["title"].gotoAndStop(this._id);
      this._mc.gotoAndPlay(1);
      this._delay.create(5000,this.close);
      this._mc["close"].addEventListener(MouseEvent.CLICK,this.onClose);
      this._mc["hit"].addEventListener(MouseEvent.CLICK,this.onHit);
      var _loc1_:Trophy = App.instance.trophies.getTrophy(this._id);
      if(_loc1_.karma != 0)
      {
         this._mc["karma"]["karma"].htmlText = _loc1_.karmaHTMLText;
      }
      else
      {
         this._mc["karma"].visible = false;
      }
      if(_loc1_.karma == 0)
      {
         App.instance.audio.play("cheer");
      }
      else if(_loc1_.karma > 0)
      {
         App.instance.audio.play("good");
      }
      else
      {
         App.instance.audio.play("evil");
      }
      this._mc.mouseEnabled = this._mc.mouseChildren = true;
   }
   
   private function onClose(param1:MouseEvent) : void
   {
      this.close();
   }
   
   private function onHit(param1:MouseEvent) : void
   {
      this.close();
      App.instance.globalUI.openPlayerPopup();
   }
   
   private function close() : void
   {
      this._delay.cancelAll();
      this._delay.destroy();
      this._mc["close"].removeEventListener(MouseEvent.CLICK,this.onClose);
      this._mc["hit"].removeEventListener(MouseEvent.CLICK,this.onHit);
      this._mc.mouseEnabled = this._mc.mouseChildren = false;
      done();
   }
}

class FadeOutTrophyProcess extends AsyncProcess
{
   
   private var _mc:MovieClip;
   
   public function FadeOutTrophyProcess(param1:MovieClip)
   {
      super();
      this._mc = param1;
   }
   
   override public function execute() : void
   {
      Tween.add(this._mc,500,{"alpha":0},null,this.tweenDone);
   }
   
   private function tweenDone() : void
   {
      this._mc.visible = false;
      this._mc.alpha = 1;
      done();
   }
}
