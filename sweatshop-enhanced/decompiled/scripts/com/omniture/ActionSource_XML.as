package com.omniture
{
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public dynamic class ActionSource_XML
   {
      
      public var onDataReady:String = "";
      
      public var data:Object;
      
      public var loaded:Boolean = true;
      
      private var _url:String;
      
      private var loader:URLLoader;
      
      public function ActionSource_XML(param1:Object)
      {
         super();
         this.s = param1;
         this.loader = new URLLoader();
         this.loader.addEventListener(Event.COMPLETE,this.onComplete);
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      private function loadXML() : *
      {
         this.loaded = false;
         this.loader.load(new URLRequest(this._url));
      }
      
      private function onComplete(param1:Event) : *
      {
         var _loc3_:XML = null;
         var _loc2_:Object = XML.settings();
         XML.ignoreWhitespace = true;
         XML.ignoreProcessingInstructions = true;
         XML.ignoreComments = true;
         _loc3_ = new XML(this.loader.data);
         this.data = new Object();
         if(_loc3_.name() == "config" && _loc3_.nodeKind() == "element")
         {
            this.handleNode(_loc3_,this.data);
         }
         XML.setSettings(_loc2_);
         if(this.s.isSet(this.onDataReady))
         {
            this.s[onDataReady](this.data);
         }
         this.loaded = true;
      }
      
      private function handleNode(param1:XML, param2:Object) : *
      {
         var _loc3_:String = null;
         var _loc4_:XMLList = null;
         var _loc5_:Number = NaN;
         _loc3_ = param1.name();
         if(Boolean(this.s.isSet(_loc3_)) && param1.nodeKind() == "element")
         {
            _loc4_ = param1.children();
            if(Boolean(this.s.isSet(_loc4_)) && _loc4_.length() > 0)
            {
               if(_loc4_[0].nodeKind() == "text")
               {
                  param2[_loc3_] = "" + _loc4_[0];
               }
               else
               {
                  param2[_loc3_] = new Object();
                  _loc5_ = 0;
                  while(_loc5_ < _loc4_.length())
                  {
                     this.handleNode(_loc4_[_loc5_],param2[_loc3_]);
                     _loc5_++;
                  }
               }
            }
         }
      }
      
      public function set url(param1:String) : *
      {
         var _loc2_:String = null;
         this._url = param1;
         if(this.s.isSet(this._url))
         {
            _loc2_ = this._url.toLowerCase();
            if(this.s.isSet(this.s.ssl))
            {
               if(_loc2_.substr(0,7) == "http://")
               {
                  this._url = this._url.substr(7);
                  _loc2_ = this._url.toLowerCase();
               }
               if(_loc2_.substr(0,8) != "https://")
               {
                  this._url = "https://" + this._url;
               }
            }
            else if(_loc2_.substr(0,7) != "http://" && _loc2_.substr(0,8) != "https://")
            {
               this._url = "http://" + this._url;
            }
            this.loadXML();
         }
      }
   }
}

