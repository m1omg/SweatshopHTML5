package com.omniture
{
   import flash.utils.clearInterval;
   
   public dynamic class ActionSource_Module_Media
   {
      
      private var autoTrackDone:Boolean = false;
      
      public var playerName:String;
      
      public var trackVars:String;
      
      private var monitorList:Array;
      
      private var list:Object;
      
      public var trackWhilePlaying:Boolean = false;
      
      public var trackMilestones:String = "";
      
      public var trackSeconds:Number = 0;
      
      private var autoTrackInterval:Number;
      
      public var trackEvents:String;
      
      private var _autoTrack:Boolean = false;
      
      private var s:Object;
      
      public function ActionSource_Module_Media(param1:Object)
      {
         super();
         var _loc2_:Object = this;
         _loc2_.s = param1;
         _loc2_.monitorList = null;
      }
      
      public function listenerMedia_scrubbing(param1:*) : *
      {
         this.listenerMedia.scrubbing(param1);
      }
      
      public function stop(param1:String, param2:Number) : *
      {
         this.event(param1,2,param2);
      }
      
      public function listenerBrightcove_seek(param1:*) : *
      {
         this.listenerBrightcove.seek(param1);
      }
      
      public function listenerMedia_complete(param1:*) : *
      {
         this.listenerMedia.complete(param1);
      }
      
      public function doAutoTrack() : *
      {
         var _loc1_:Object = this;
         if(!_loc1_.s.isSet(_loc1_.s.account) || !_loc1_.s.isSet(_loc1_.s.movie))
         {
            return;
         }
         clearInterval(_loc1_.autoTrackInterval);
         if(Boolean(_loc1_._autoTrack) && !_loc1_.autoTrackDone)
         {
            if(_loc1_.attach(_loc1_.s.movie))
            {
               _loc1_.autoTrackDone = true;
            }
            else
            {
               _loc1_.autoTrackInterval = _loc1_.s.setupInterval(this,"doAutoTrack",1000,null);
            }
         }
      }
      
      public function listenerMedia_click(param1:*) : *
      {
         this.listenerMedia.click(param1);
      }
      
      private function event(param1:String, param2:Number, param3:Number) : *
      {
         var _loc5_:Object = null;
         var _loc10_:Array = null;
         var _loc11_:Number = NaN;
         var _loc18_:String = null;
         var _loc4_:Object = this;
         var _loc6_:Date = new Date();
         var _loc7_:Number = Math.floor(_loc6_.getTime() / 1000);
         var _loc8_:Number = Number(_loc4_.trackSeconds);
         var _loc9_:String = _loc4_.trackMilestones;
         var _loc12_:String = "--**--";
         var _loc13_:Boolean = true;
         var _loc14_:String = null;
         var _loc15_:String = _loc4_.trackVars;
         var _loc16_:String = _loc4_.trackEvents;
         var _loc17_:String = "media";
         var _loc19_:Object = new Object();
         param1 = _loc4_.cleanName(param1);
         _loc5_ = Boolean(_loc4_.s.isSet(param1)) && Boolean(_loc4_.s.isSet(_loc4_.list)) && Boolean(_loc4_.s.isSet(_loc4_.list[param1])) ? _loc4_.list[param1] : null;
         if(_loc4_.s.isSet(_loc5_))
         {
            _loc19_.name = param1;
            _loc19_.length = _loc5_.length;
            _loc19_.playerName = _loc5_.playerName;
            if(_loc5_.lastTrackOffset < 0)
            {
               _loc19_.event = "OPEN";
            }
            else
            {
               _loc19_.event = param2 == 1 ? "PLAY" : (param2 == 2 ? "STOP" : (param2 == 3 ? "MONITOR" : "CLOSE"));
            }
            _loc19_.openTime = new Date();
            _loc19_.openTime.setTime(_loc5_.timestamp * 1000);
            if(param2 > 2 || param2 != _loc5_.lastEventType && (param2 != 2 || _loc5_.lastEventType == 1))
            {
               _loc14_ = "Media." + param1;
               _loc18_ = "" + escape(_loc5_.name) + _loc12_ + _loc5_.length + _loc12_ + escape(_loc5_.playerName) + _loc12_;
               if(_loc4_.s.isSet(param2))
               {
                  if(param3 < 0 && _loc5_.lastEventTimestamp > 0)
                  {
                     param3 = _loc7_ - _loc5_.lastEventTimestamp + _loc5_.lastEventOffset;
                     param3 = param3 < _loc5_.length ? param3 : _loc5_.length - 1;
                  }
                  param3 = Math.floor(param3);
                  if(param2 >= 2 && _loc5_.lastEventOffset < param3)
                  {
                     _loc5_.timePlayed += param3 - _loc5_.lastEventOffset;
                     _loc5_.timePlayedSinseTrack += param3 - _loc5_.lastEventOffset;
                  }
                  if(param2 <= 2)
                  {
                     _loc5_.session += (param2 == 1 ? "S" : "E") + param3;
                     _loc5_.lastEventType = param2;
                  }
                  else if(_loc5_.lastEventType != 1)
                  {
                     _loc4_.event(param1,1,param3);
                  }
                  _loc5_.lastEventTimestamp = _loc7_;
                  _loc5_.lastEventOffset = param3;
                  _loc18_ += "" + _loc5_.timePlayed + _loc12_ + _loc5_.timestamp + _loc12_ + (Boolean(_loc4_.s.isSet(_loc4_.trackWhilePlaying)) && _loc5_.lastTrackOffset >= 0 ? "L" + _loc5_.lastTrackOffset : "") + _loc5_.session + (param2 != 2 ? (_loc4_.s.isSet(_loc4_.trackWhilePlaying) ? "L" : "E") + param3 : "");
                  if(_loc4_.s.isSet(_loc4_.trackWhilePlaying))
                  {
                     _loc14_ = null;
                     _loc17_ = "m_o";
                     if(param2 != 4)
                     {
                        _loc19_.offset = param3;
                        _loc19_.percent = (_loc19_.offset + 1) / _loc19_.length * 100;
                        _loc19_.percent = _loc19_.percent > 100 ? 100 : Math.floor(_loc19_.percent);
                        _loc19_.timePlayed = _loc5_.timePlayed;
                        if(_loc4_.s.isSet(_loc4_.monitor))
                        {
                           _loc4_.monitor(_loc4_.s,_loc19_);
                        }
                     }
                     if(_loc5_.lastTrackOffset < 0)
                     {
                        _loc17_ = "m_s";
                     }
                     else if(param2 == 4)
                     {
                        _loc17_ = "m_i";
                     }
                     else
                     {
                        _loc13_ = false;
                        _loc15_ = _loc16_ = "None";
                        _loc8_ = _loc4_.s.isSet(_loc8_) ? parseInt("" + _loc8_) : 0;
                        _loc10_ = _loc4_.s.isSet(_loc9_) ? _loc9_.split(",") : null;
                        if(Boolean(_loc4_.s.isSet(_loc8_)) && _loc5_.timePlayedSinseTrack >= _loc8_)
                        {
                           _loc13_ = true;
                        }
                        else if(_loc4_.s.isSet(_loc10_))
                        {
                           if(param3 < _loc5_.lastTrackOffset)
                           {
                              _loc5_.lastTrackOffset = param3;
                           }
                           else
                           {
                              _loc11_ = 0;
                              while(_loc11_ < _loc10_.length)
                              {
                                 _loc8_ = _loc4_.s.isSet(_loc10_[_loc11_]) ? parseInt("" + _loc10_[_loc11_]) : 0;
                                 if(Boolean(_loc4_.s.isSet(_loc8_)) && Boolean((_loc5_.lastTrackOffset + 1) / _loc5_.length < _loc8_ / 100) && (param3 + 1) / _loc5_.length >= _loc8_ / 100)
                                 {
                                    _loc13_ = true;
                                    _loc11_ = _loc10_.length;
                                 }
                                 _loc11_++;
                              }
                           }
                        }
                     }
                  }
               }
               else
               {
                  _loc4_.event(param1,2,-1);
                  if(_loc4_.s.isSet(_loc4_.trackWhilePlaying))
                  {
                     _loc19_.offset = _loc5_.lastEventOffset;
                     _loc19_.percent = (_loc19_.offset + 1) / _loc19_.length * 100;
                     _loc19_.percent = _loc19_.percent > 100 ? 100 : Math.floor(_loc19_.percent);
                     _loc19_.timePlayed = _loc5_.timePlayed;
                     if(_loc4_.s.isSet(_loc4_.monitor))
                     {
                        _loc4_.monitor(_loc4_.s,_loc19_);
                     }
                  }
                  _loc4_.list[param1] = 0;
                  if(_loc4_.s.isSet(_loc5_.session))
                  {
                     _loc18_ += "" + _loc5_.timePlayed + _loc12_ + _loc5_.timestamp + _loc12_ + (Boolean(_loc4_.s.isSet(_loc4_.trackWhilePlaying)) && _loc5_.lastTrackOffset >= 0 ? "L" + _loc5_.lastTrackOffset : "") + _loc5_.session;
                     if(_loc4_.s.isSet(_loc4_.trackWhilePlaying))
                     {
                        _loc15_ = _loc16_ = "None";
                        _loc17_ = "m_o";
                     }
                     else
                     {
                        _loc13_ = false;
                        _loc4_.s.flushBufferedRequest(_loc4_.s.account,_loc14_);
                     }
                  }
                  else
                  {
                     _loc13_ = false;
                  }
                  _loc14_ = null;
               }
               if(_loc13_)
               {
                  _loc4_.s.track({
                     "linkTrackVars":_loc15_,
                     "linkTrackEvents":_loc16_,
                     "pe":_loc17_,
                     "pev3":_loc18_
                  },_loc14_);
                  if(_loc4_.s.isSet(_loc4_.trackWhilePlaying))
                  {
                     _loc5_.timePlayedSinseTrack = 0;
                     _loc5_.lastTrackOffset = param3;
                     _loc5_.session = "";
                  }
               }
            }
         }
      }
      
      public function listenerFLVPlayback_complete(param1:*) : *
      {
         this.listenerFLVPlayback.complete(param1);
      }
      
      public function variableOverridesApply(param1:Object) : *
      {
         var _loc3_:String = null;
         var _loc2_:Object = this;
         for(_loc3_ in param1)
         {
            if(_loc3_ == "autoTrack" || _loc3_ == "trackWhilePlaying")
            {
               if(typeof param1[_loc3_] == "string")
               {
                  if(param1[_loc3_].toLowerCase() == "true")
                  {
                     param1[_loc3_] = true;
                  }
                  else
                  {
                     param1[_loc3_] = false;
                  }
               }
               else if(typeof param1[_loc3_] != "boolean")
               {
                  param1[_loc3_] = false;
               }
            }
            else if(_loc3_ == "trackSeconds")
            {
               if(typeof param1[_loc3_] == "string")
               {
                  param1[_loc3_] == parseInt(param1[_loc3_]);
               }
               else if(typeof param1[_loc3_] != "number")
               {
                  param1[_loc3_] == 0;
               }
            }
            if((typeof param1[_loc3_] == "string" || typeof param1[_loc3_] == "number" || typeof param1[_loc3_] == "boolean") && (_loc3_ == "autoTrack" || _loc3_ == "trackWhilePlaying" || _loc3_ == "trackSeconds" || _loc3_ == "trackMilestones" || _loc3_ == "playerName" || _loc3_ == "trackVars" || _loc3_ == "trackEvents"))
            {
               _loc2_[_loc3_] = param1[_loc3_];
            }
         }
      }
      
      private function startMonitor(param1:Object) : *
      {
         var monitorNum:Number = NaN;
         var monitor:Object = param1;
         var m:Object = this;
         var nextMonitorNum:Number = 0;
         if(m.s.isSet(m.monitorList))
         {
            nextMonitorNum = -1;
            monitorNum = 0;
            while(monitorNum < m.monitorList.length)
            {
               if(m.s.isSet(m.monitorList[monitorNum]))
               {
                  if(Boolean(m.s.isSet(m.monitorList[monitorNum].node)) && Boolean(m.s.isSet(monitor)) && Boolean(m.s.isSet(monitor.node)) && m.monitorList[monitorNum].node == monitor.node)
                  {
                     return;
                  }
               }
               else if(nextMonitorNum < 0)
               {
                  nextMonitorNum = monitorNum;
               }
               monitorNum++;
            }
            if(nextMonitorNum < 0)
            {
               nextMonitorNum = Number(m.monitorList.length);
            }
         }
         else
         {
            m.monitorList = new Array();
         }
         monitor.update = function(param1:Object):*
         {
            if(param1.m == null || param1.m == undefined || param1.m.s == null || param1.m.s == undefined || param1.node == null || param1.node == undefined)
            {
               clearInterval(param1.interval);
               param1.m.monitorList[param1.num] = null;
            }
            else
            {
               param1.monitor();
            }
         };
         monitor.interval = m.s.setupInterval(monitor,"update",5000,monitor);
         monitor.num = nextMonitorNum;
         m.monitorList[monitor.num] = monitor;
      }
      
      private function _open(param1:String, param2:Number, param3:String, param4:Object) : *
      {
         var _loc9_:String = null;
         var _loc5_:Object = this;
         var _loc6_:Object = new Object();
         var _loc7_:Date = new Date();
         var _loc8_:String = "";
         param1 = _loc5_.cleanName(param1);
         param2 = Math.floor(param2);
         if(!_loc5_.s.isSet(param2))
         {
            param2 = 1;
         }
         if(Boolean(_loc5_.s.isSet(param1)) && Boolean(_loc5_.s.isSet(param3)))
         {
            if(!_loc5_.s.isSet(_loc5_.list))
            {
               _loc5_.list = new Object();
            }
            if(_loc5_.s.isSet(_loc5_.list[param1]))
            {
               _loc5_.close(param1);
            }
            if(_loc5_.s.isSet(param4))
            {
               _loc8_ = "" + param4;
            }
            for(_loc9_ in _loc5_.list)
            {
               if(Boolean(_loc5_.s.isSet(_loc5_.list[_loc9_])) && _loc5_.list[_loc9_].playerID == _loc8_)
               {
                  _loc5_.close(_loc5_.list[_loc9_].name);
               }
            }
            _loc6_.name = param1;
            _loc6_.length = param2;
            _loc6_.playerName = _loc5_.cleanName(_loc5_.s.isSet(_loc5_.playerName) ? _loc5_.playerName : param3);
            _loc6_.playerID = _loc8_;
            _loc6_.timePlayed = 0;
            _loc6_.timePlayedSinseTrack = 0;
            _loc6_.timestamp = Math.floor(_loc7_.getTime() / 1000);
            _loc6_.lastEventType = 0;
            _loc6_.lastEventTimestamp = _loc6_.timestamp;
            _loc6_.lastEventOffset = 0;
            _loc6_.session = "";
            _loc6_.lastTrackOffset = -1;
            _loc5_.list[param1] = _loc6_;
         }
      }
      
      private function autoEvent(param1:String, param2:Number, param3:String, param4:Number, param5:Number, param6:Object) : *
      {
         var _loc7_:Object = this;
         param1 = _loc7_.cleanName(param1);
         if(Boolean(_loc7_.s.isSet(param1)) && Boolean(_loc7_.s.isSet(param2)) && Boolean(_loc7_.s.isSet(param3)))
         {
            if(!_loc7_.s.isSet(_loc7_.list) || !_loc7_.s.isSet(_loc7_.list[param1]))
            {
               _loc7_.open(param1,param2,param3,param6);
            }
            _loc7_.event(param1,param4,param5);
         }
      }
      
      public function play(param1:String, param2:Number) : *
      {
         var media:Object = null;
         var monitor:Object = null;
         var name:String = param1;
         var offset:Number = param2;
         var m:Object = this;
         m.event(name,1,offset);
         monitor = new Object();
         monitor.m = m;
         monitor.node = m.cleanName(name);
         monitor.monitor = function():*
         {
            var _loc3_:Object = null;
            var _loc1_:Object = this.m;
            var _loc2_:Object = this.node;
            _loc3_ = Boolean(_loc1_.s.isSet(_loc2_)) && Boolean(_loc1_.s.isSet(_loc1_.list)) && Boolean(_loc1_.s.isSet(_loc1_.list[_loc2_])) ? _loc1_.list[_loc2_] : null;
            if(_loc1_.s.isSet(_loc3_))
            {
               if(_loc3_.lastEventType == 1)
               {
                  _loc1_.event(_loc3_.name,3,-1);
               }
            }
            else
            {
               this.node = null;
            }
         };
         m.startMonitor(monitor);
      }
      
      public function set autoTrack(param1:Boolean) : *
      {
         this._autoTrack = param1;
         if(this._autoTrack)
         {
            this.autoTrackInterval = this.s.setupInterval(this,"doAutoTrack",100,null);
         }
      }
      
      public function listenerFLVPlayback_stateChange(param1:*) : *
      {
         this.listenerFLVPlayback.stateChange(param1);
      }
      
      public function listenerBrightcove_videoStart(param1:*) : *
      {
         this.listenerBrightcove.videoStart(param1);
      }
      
      public function listenerMedia_change(param1:*) : *
      {
         this.listenerMedia.change(param1);
      }
      
      private function attach(param1:Object) : Boolean
      {
         var member:String = null;
         var childNum:Number = NaN;
         var player:Object = null;
         var monitor:Object = null;
         var subAttached:Boolean = false;
         var node:Object = param1;
         var m:Object = this;
         var attached:Boolean = false;
         if(m.s.isSet(node))
         {
            if(Boolean(m.s.isSet(node,"getModule")) || Boolean(m.s.isSet(node,"showBrightcoveMenu")))
            {
               player = node;
               if(m.s.flashASVersion > 2 && Boolean(m.s.isSet(node,"getModule")))
               {
                  player = node.getModule("experience");
                  if(Boolean(m.s.isSet(player)) && Boolean(m.s.isSet(player,"getReady")) && Boolean(player.getReady()))
                  {
                     player = node.getModule("videoPlayer");
                  }
                  else
                  {
                     player = undefined;
                  }
               }
               if(Boolean(s.isSet(player)) && Boolean(s.isSet(player,"addEventListener")))
               {
                  if(!m.s.isSet(m.listenerBrightcove))
                  {
                     m.listenerBrightcove = new Object();
                     m.listenerBrightcove.m = m;
                     m.listenerBrightcove.playerName = "Brightcove";
                     if(m.s.flashASVersion > 2)
                     {
                        m.listenerBrightcove.playerName += " 3";
                     }
                     else
                     {
                        m.listenerBrightcove.playerName += " 2";
                     }
                     m.listenerBrightcove.handleEvent = function(param1:Object, param2:Number, param3:Number):*
                     {
                        var _loc5_:String = null;
                        var _loc6_:Number = NaN;
                        var _loc7_:Object = null;
                        var _loc4_:Object = this.m;
                        if(Boolean(_loc4_.s.isSet(_loc4_.autoTrack)) && Boolean(_loc4_.s.isSet(param1)))
                        {
                           if(_loc4_.s.flashASVersion > 2)
                           {
                              _loc7_ = param1.getCurrentVideo();
                           }
                           else
                           {
                              _loc7_ = param1.getCurrentTitle();
                           }
                           if(Boolean(_loc4_.s.isSet(_loc7_)) && Boolean(_loc4_.s.isSet(_loc7_.id)))
                           {
                              _loc5_ = this.playerName + ":" + _loc7_.id;
                              _loc6_ = _loc7_.length / 1000;
                              if(param3 < 0)
                              {
                                 param3 = Number(param1.getVideoPosition());
                              }
                              if(!_loc4_.s.isSet(param3))
                              {
                                 param3 = 0;
                              }
                              _loc4_.autoEvent(_loc5_,_loc6_,this.playerName,param2,param3,param1);
                           }
                        }
                     };
                     m.listenerBrightcove.videoProgress = m.listenerBrightcove.videoStart = m.listenerBrightcove.progress = m.listenerBrightcove.play = function(param1:*):*
                     {
                        if(Boolean(this.m.s.isSet(param1)) && Boolean(this.m.s.isSet(param1.target)) && Boolean(this.m.s.isSet(param1.target.isPlaying)) && Boolean(param1.target.isPlaying()))
                        {
                           this.handleEvent(param1.target,1,typeof param1.position == "number" ? param1.position : -1);
                        }
                     };
                     m.listenerBrightcove.videoStop = m.listenerBrightcove.startBuffering = m.listenerBrightcove.pause = m.listenerBrightcove.buffering = m.listenerBrightcove.scrubber = m.listenerBrightcove.seek = function(param1:*):*
                     {
                        if(this.m.s.isSet(param1))
                        {
                           this.handleEvent(param1.target,2,-1);
                        }
                     };
                     m.listenerBrightcove.videoComplete = m.listenerBrightcove.mediaComplete = function(param1:*):*
                     {
                        if(this.m.s.isSet(param1))
                        {
                           this.handleEvent(param1.target,0,-1);
                        }
                     };
                  }
                  if(m.s.flashASVersion > 2)
                  {
                     player.addEventListener("videoProgress",m.listenerBrightcove_videoProgress);
                     player.addEventListener("videoStart",m.listenerBrightcove_videoStart);
                     player.addEventListener("videoStop",m.listenerBrightcove_videoStop);
                     player.addEventListener("startBuffering",m.listenerBrightcove_startBuffering);
                     player.addEventListener("seek",m.listenerBrightcove_seek);
                     player.addEventListener("videoComplete",m.listenerBrightcove_videoComplete);
                  }
                  else
                  {
                     player.addEventListener("progress",m.listenerBrightcove,"progress");
                     player.addEventListener("play",m.listenerBrightcove,"play");
                     player.addEventListener("pause",m.listenerBrightcove,"pause");
                     player.addEventListener("buffering",m.listenerBrightcove,"buffering");
                     player.addEventListener("scrubber",m.listenerBrightcove,"scrubber");
                     player.addEventListener("seek",m.listenerBrightcove,"seek");
                     player.addEventListener("mediaComplete",m.listenerBrightcove,"mediaComplete");
                  }
                  monitor = new Object();
                  monitor.m = m;
                  monitor.node = player;
                  monitor.monitor = function():*
                  {
                     var _loc1_:Object = this.m;
                     var _loc2_:Object = this.node;
                     if(Boolean(_loc1_.s.isSet(_loc2_.isPlaying)) && Boolean(_loc2_.isPlaying()))
                     {
                        this.m.listenerBrightcove.handleEvent(_loc2_,3,-1);
                     }
                  };
                  m.startMonitor(monitor);
                  attached = true;
                  return attached;
               }
            }
            if(Boolean(0) && Boolean(m.s.isSet(node,"flvVideo")) && Boolean(m.s.isSet(node.flvVideo,"mBandwidthDetector")) && Boolean(m.s.isSet(node.flvVideo.mBandwidthDetector,"mVideoPlayer")) && Boolean(m.s.isSet(node.flvVideo.mBandwidthDetector.mVideoPlayer,"addEventListener")))
            {
               node = node.flvVideo.mBandwidthDetector.mVideoPlayer;
               if(!m.s.isSet(m.listenerMaven))
               {
                  m.listenerMaven = new Object();
                  m.listenerMaven.m = m;
                  m.listenerMaven.playerName = "Maven Networks";
                  m.listenerMaven.handleEvent = function(param1:Object, param2:Number):*
                  {
                     var _loc4_:String = null;
                     var _loc5_:Number = NaN;
                     var _loc6_:Number = NaN;
                     var _loc3_:Object = this.m;
                     if(Boolean(_loc3_.s.isSet(_loc3_.autoTrack)) && Boolean(_loc3_.s.isSet(param1)))
                     {
                        if(_loc3_.s.flashASVersion > 2)
                        {
                           _loc4_ = param1.source;
                        }
                        else
                        {
                           _loc4_ = param1.contentPath;
                        }
                        _loc5_ = Number(param1.totalTime);
                        _loc6_ = Number(param1.playheadTime);
                        _loc3_.autoEvent(_loc4_,_loc5_,this.playerName,param2,_loc6_,param1);
                     }
                  };
                  m.listenerMaven.stateChange = function(param1:*):*
                  {
                     var _loc4_:Object = null;
                     var _loc2_:Object = this.m;
                     var _loc3_:Number = -1;
                     if(Boolean(_loc2_.s.isSet(param1)) && Boolean(_loc2_.s.isSet(param1.target)))
                     {
                        _loc4_ = param1.target;
                        if(_loc2_.s.isSet(_loc4_,"state"))
                        {
                           if(_loc4_.state == "playing")
                           {
                              _loc3_ = 1;
                           }
                           else if(_loc4_.state == "stopped" || _loc4_.state == "paused" || _loc4_.state == "buffering" || _loc4_.state == "rewinding" || _loc4_.state == "seeking")
                           {
                              _loc3_ = 2;
                           }
                           if(_loc3_ >= 0)
                           {
                              this.handleEvent(param1.target,_loc3_);
                           }
                        }
                     }
                  };
                  m.listenerMaven.complete = function(param1:*):*
                  {
                     if(this.m.s.isSet(param1))
                     {
                        this.handleEvent(param1.target,0);
                     }
                  };
               }
               if(m.s.flashASVersion > 2)
               {
                  node.addEventListener("complete",m.listenerMaven_complete);
                  node.addEventListener("stateChange",m.listenerMaven_stateChange);
               }
               else
               {
                  node.addEventListener("complete",m.listenerMaven);
                  node.addEventListener("stateChange",m.listenerMaven);
               }
               monitor = new Object();
               monitor.m = m;
               monitor.node = node;
               monitor.monitor = function():*
               {
                  var _loc1_:Object = this.m;
                  var _loc2_:Object = this.node;
                  if(Boolean(_loc1_.s.isSet(_loc2_.state)) && _loc2_.state == "playing")
                  {
                     this.m.listenerMaven.handleEvent(_loc2_,3);
                  }
               };
               m.startMonitor(monitor);
               attached = true;
               return attached;
            }
            if(Boolean(m.s.isSet(node,"addEventListener")) && Boolean(m.s.isSet(node,"isFLVCuePointEnabled")))
            {
               if(!m.s.isSet(m.listenerFLVPlayback))
               {
                  m.listenerFLVPlayback = new Object();
                  m.listenerFLVPlayback.m = m;
                  m.listenerFLVPlayback.playerName = "Flash FLVPlayback";
                  m.listenerFLVPlayback.handleEvent = function(param1:Object, param2:Number):*
                  {
                     var _loc4_:String = null;
                     var _loc5_:Number = NaN;
                     var _loc6_:Number = NaN;
                     var _loc3_:Object = this.m;
                     if(Boolean(_loc3_.s.isSet(_loc3_.autoTrack)) && Boolean(_loc3_.s.isSet(param1)))
                     {
                        if(_loc3_.s.flashASVersion > 2)
                        {
                           _loc4_ = param1.source;
                        }
                        else
                        {
                           _loc4_ = param1.contentPath;
                        }
                        _loc5_ = Number(param1.totalTime);
                        _loc6_ = Number(param1.playheadTime);
                        _loc3_.autoEvent(_loc4_,_loc5_,this.playerName,param2,_loc6_,param1);
                     }
                  };
                  m.listenerFLVPlayback.stateChange = function(param1:*):*
                  {
                     var _loc4_:Object = null;
                     var _loc2_:Object = this.m;
                     var _loc3_:Number = -1;
                     if(Boolean(_loc2_.s.isSet(param1)) && Boolean(_loc2_.s.isSet(param1.target)))
                     {
                        _loc4_ = param1.target;
                        if(_loc2_.s.isSet(_loc4_,"state"))
                        {
                           if(_loc4_.state == "playing")
                           {
                              _loc3_ = 1;
                           }
                           else if(_loc4_.state == "stopped" || _loc4_.state == "paused" || _loc4_.state == "buffering" || _loc4_.state == "rewinding" || _loc4_.state == "seeking")
                           {
                              _loc3_ = 2;
                           }
                           if(_loc3_ >= 0)
                           {
                              this.handleEvent(param1.target,_loc3_);
                           }
                        }
                     }
                  };
                  m.listenerFLVPlayback.complete = function(param1:*):*
                  {
                     if(this.m.s.isSet(param1))
                     {
                        this.handleEvent(param1.target,0);
                     }
                  };
               }
               if(m.s.flashASVersion > 2)
               {
                  node.addEventListener("complete",m.listenerFLVPlayback_complete);
                  node.addEventListener("stateChange",m.listenerFLVPlayback_stateChange);
               }
               else
               {
                  node.addEventListener("complete",m.listenerFLVPlayback);
                  node.addEventListener("stateChange",m.listenerFLVPlayback);
               }
               monitor = new Object();
               monitor.m = m;
               monitor.node = node;
               monitor.monitor = function():*
               {
                  var _loc1_:Object = this.m;
                  var _loc2_:Object = this.node;
                  if(Boolean(_loc1_.s.isSet(_loc2_.state)) && _loc2_.state == "playing")
                  {
                     this.m.listenerFLVPlayback.handleEvent(_loc2_,3);
                  }
               };
               m.startMonitor(monitor);
               attached = true;
               return attached;
            }
            if(Boolean(m.s.isSet(node,"addEventListener")) && Boolean(m.s.isSet(node,"addCuePoint")))
            {
               if(!m.s.isSet(m.listenerMedia))
               {
                  m.listenerMedia = new Object();
                  m.listenerMedia.m = m;
                  m.listenerMedia.playerName = "Flash Media";
                  m.listenerMedia.handleEvent = function(param1:Object, param2:Number):*
                  {
                     var _loc4_:String = null;
                     var _loc5_:Number = NaN;
                     var _loc6_:Number = NaN;
                     var _loc3_:Object = this.m;
                     if(Boolean(_loc3_.s.isSet(_loc3_.autoTrack)) && Boolean(_loc3_.s.isSet(param1)))
                     {
                        _loc4_ = param1.contentPath;
                        _loc5_ = Number(param1.totalTime);
                        _loc6_ = Number(param1.playheadTime);
                        _loc3_.autoEvent(_loc4_,_loc5_,this.playerName,param2,_loc6_,param1);
                     }
                  };
                  m.listenerMedia.complete = function(param1:*):*
                  {
                     if(this.m.s.isSet(param1))
                     {
                        this.handleEvent(param1.target,0);
                     }
                  };
                  m.listenerMedia.click = function(param1:*):*
                  {
                     if(Boolean(this.m.s.isSet(param1)) && Boolean(this.m.s.isSet(param1.target)))
                     {
                        this.handleEvent(param1.target,this.m.s.isSet(param1.target.playing) ? 1 : 2);
                     }
                  };
                  m.listenerMedia.change = function(param1:*):*
                  {
                     if(Boolean(this.m.s.isSet(param1)) && Boolean(this.m.s.isSet(param1.target)))
                     {
                        this.handleEvent(param1.target,this.m.s.isSet(param1.target.playing) ? 1 : 2);
                     }
                  };
                  m.listenerMedia.scrubbing = function(param1:*):*
                  {
                     if(this.m.s.isSet(param1))
                     {
                        this.handleEvent(param1.target,2);
                     }
                  };
               }
               if(m.s.flashASVersion > 2)
               {
                  node.addEventListener("complete",m.listenerMedia_complete);
                  node.addEventListener("click",m.listenerMedia_click);
                  node.addEventListener("change",m.listenerMedia_change);
                  node.addEventListener("scrubbing",m.listenerMedia_scrubbing);
               }
               else
               {
                  node.addEventListener("complete",m.listenerMedia);
                  node.addEventListener("click",m.listenerMedia);
                  node.addEventListener("change",m.listenerMedia);
                  node.addEventListener("scrubbing",m.listenerMedia);
               }
               monitor = new Object();
               monitor.m = m;
               monitor.node = node;
               monitor.monitor = function():*
               {
                  var _loc1_:Object = this.m;
                  var _loc2_:Object = this.node;
                  if(_loc1_.s.isSet(_loc2_.playing))
                  {
                     this.m.listenerMedia.handleEvent(_loc2_,3);
                  }
               };
               m.startMonitor(monitor);
               attached = true;
               return attached;
            }
            if(m.s.flashASVersion > 2)
            {
               if(Boolean(m.s.isSet(node,"numChildren")) && Boolean(m.s.isSet(node,"getChildAt")))
               {
                  childNum = 0;
                  while(childNum < node.numChildren)
                  {
                     subAttached = Boolean(m.attach(node.getChildAt(childNum)));
                     if(m.s.isSet(subAttached))
                     {
                        attached = subAttached;
                     }
                     childNum++;
                  }
               }
            }
            else
            {
               for(member in node)
               {
                  if(Boolean(m.s.isSet(node[member]) && m.s.isSet(node[member]._name)) && Boolean(node[member]._name == member) && "" + node + "." + member == "" + node[member])
                  {
                     subAttached = Boolean(m.attach(node[member]));
                     if(m.s.isSet(subAttached))
                     {
                        attached = subAttached;
                     }
                  }
               }
            }
         }
         return attached;
      }
      
      public function listenerBrightcove_videoStop(param1:*) : *
      {
         this.listenerBrightcove.videoStop(param1);
      }
      
      public function open(param1:String, param2:Number, param3:String, param4:Object = null) : *
      {
         this._open(param1,param2,param3,param4);
      }
      
      public function track(param1:String) : *
      {
         var _loc2_:Object = this;
         if(_loc2_.s.isSet(_loc2_.trackWhilePlaying))
         {
            _loc2_.event(param1,4,-1);
         }
      }
      
      public function get autoTrack() : Boolean
      {
         return this._autoTrack;
      }
      
      public function listenerBrightcove_videoProgress(param1:*) : *
      {
         this.listenerBrightcove.videoProgress(param1);
      }
      
      private function cleanName(param1:String) : String
      {
         var _loc2_:Object = this;
         return _loc2_.s.replace(_loc2_.s.replace(_loc2_.s.replace(param1,"\n",""),"\r",""),"--**--","");
      }
      
      public function listenerBrightcove_startBuffering(param1:*) : *
      {
         this.listenerBrightcove.startBuffering(param1);
      }
      
      public function close(param1:String) : *
      {
         this.event(param1,0,-1);
      }
      
      public function listenerBrightcove_videoComplete(param1:*) : *
      {
         this.listenerBrightcove.videoComplete(param1);
      }
   }
}

