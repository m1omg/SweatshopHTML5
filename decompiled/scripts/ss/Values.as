package ss
{
   import flash.geom.Rectangle;
   
   public class Values
   {
      
      private static var _ENERGY_MR:Number;
      
      private static var _ENERGY_MT:Number;
      
      public static var IS_LIVE:Boolean = false;
      
      public static var IS_LOCAL:Boolean = false;
      
      public static var DEBUG_MODE:Boolean = false;
      
      public static var SINGLE_LEVEL_MODE:Boolean = false;
      
      public static var ENABLE_OMNITURE:Boolean = true;
      
      public static var FB_DEV_APP_ID:String = "123981551019464";
      
      public static var FB_LIVE_APP_ID:String = "186336634758681";
      
      public static var GOOGLE_ANALYTICS_LIVE_ID:String = "UA-24545211-1";
      
      public static var LOG_TO_CONSOLE:Boolean = true;
      
      public static var FIXED_TIMESTEP:Boolean = false;
      
      public static var DEPTH_SORT_INTERVAL:Number = 0.5;
      
      public static var SUPPRESS_REMOTE_CALLS:Boolean = false;
      
      public static var CURRENT_URL:String = "";
      
      public static var FACEBOOK_ICONS_PATH_LIVE:String = "http://www.playsweatshop.com/_images/fb_icons/";
      
      public static var FACEBOOK_ICONS_PATH_DEV:String = "http://www.littleloud.com/live/sweatshop/site_/_images/fb_icons/";
      
      public static var BG_COLOR:int = 0;
      
      public static var DIMENSIONS:Object = {
         1:{
            "w":16,
            "h":9,
            "tw":43,
            "th":43,
            "scale":1,
            "belt":18
         },
         2:{
            "w":18,
            "h":10,
            "tw":38,
            "th":38,
            "scale":0.9,
            "belt":15
         },
         3:{
            "w":20,
            "h":11,
            "tw":35,
            "th":35,
            "scale":0.8,
            "belt":12
         }
      };
      
      public static var ACTIVE_TILE_AREAS:Object = {
         1:new Rectangle(1,0,14,8),
         2:new Rectangle(1,0,15,9),
         3:new Rectangle(1,0,17,10)
      };
      
      public static var HUD_COMPACT:Boolean = true;
      
      public static var FEMALE_CHANCE:Number = 0.6;
      
      public static var STITCH_FRACTION:Number = 0.9;
      
      public static var SLOW_BELT_SPEED:Number = 0.6;
      
      public static var FAST_BELT_SPEED:Number = 1.2;
      
      public static var CASH_ON_PACK:Boolean = true;
      
      public static var INTELIGENT_PACKING:Boolean = true;
      
      public static var DOUBLE_CLICK_SELECTION_TO_USE:Boolean = true;
      
      public static var DRAG_TILE_X_OFFSET:int = 0;
      
      public static var DRAG_TILE_Y_OFFSET:int = 0;
      
      public static var ENERGY_T0:Number = -5;
      
      public static var ENERGY_R0:Number = 2;
      
      public static var ENERGY_T1:Number = -0.5;
      
      public static var ENERGY_R1:Number = 10;
      
      public static var NEUTRAL_ENERGY_THRESHOLD:Number = 60;
      
      public static var CANCEL_TIREDNESS_COUNT_ENERGY_THRESHOLD:Number = 40;
      
      public static var SAD_ENERGY_THRESHOLD:Number = 30;
      
      public static var MAX_TIREDNESS_STRIKES:int = 2;
      
      public static var SAD_SKILL_MULTIPLIER:Number = 1;
      
      public static var WORKER_EXHAUSTED_TIME:Number = 10;
      
      public static var WORKER_FIRED_ANIMATION_TIME:Number = 2;
      
      public static var WORKER_LEVELLED_UP_DANCE_TIME:Number = 3;
      
      public static var WORKER_HEAD_ON_TOP:Boolean = false;
      
      public static var WORKER_OUTLINES:Boolean = false;
      
      public static var SHOW_ITEM_PROGRESS_BAR:Boolean = true;
      
      public static var STORY_SHORT_PAUSE:Number = 1.5;
      
      public static var STORY_LONG_PAUSE:Number = 3;
      
      public static var STORY_TEXT_SHORT_PAUSE:Number = 0.8;
      
      public static var STORY_TEXT_LONG_PAUSE:Number = 1.6;
      
      public static var STORY_TEXT_SLOW_INTERVAL:Number = 0.05;
      
      public static var STORY_TEXT_MEDIUM_INTERVAL:Number = 0.03;
      
      public static var STORY_TEXT_FAST_INTERVAL:Number = 0.01;
      
      public static var STORY_TEXT_SHOW_NEXT_INTERVAL:Number = 0.5;
      
      public static var BURN_TIME:Number = 6;
      
      public static var WORKER_FLAMMABILITY:Number = 0.4;
      
      public static var BOX_FLAMMABILITY:Number = 0.4;
      
      public static var ITEM_FLAMMABILITY:Number = 0.4;
      
      public static var MINIMUM_HAZARD_SPARK_TIME:Number = 10;
      
      public static var SFX_VOLUME:Number = 1;
      
      public static var MUSIC_VOLUME:Number = 0.9;
      
      public static var GOLD_PERCENT:Number = 80;
      
      public static var SILVER_PERCENT:Number = 60;
      
      public static var TIME_WEIGHT:Number = 25;
      
      public static var CASH_WEIGHT:Number = 25;
      
      public static var QUALITY_WEIGHT:Number = 50;
      
      public static var FIRE_HAZARD_ACTIVATE_CHANCE:Number = 3;
      
      public static var LOW_ACCIDENT_RISK:Number = 2.5;
      
      public static var HIGH_ACCIDENT_RISK:Number = 5;
      
      public static const LOW_QUALITY_THRESHOLD:int = 18;
      
      public static const MIN_QUALITY_CHANGE_INTERVAL:int = 10;
      
      public function Values()
      {
         super();
      }
      
      public static function get ENERGY_MR() : Number
      {
         if(!_ENERGY_MR)
         {
            _ENERGY_MR = (ENERGY_R1 - ENERGY_R0) / 10;
         }
         return _ENERGY_MR;
      }
      
      public static function get ENERGY_MT() : Number
      {
         if(!_ENERGY_MT)
         {
            _ENERGY_MT = (ENERGY_T1 - ENERGY_T0) / 10;
         }
         return _ENERGY_MT;
      }
   }
}

