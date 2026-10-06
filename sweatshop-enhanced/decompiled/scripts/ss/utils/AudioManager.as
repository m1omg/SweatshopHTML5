package ss.utils
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import org.fatlib.Log;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.utils.ArrayUtils;
   import ss.Values;
   import ss.app.App;
   
   public class AudioManager extends EventDispatcher implements IDestroyable
   {
      
      public static const MUTE_TOGGLED:String = "onMuteToggled";
      
      public var triggers:Array;
      
      private var _music:SoundChannel;
      
      private var _muted:Boolean;
      
      private var _musicMuted:Boolean;
      
      private var _sfxData:Object;
      
      private var _currentMusicTrack:String;
      
      private var _musicData:Object;
      
      private var _speech:SoundChannel;
      
      private var _lastSpeechSuffix:String;
      
      private var _currentMusicVolume:Number;
      
      public function AudioManager()
      {
         super();
         this._musicMuted = false;
         this._muted = false;
      }
      
      public function init(param1:Object, param2:Object) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         Log.log("[AudioManager] init");
         this._musicData = param2;
         this._sfxData = param1;
         this.triggers = [];
         for(_loc3_ in param1)
         {
            _loc4_ = param1[_loc3_]["triggers"];
            for each(_loc5_ in _loc4_.split(" "))
            {
               if(Boolean(_loc5_) && !ArrayUtils.contains(this.triggers,_loc5_))
               {
                  this.triggers.push(_loc5_);
               }
            }
         }
         this._musicData = param2;
      }
      
      public function trigger(param1:String, param2:Object = null) : void
      {
         var _loc3_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:Boolean = false;
         var _loc10_:String = null;
         var _loc4_:Number = 1;
         var _loc5_:Array = [];
         for each(_loc6_ in this._sfxData)
         {
            _loc8_ = _loc6_.triggers.split(" ");
            if(ArrayUtils.contains(_loc8_,param1))
            {
               if(_loc6_.volume)
               {
                  _loc4_ = parseFloat(_loc6_.volume);
               }
               else
               {
                  _loc4_ = 1;
               }
               _loc3_ = _loc6_.match;
               if(!_loc3_)
               {
                  _loc5_.push([_loc6_.sound,_loc4_]);
               }
               else
               {
                  _loc9_ = true;
                  for(_loc10_ in _loc3_)
                  {
                     _loc9_ &&= param2[_loc10_] == _loc3_[_loc10_];
                  }
                  if(_loc9_)
                  {
                     _loc5_.push([_loc6_.sound,_loc4_]);
                  }
               }
            }
         }
         for each(_loc7_ in _loc5_)
         {
            this.play(_loc7_[0],_loc7_[1]);
         }
      }
      
      public function startSpeech(param1:String = "hi") : void
      {
         if(this._speech)
         {
            this._speech.stop();
            this._speech = null;
         }
         this._lastSpeechSuffix = param1;
         this._speech = this.play("speech_" + param1,1,"sfx",true);
      }
      
      public function restartSpeech() : void
      {
         this.startSpeech(this._lastSpeechSuffix);
      }
      
      public function stopSpeech() : void
      {
         if(this._speech)
         {
            this._speech.stop();
            this._speech = null;
         }
      }
      
      public function getSpeechPlaying() : Boolean
      {
         return this._speech != null;
      }
      
      public function toggleMute() : void
      {
         this._muted = !this._muted;
         if(this._muted)
         {
            SoundMixer.soundTransform = new SoundTransform(0);
         }
         else
         {
            SoundMixer.soundTransform = new SoundTransform(1);
         }
         dispatchEvent(new Event(MUTE_TOGGLED));
      }
      
      private function onSoundComplete(param1:Event) : void
      {
         dispatchEvent(new CustomEvent(Event.SOUND_COMPLETE,{"channel":param1.target}));
      }
      
      public function playMusic(param1:String) : void
      {
         var s:Sound = null;
         var track:String = param1;
         this._musicMuted = false;
         if(this._music)
         {
            this._music.stop();
         }
         this._currentMusicTrack = track;
         this._currentMusicVolume = 1;
         if(this._musicData[track])
         {
            this._currentMusicVolume = this._musicData[track]["volume"];
         }
         try
         {
            s = App.instance.resources.instantiateSound("music",track);
            this._music = s.play(0,100000,new SoundTransform(Values.MUSIC_VOLUME * this._currentMusicVolume));
            Log.log("[AudioManager] playing music: " + track);
         }
         catch(r:Error)
         {
            Log.error("[AudioManager] no such symbol as \"" + track + "\"");
         }
      }
      
      public function stopMusic() : void
      {
         if(this._music)
         {
            this._music.stop();
         }
         this._currentMusicTrack = null;
      }
      
      public function destroy() : void
      {
         if(this._music)
         {
            this._music.stop();
         }
      }
      
      public function get muted() : Boolean
      {
         return this._muted;
      }
      
      public function get currentMusicTrack() : String
      {
         return this._currentMusicTrack;
      }
      
      public function muteMusic(param1:Boolean = true) : void
      {
         this._musicMuted = param1;
         this.updateMusicMuteState();
      }
      
      public function toggleMuteMusic() : void
      {
         this._musicMuted = !this._musicMuted;
         this.updateMusicMuteState();
      }
      
      public function play(param1:String, param2:Number = 1, param3:String = "sfx", param4:Boolean = false) : SoundChannel
      {
         var _loc5_:Sound = App.instance.resources.instantiateSound(param3,param1);
         var _loc6_:int = 0;
         if(param4)
         {
            _loc6_ = int.MAX_VALUE;
         }
         return _loc5_.play(0,_loc6_,new SoundTransform(Values.SFX_VOLUME * param2));
      }
      
      private function updateMusicMuteState() : void
      {
         if(!this._music)
         {
            return;
         }
         if(this._musicMuted)
         {
            this._music.soundTransform = new SoundTransform(0);
         }
         else
         {
            this._music.soundTransform = new SoundTransform(Values.MUSIC_VOLUME * this._currentMusicVolume);
         }
      }
   }
}

