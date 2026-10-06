package ss.app.screens.game
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.fatlib.app.Screen;
   import org.fatlib.process.Callback;
   import org.fatlib.process.MacroProcess;
   import ss.Values;
   import ss.app.App;
   import ss.data.LevelResult;
   import ss.utils.DelayProcess;
   import ss.utils.ScoreUtils;
   import ss.utils.Utils;
   
   public class LevelWonDialog extends Screen
   {
      
      private var _mc:MovieClip;
      
      private var _macro:MacroProcess;
      
      public function LevelWonDialog()
      {
         super();
         this._mc = App.instance.resources.instantiateMovieClip("ui","WinPopupSymbol");
         Utils.tweenInPanel(this._mc,true);
         App.instance.audio.play("cheer");
         this._mc["record"].visible = false;
         this._mc["record"].stop();
         this._mc.addEventListener(MouseEvent.CLICK,this.onClick);
         this._mc["time_max"].text = Values.TIME_WEIGHT;
         this._mc["cash_max"].text = Values.CASH_WEIGHT;
         this._mc["quality_max"].text = Values.QUALITY_WEIGHT;
         var _loc1_:LevelResult = App.instance.session.lastResult;
         var _loc2_:Number = _loc1_.timeScore;
         var _loc3_:Number = _loc1_.cashScore;
         var _loc4_:Number = _loc1_.qualityScore;
         var _loc5_:Number = _loc1_.score;
         var _loc6_:String = ScoreUtils.getMedal(_loc1_.score);
         this._macro = new MacroProcess();
         this._macro.addProcess(new DelayProcess(500));
         this._macro.addProcess(new CountTextProcess(this._mc["quality"],_loc4_));
         this._macro.addProcess(new DelayProcess(500));
         this._macro.addProcess(new CountTextProcess(this._mc["time"],_loc2_));
         this._macro.addProcess(new DelayProcess(500));
         this._macro.addProcess(new CountTextProcess(this._mc["cash"],_loc3_));
         this._macro.addProcess(new DelayProcess(1000));
         this._macro.addProcess(new CountTextProcess(this._mc["total"],_loc5_,"%"));
         this._macro.addProcess(new DelayProcess(1000));
         this._macro.addProcess(new Callback(this._mc["medal"].gotoAndPlay,[_loc6_]));
         this._macro.addProcess(new Callback(App.instance.audio.play,[_loc6_]));
         if(_loc1_.isNewRecord)
         {
            this._macro.addProcess(new DelayProcess(400));
            this._macro.addProcess(new Callback(this.showNewRecord));
            this._macro.addProcess(new DelayProcess(400));
         }
         else
         {
            this._macro.addProcess(new DelayProcess(500));
         }
         this._macro.addProcess(new Callback(this.showContButton));
         this._macro.execute();
         this._mc["cont"].visible = false;
      }
      
      override public function get display() : DisplayObjectContainer
      {
         return this._mc;
      }
      
      private function showNewRecord() : void
      {
         this._mc["record"].visible = true;
         this._mc["record"].gotoAndPlay(1);
      }
      
      private function showContButton() : void
      {
         this._mc["cont"].visible = true;
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(param1.target.name == "cont")
         {
            App.instance.screens.goto(App.RESULTS_SCREEN);
         }
      }
      
      override public function destroy() : void
      {
         this._mc.removeEventListener(MouseEvent.CLICK,this.onClick);
      }
   }
}

import flash.events.Event;
import flash.text.TextField;
import org.fatlib.process.AsyncProcess;
import org.fatlib.utils.Tween;

class CountTextProcess extends AsyncProcess
{
   
   private var _tf:TextField;
   
   private var _finalValue:Number;
   
   private var _suffix:String;
   
   public var textValue:Number;
   
   public function CountTextProcess(param1:TextField, param2:Number, param3:String = "")
   {
      super();
      this._tf = param1;
      this._tf.text = "";
      this._finalValue = param2;
      this._suffix = param3;
   }
   
   override public function execute() : void
   {
      var _loc1_:Number = 300;
      this._tf.addEventListener(Event.ENTER_FRAME,this.onFrame);
      this.textValue = 0;
      Tween.add(this,_loc1_,{"textValue":this._finalValue},Tween.EASE_OUT,this.countTextDone);
   }
   
   private function onFrame(param1:Event) : void
   {
      this._tf.text = Math.ceil(this.textValue).toString() + this._suffix;
   }
   
   private function countTextDone() : void
   {
      this._tf.removeEventListener(Event.ENTER_FRAME,this.onFrame);
      this._tf.text = this._finalValue.toString() + this._suffix;
      done();
   }
}
