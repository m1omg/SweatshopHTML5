package ss.remote
{
   import com.facebook.graph.Facebook;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.Security;
   import org.fatlib.Log;
   import org.fatlib.events.CustomEvent;
   import ss.Constants;
   import ss.Values;
   import ss.app.App;
   
   public class Social extends EventDispatcher
   {
      
      public static const TWITTER:String = "TWITTER";
      
      public static const FACEBOOK:String = "FACEBOOK";
      
      private var _currentShareable:Shareable;
      
      public function Social()
      {
         super();
      }
      
      public function init() : void
      {
         Log.log("[Social] init");
         Security.loadPolicyFile("http://profile.ak.fbcdn.net/crossdomain.xml");
         if(ExternalInterface.available)
         {
            if(Values.IS_LIVE)
            {
               Facebook.init(Values.FB_LIVE_APP_ID);
            }
            else
            {
               Facebook.init(Values.FB_DEV_APP_ID);
            }
         }
      }
      
      public function share(param1:Shareable, param2:String) : void
      {
         if(Values.SUPPRESS_REMOTE_CALLS)
         {
            this.done();
            return;
         }
         Log.log("[Social] share " + param1 + " to " + param2);
         this._currentShareable = param1;
         if(param2 == TWITTER)
         {
            this._shareToTwitter();
         }
         else if(param2 == FACEBOOK)
         {
            this._shareToFacebook();
         }
         if(param1.type == Constants.SHAREABLE_KARMA)
         {
            App.instance.tracking.karmaShared(param1.id,param2);
         }
         else
         {
            App.instance.tracking.trophyShared(param1.id,param2);
         }
      }
      
      private function _shareToFacebook() : void
      {
         var _loc1_:Object = null;
         if(ExternalInterface.available)
         {
            _loc1_ = {"perms":"publish_stream, user_status, user_about_me"};
            Facebook.login(this._onFacebookLogin,_loc1_);
         }
         else
         {
            this.done();
         }
      }
      
      private function _onFacebookLogin(param1:Object, param2:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         if(param1)
         {
            if(Values.IS_LIVE)
            {
               _loc4_ = Values.FACEBOOK_ICONS_PATH_LIVE + this._currentShareable.imageFilestub + ".jpg";
            }
            else
            {
               _loc4_ = Values.FACEBOOK_ICONS_PATH_DEV + this._currentShareable.imageFilestub + ".jpg";
            }
            _loc3_ = {
               "message":"I\'m playing Sweatshop at http://playsweatshop.com.",
               "picture":_loc4_,
               "caption":this._currentShareable.facebookCopy
            };
            Facebook.api("/me/feed",this._onPostToFacebookResult,_loc3_,"POST");
         }
         else
         {
            this.done();
         }
      }
      
      private function _onPostToFacebookResult(param1:Object, param2:Object) : void
      {
         if(param1)
         {
            this.done();
         }
         else
         {
            this.done();
         }
      }
      
      private function _shareToTwitter() : void
      {
         var _loc1_:String = this._currentShareable.twitterCopy.replace("#","%23");
         var _loc2_:URLRequest = new URLRequest("http://twitter.com/share?url=null&text=" + _loc1_);
         navigateToURL(_loc2_,"_blank");
         this.done();
      }
      
      private function done(param1:Object = null) : void
      {
         if(!param1)
         {
            param1 = {};
         }
         dispatchEvent(new CustomEvent(Event.COMPLETE,param1));
      }
   }
}

