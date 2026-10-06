package ss.story
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import org.fatlib.Log;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.interfaces.IDestroyable;
   import ss.Values;
   import ss.app.App;
   import ss.game.Game;
   import ss.utils.IPausable;
   import ss.utils.PausableDelay;
   
   public class DialogTextController extends EventDispatcher implements IDestroyable, IPausable
   {
      
      public static const CHANGE_MOOD:String = "onChangeMood";
      
      private var _continueButton:MovieClip;
      
      private var _t:TextField;
      
      private var _delay:PausableDelay;
      
      private var _finishedLine:Boolean;
      
      private var _chars:Array;
      
      private var _paused:Boolean;
      
      private var _speechWasPlaying:Boolean;
      
      public function DialogTextController(param1:TextField, param2:MovieClip)
      {
         super();
         this._delay = new PausableDelay();
         this._t = param1;
         this._t.text = "";
         this._continueButton = param2;
         this._continueButton.visible = false;
      }
      
      public function destroy() : void
      {
         this._delay.destroy();
      }
      
      public function hide() : void
      {
         this._t.text = "";
         this._continueButton.visible = false;
         this._delay.cancelAll();
         App.instance.audio.stopSpeech();
      }
      
      public function show() : void
      {
      }
      
      public function renderLine(param1:XML) : void
      {
         var _loc7_:XML = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         this.show();
         var _loc2_:String = param1.name().toString();
         this._delay.cancelAll();
         this._finishedLine = false;
         this._continueButton.visible = false;
         this._t.text = "";
         this._chars = [];
         var _loc3_:int = 0;
         var _loc4_:Number = 0;
         var _loc5_:int = 0;
         var _loc6_:Number = Values.STORY_TEXT_MEDIUM_INTERVAL;
         for each(_loc7_ in param1.children())
         {
            _loc8_ = _loc7_.nodeKind();
            switch(_loc8_)
            {
               case "text":
                  _loc9_ = _loc7_.toString();
                  _loc9_ = this.replaceVariables(_loc9_);
                  this._t.appendText(_loc9_);
                  this._delay.create(_loc4_ * 1000,App.instance.audio.startSpeech,[_loc2_]);
                  _loc11_ = 0;
                  while(_loc11_ < _loc9_.length)
                  {
                     _loc4_ += _loc6_;
                     _loc12_ = _loc9_.charAt(_loc11_);
                     this._chars.push({
                        "char":_loc12_,
                        "color":_loc5_
                     });
                     this._delay.create(_loc4_ * 1000,this.showChar,[_loc3_]);
                     _loc3_++;
                     _loc11_++;
                  }
                  this._delay.create(_loc4_ * 1000,App.instance.audio.stopSpeech);
                  break;
               case "element":
                  _loc10_ = _loc7_.name().toString();
                  switch(_loc10_)
                  {
                     case "short":
                        _loc4_ += Values.STORY_TEXT_SHORT_PAUSE;
                        break;
                     case "long":
                        _loc4_ += Values.STORY_TEXT_LONG_PAUSE;
                        break;
                     case "fast":
                        _loc6_ = Values.STORY_TEXT_FAST_INTERVAL;
                        break;
                     case "slow":
                        _loc6_ = Values.STORY_TEXT_SLOW_INTERVAL;
                        break;
                     case "medium":
                        _loc6_ = Values.STORY_TEXT_MEDIUM_INTERVAL;
                        break;
                     case "bold":
                        _loc5_ = 16711680;
                        break;
                     case "regular":
                        _loc5_ = 0;
                        break;
                     case "neutral":
                     case "happy":
                     case "confused":
                     case "sad":
                     case "angry":
                     case "evil":
                        this._delay.create(_loc4_ * 1000,this.changeMood,[_loc10_]);
                  }
            }
         }
         this._t.setTextFormat(new TextFormat(null,null,16777215));
         this._delay.create((_loc4_ + Values.STORY_TEXT_SHOW_NEXT_INTERVAL) * 1000,this.done);
      }
      
      private function changeMood(param1:String) : void
      {
         dispatchEvent(new CustomEvent(CHANGE_MOOD,{"mood":param1}));
      }
      
      public function next() : void
      {
         var _loc1_:int = 0;
         App.instance.audio.stopSpeech();
         this._delay.cancelAll();
         if(this._finishedLine)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
         else
         {
            _loc1_ = 0;
            while(_loc1_ < this._chars.length)
            {
               this.showChar(_loc1_);
               _loc1_++;
            }
            this.done();
         }
      }
      
      private function replaceVariables(param1:String) : String
      {
         var _loc2_:String = param1;
         return _loc2_.replace(/\?required_deliveries/,Game.level.numItems.toString());
      }
      
      private function done() : void
      {
         App.instance.audio.stopSpeech();
         this._finishedLine = true;
         this._continueButton.gotoAndPlay(1);
         this._continueButton.visible = true;
      }
      
      private function showChar(param1:int) : void
      {
         var index:int = param1;
         try
         {
            this._t.setTextFormat(new TextFormat(null,null,this._chars[index].color),index,index + 1);
         }
         catch(e:Error)
         {
            Log.error(e.message);
         }
      }
      
      public function pause() : void
      {
         this._delay.pause();
         this._continueButton.stop();
         this._speechWasPlaying = App.instance.audio.getSpeechPlaying();
         if(this._speechWasPlaying)
         {
            App.instance.audio.stopSpeech();
         }
      }
      
      public function unpause() : void
      {
         this._delay.unpause();
         this._continueButton.play();
         if(this._speechWasPlaying)
         {
            App.instance.audio.restartSpeech();
         }
      }
   }
}

