package org.fatlib.assets
{
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.media.Sound;
   import org.fatlib.events.LoadProgressEvent;
   
   public class ResourceBank extends EventDispatcher
   {
      
      private var _resources:Array;
      
      private var _numLoaded:int;
      
      private var _numTotal:int;
      
      private var _hasLoaded:Boolean;
      
      public function ResourceBank()
      {
         super();
         this._resources = [];
      }
      
      public function addResource(param1:String, param2:Class) : void
      {
         this._resources[param1] = new Resource(param2);
      }
      
      public function startLoading() : void
      {
         var _loc1_:Resource = null;
         this._numLoaded = 0;
         this._numTotal = 0;
         for each(_loc1_ in this._resources)
         {
            if(!_loc1_.loaded)
            {
               ++this._numTotal;
            }
         }
         for each(_loc1_ in this._resources)
         {
            if(!_loc1_.loaded)
            {
               _loc1_.load(this.handleResourceLoaded);
            }
         }
      }
      
      public function get hasLoaded() : Boolean
      {
         return this._hasLoaded;
      }
      
      private function handleResourceLoaded() : void
      {
         ++this._numLoaded;
         if(this._numLoaded == this._numTotal)
         {
            dispatchEvent(new LoadProgressEvent(LoadProgressEvent.LOADED));
            this._hasLoaded = true;
         }
      }
      
      private function getResource(param1:String) : Resource
      {
         var _loc2_:Resource = this._resources[param1];
         if(!_loc2_)
         {
            throw new Error("no such resource as " + param1);
         }
         if(!_loc2_.loaded)
         {
            throw new Error("resource " + param1 + " not loaded");
         }
         return _loc2_;
      }
      
      public function instantiateBitmapData(param1:String, param2:String) : BitmapData
      {
         var _loc3_:Class = this.getResource(param1).getDef(param2);
         return new _loc3_(0,0) as BitmapData;
      }
      
      public function instantiateSound(param1:String, param2:String) : Sound
      {
         var _loc3_:Class = this.getResource(param1).getDef(param2 + ".wav");
         return new _loc3_() as Sound;
      }
      
      public function instantiateMovieClip(param1:String, param2:String, param3:Boolean = true) : MovieClip
      {
         var _loc4_:Class = this.getResource(param1).getDef(param2);
         var _loc5_:MovieClip = new _loc4_() as MovieClip;
         _loc5_.cacheAsBitmap = param3;
         return _loc5_;
      }
   }
}

import flash.display.Loader;
import flash.events.Event;
import org.fatlib.process.Callback;

class Resource
{
   
   private var _done:Callback;
   
   private var _swf:Class;
   
   public var loaded:Boolean = false;
   
   public var loader:Loader;
   
   public function Resource(param1:Class)
   {
      super();
      this._swf = param1;
   }
   
   public function load(param1:Function) : void
   {
      this._done = new Callback(param1);
      this.loader = new Loader();
      this.loader.contentLoaderInfo.addEventListener(Event.INIT,this.onInit);
      this.loader.loadBytes(new this._swf());
   }
   
   private function onInit(param1:Event) : void
   {
      this.loaded = true;
      this.loader.contentLoaderInfo.removeEventListener(Event.INIT,this.onInit);
      this._done.execute();
   }
   
   public function getDef(param1:String) : Class
   {
      return this.loader.contentLoaderInfo.applicationDomain.getDefinition(param1) as Class;
   }
}
