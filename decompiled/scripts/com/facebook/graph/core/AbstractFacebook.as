package com.facebook.graph.core
{
   import com.facebook.graph.data.FQLMultiQuery;
   import com.facebook.graph.data.FacebookSession;
   import com.facebook.graph.net.FacebookRequest;
   import com.facebook.graph.utils.FQLMultiQueryParser;
   import com.facebook.graph.utils.IResultParser;
   import flash.net.URLRequestMethod;
   import flash.utils.Dictionary;
   
   public class AbstractFacebook
   {
      
      protected var session:FacebookSession;
      
      protected var openRequests:Dictionary;
      
      protected var resultHash:Dictionary;
      
      protected var locale:String;
      
      protected var parserHash:Dictionary;
      
      public function AbstractFacebook()
      {
         super();
         this.openRequests = new Dictionary();
         this.resultHash = new Dictionary(true);
         this.parserHash = new Dictionary();
      }
      
      protected function api(param1:String, param2:Function = null, param3:* = null, param4:String = "GET") : void
      {
         param1 = param1.indexOf("/") != 0 ? "/" + param1 : param1;
         if(this.session != null)
         {
            if(param3 == null)
            {
               param3 = {};
            }
            param3.access_token = this.session.accessToken;
         }
         var _loc5_:FacebookRequest = new FacebookRequest(FacebookURLDefaults.GRAPH_URL,param4);
         if(this.locale)
         {
            param3.locale = this.locale;
         }
         this.openRequests[_loc5_] = param2;
         _loc5_.call(param1,param3,this.handleRequestLoad);
      }
      
      protected function pagingCall(param1:String, param2:Function) : void
      {
         var _loc3_:FacebookRequest = new FacebookRequest(param1);
         this.openRequests[_loc3_] = param2;
         _loc3_.callURL(this.handleRequestLoad,"",this.locale);
      }
      
      protected function getRawResult(param1:Object) : Object
      {
         return this.resultHash[param1];
      }
      
      protected function nextPage(param1:Object, param2:Function = null) : void
      {
         var _loc3_:Object = this.getRawResult(param1);
         if(Boolean(_loc3_) && Boolean(_loc3_.paging) && Boolean(_loc3_.paging.next))
         {
            this.pagingCall(_loc3_.paging.next,param2);
         }
         else if(param2 != null)
         {
            param2(null,"no page");
         }
      }
      
      protected function previousPage(param1:Object, param2:Function = null) : void
      {
         var _loc3_:Object = this.getRawResult(param1);
         if(Boolean(_loc3_) && Boolean(_loc3_.paging) && Boolean(_loc3_.paging.previous))
         {
            this.pagingCall(_loc3_.paging.previous,param2);
         }
         else if(param2 != null)
         {
            param2(null,"no page");
         }
      }
      
      protected function handleRequestLoad(param1:FacebookRequest) : void
      {
         var _loc3_:Object = null;
         var _loc4_:IResultParser = null;
         var _loc2_:Function = this.openRequests[param1];
         if(_loc2_ === null)
         {
            delete this.openRequests[param1];
         }
         if(param1.success)
         {
            _loc3_ = "data" in param1.data ? param1.data.data : param1.data;
            this.resultHash[_loc3_] = param1.data;
            if(this.parserHash[param1] is IResultParser)
            {
               _loc4_ = this.parserHash[param1] as IResultParser;
               _loc3_ = _loc4_.parse(_loc3_);
               this.parserHash[param1] = null;
               delete this.parserHash[param1];
            }
            if(_loc2_ != null)
            {
               _loc2_(_loc3_,null);
            }
         }
         else if(_loc2_ != null)
         {
            _loc2_(null,param1.data);
         }
         delete this.openRequests[param1];
      }
      
      protected function callRestAPI(param1:String, param2:Function = null, param3:* = null, param4:String = "GET") : void
      {
         var _loc6_:IResultParser = null;
         if(param3 == null)
         {
            param3 = {};
         }
         param3.format = "json";
         if(this.session != null)
         {
            param3.access_token = this.session.accessToken;
         }
         var _loc5_:FacebookRequest = new FacebookRequest(FacebookURLDefaults.API_URL,param4,param2);
         this.openRequests[_loc5_] = param2;
         if(this.parserHash[param3["queries"]] is IResultParser)
         {
            _loc6_ = this.parserHash[param3["queries"]] as IResultParser;
            this.parserHash[param3["queries"]] = null;
            delete this.parserHash[param3["queries"]];
            this.parserHash[_loc5_] = _loc6_;
         }
         _loc5_.call("/method/" + param1,param3,this.handleRequestLoad);
      }
      
      protected function fqlQuery(param1:String, param2:Function = null, param3:Object = null) : void
      {
         var _loc4_:String = null;
         for(_loc4_ in param3)
         {
            param1 = param1.replace(new RegExp("\\{" + _loc4_ + "\\}","g"),param3[_loc4_]);
         }
         this.callRestAPI("fql.query",param2,{"query":param1});
      }
      
      protected function fqlMultiQuery(param1:FQLMultiQuery, param2:Function = null, param3:IResultParser = null) : void
      {
         this.parserHash[param1.toString()] = param3 != null ? param3 : new FQLMultiQueryParser();
         this.callRestAPI("fql.multiquery",param2,{"queries":param1.toString()});
      }
      
      protected function deleteObject(param1:String, param2:Function = null) : void
      {
         var _loc3_:Object = {"method":"delete"};
         this.api(param1,param2,_loc3_,URLRequestMethod.POST);
      }
      
      protected function getImageUrl(param1:String, param2:String = null) : String
      {
         return FacebookURLDefaults.GRAPH_URL + "/" + param1 + "/picture" + (param2 != null ? "?type=" + param2 : "");
      }
   }
}

