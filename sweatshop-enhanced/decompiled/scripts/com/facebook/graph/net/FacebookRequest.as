package com.facebook.graph.net
{
   import com.adobe.images.PNGEncoder;
   import com.adobe.serialization.json.JSON;
   import com.facebook.graph.utils.PostRequest;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.DataEvent;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.FileReference;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   
   public class FacebookRequest
   {
      
      protected var urlLoader:URLLoader;
      
      protected var fileReference:FileReference;
      
      protected var urlRequest:URLRequest;
      
      protected var _rawResult:String;
      
      protected var _data:Object;
      
      protected var _success:Boolean;
      
      protected var _url:String;
      
      protected var _requestMethod:String;
      
      protected var _callback:Function;
      
      public function FacebookRequest(param1:String, param2:String = "GET", param3:Function = null)
      {
         super();
         this._url = param1;
         this._requestMethod = param2;
         this._callback = param3;
      }
      
      public function get rawResult() : String
      {
         return this._rawResult;
      }
      
      public function get success() : Boolean
      {
         return this._success;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function callURL(param1:Function, param2:String = "", param3:String = null) : void
      {
         var _loc4_:URLVariables = null;
         this._callback = param1;
         this.urlRequest = new URLRequest(param2.length ? param2 : this._url);
         if(param3)
         {
            _loc4_ = new URLVariables();
            _loc4_.locale = param3;
            this.urlRequest.data = _loc4_;
         }
         this.loadURLLoader();
      }
      
      public function call(param1:String, param2:* = null, param3:Function = null) : void
      {
         var _loc5_:Object = null;
         var _loc7_:String = null;
         var _loc8_:ByteArray = null;
         if(param3 != null)
         {
            this._callback = param3;
         }
         var _loc4_:String = this._url + param1;
         this.urlRequest = new URLRequest(_loc4_);
         this.urlRequest.method = this._requestMethod;
         if(param2 == null)
         {
            this.loadURLLoader();
            return;
         }
         if(this.isValueFile(param2))
         {
            _loc5_ = param2;
         }
         else if(param2 != null)
         {
            for(_loc7_ in param2)
            {
               if(this.isValueFile(param2[_loc7_]))
               {
                  _loc5_ = param2[_loc7_];
                  delete param2[_loc7_];
                  break;
               }
            }
         }
         if(_loc5_ == null)
         {
            this.urlRequest.data = this.objectToURLVariables(param2);
            this.loadURLLoader();
            return;
         }
         if(_loc5_ is FileReference)
         {
            this.urlRequest.data = this.objectToURLVariables(param2);
            this.urlRequest.method = URLRequestMethod.POST;
            this.fileReference = _loc5_ as FileReference;
            this.fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,this.handleFileReferenceData,false,0,true);
            this.fileReference.addEventListener(IOErrorEvent.IO_ERROR,this.handelFileReferenceError,false,0,false);
            this.fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handelFileReferenceError,false,0,false);
            this.fileReference.upload(this.urlRequest);
            return;
         }
         var _loc6_:PostRequest = new PostRequest();
         for(_loc7_ in param2)
         {
            _loc6_.writePostData(_loc7_,param2[_loc7_]);
         }
         if(_loc5_ is Bitmap)
         {
            _loc5_ = (_loc5_ as Bitmap).bitmapData;
         }
         if(_loc5_ is ByteArray)
         {
            _loc6_.writeFileData(param2.fileName,_loc5_ as ByteArray,param2.contentType);
         }
         else if(_loc5_ is BitmapData)
         {
            _loc8_ = PNGEncoder.encode(_loc5_ as BitmapData);
            _loc6_.writeFileData(param2.fileName,_loc8_,"image/png");
         }
         _loc6_.close();
         this.urlRequest.contentType = "multipart/form-data; boundary=" + _loc6_.boundary;
         this.urlRequest.data = _loc6_.getPostData();
         this.urlRequest.method = URLRequestMethod.POST;
         this.loadURLLoader();
      }
      
      protected function isValueFile(param1:Object) : Boolean
      {
         return param1 is FileReference || param1 is Bitmap || param1 is BitmapData || param1 is ByteArray;
      }
      
      protected function objectToURLVariables(param1:Object) : URLVariables
      {
         var _loc3_:String = null;
         var _loc2_:URLVariables = new URLVariables();
         if(param1 == null)
         {
            return _loc2_;
         }
         for(_loc3_ in param1)
         {
            _loc2_[_loc3_] = param1[_loc3_];
         }
         return _loc2_;
      }
      
      public function close() : void
      {
         if(this.urlLoader != null)
         {
            this.urlLoader.removeEventListener(Event.COMPLETE,this.handleURLLoaderComplete);
            this.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.handleURLLoaderIOError);
            this.urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleURLLoaderSecurityError);
            try
            {
               this.urlLoader.close();
            }
            catch(e:*)
            {
            }
            this.urlLoader = null;
         }
         if(this.fileReference != null)
         {
            this.fileReference.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA,this.handleFileReferenceData);
            this.fileReference.removeEventListener(IOErrorEvent.IO_ERROR,this.handelFileReferenceError);
            this.fileReference.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handelFileReferenceError);
            try
            {
               this.fileReference.cancel();
            }
            catch(e:*)
            {
            }
            this.fileReference = null;
         }
      }
      
      protected function loadURLLoader() : void
      {
         this.urlLoader = new URLLoader();
         this.urlLoader.addEventListener(Event.COMPLETE,this.handleURLLoaderComplete,false,0,false);
         this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR,this.handleURLLoaderIOError,false,0,true);
         this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleURLLoaderSecurityError,false,0,true);
         this.urlLoader.load(this.urlRequest);
      }
      
      protected function handleURLLoaderComplete(param1:Event) : void
      {
         this.handleDataLoad(this.urlLoader.data);
      }
      
      protected function handleDataLoad(param1:Object, param2:Boolean = true) : void
      {
         var result:Object = param1;
         var dispatchCompleteEvent:Boolean = param2;
         this._rawResult = result as String;
         this._success = true;
         try
         {
            this._data = com.adobe.serialization.json.JSON.decode(this._rawResult);
         }
         catch(e:*)
         {
            _data = _rawResult;
            _success = false;
         }
         if(dispatchCompleteEvent)
         {
            this.dispatchComplete();
         }
      }
      
      protected function dispatchComplete() : void
      {
         this._callback(this);
         this.close();
      }
      
      protected function handleURLLoaderIOError(param1:IOErrorEvent) : void
      {
         var event:IOErrorEvent = param1;
         this._success = false;
         this._rawResult = (event.target as URLLoader).data;
         if(this._rawResult != "")
         {
            try
            {
               this._data = com.adobe.serialization.json.JSON.decode(this._rawResult);
            }
            catch(e:*)
            {
               _data = {
                  "type":"Exception",
                  "message":_rawResult
               };
            }
         }
         else
         {
            this._data = event;
         }
         this.dispatchComplete();
      }
      
      protected function handleURLLoaderSecurityError(param1:SecurityErrorEvent) : void
      {
         var event:SecurityErrorEvent = param1;
         this._success = false;
         this._rawResult = (event.target as URLLoader).data;
         try
         {
            this._data = com.adobe.serialization.json.JSON.decode((event.target as URLLoader).data);
         }
         catch(e:*)
         {
            _data = event;
         }
         this.dispatchComplete();
      }
      
      protected function handleFileReferenceData(param1:DataEvent) : void
      {
         this.handleDataLoad(param1.data);
      }
      
      protected function handelFileReferenceError(param1:ErrorEvent) : void
      {
         this._success = false;
         this._data = param1;
         this.dispatchComplete();
      }
      
      public function toString() : String
      {
         return this.urlRequest.url + (this.urlRequest.data == null ? "" : "?" + unescape(this.urlRequest.data.toString()));
      }
   }
}

