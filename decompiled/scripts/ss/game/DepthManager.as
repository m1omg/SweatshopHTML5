package ss.game
{
   import flash.geom.Point;
   
   public class DepthManager
   {
      
      public static const MINIMUM:String = "MINIMUM";
      
      public static const DRAGGABLE:String = "DRAGGABLE";
      
      public static const SHADOW:String = "SHADOW";
      
      public static const FIRE_HAZARD:String = "FIRE_HAZARD";
      
      public static const BELT:String = "BELT";
      
      public static const BELT_NODE:String = "BELT_NODE";
      
      public static const WORKER_BOT:String = "WORKER_BOT";
      
      public static const WORKER_TOP:String = "WORKER_TOP";
      
      public static const WORKER_STARS:String = "WORKER_STARS";
      
      public static const WORKER_EFFECT:String = "WORKER_EFFECT";
      
      public static const ITEM:String = "ITEM";
      
      public static const ITEM_FIRE:String = "ITEM_FIRE";
      
      public static const ITEM_PROGRESS_BAR:String = "ITEM_PROGRESS_BAR";
      
      public static const VALUE_MAP:String = "VALUE_MAP";
      
      public static const DRAG_MAP:String = "DRAG_MAP";
      
      public static const FEATURE_TILE_EFFECT:String = "FEATURE_TILE_EFFECT";
      
      public static const ENVIRONMENT_BG:String = "ENVIRONMENT_BG";
      
      public static const ENVIRONMENT_FG:String = "ENVIRONMENT_FG";
      
      public static const ENVIRONMENT_TILES:String = "ENVIRONMENT_TILES";
      
      public static const CONTROL_PANEL:String = "CONTROL_PANEL";
      
      public static const TOOLTIPS:String = "TOOLTIPS";
      
      public static const WIN_LOSE_OVERLAY:String = "WIN_LOSE_OVERLAY";
      
      public static const FEATURE_HIT:String = "FEATURE_HIT";
      
      public static const DIALOG:String = "DIALOG";
      
      public static const SELECT_POPUP:String = "SELECT_POPUP";
      
      public static const PAUSE_MENU:String = "PAUSE_MENU";
      
      public static const GLOBAL_UI:String = "GLOBAL_UI";
      
      public function DepthManager()
      {
         super();
      }
      
      public static function getDepth(param1:String, param2:Point = null, param3:Point = null) : Number
      {
         if(!param2)
         {
            param2 = new Point();
         }
         if(!param3)
         {
            param3 = new Point();
         }
         switch(param1)
         {
            case MINIMUM:
               return -10000;
            case SHADOW:
               return 0;
            case FIRE_HAZARD:
               return 9 + 20 * param2.y;
            case BELT:
               return 10 + 20 * param2.y;
            case BELT_NODE:
               return 14 + 20 * (param2.y + 1) + param2.x / 100;
            case WORKER_BOT:
               return 16 + 20 * param2.y + param3.y / 40 + param2.x / 80;
            case WORKER_TOP:
               return 15 + 20 * (param2.y + 1) + param3.y / 40 + param2.x / 80;
            case WORKER_EFFECT:
               return 15.5 + 20 * (param2.y + 1) + param3.y / 40 + param2.x / 80;
            case WORKER_STARS:
               return 18 + 20 * (param2.y + 1) + param3.y / 40 + param2.x / 80;
            case ITEM:
               return 11 + 20 * (param2.y + 1) + param3.y / 20 + param2.x / 10;
            case ITEM_FIRE:
               return 12 + 20 * (param2.y + 1) + param3.y / 20 + param2.x / 10;
            case FEATURE_TILE_EFFECT:
               return 3;
            case DRAG_MAP:
               return 2;
            case VALUE_MAP:
               return 1;
            case ENVIRONMENT_BG:
               return -1000;
            case ENVIRONMENT_TILES:
               return -999;
            case ENVIRONMENT_FG:
               return -998;
            case ITEM_PROGRESS_BAR:
               return 5000;
            case TOOLTIPS:
               return 5001;
            case CONTROL_PANEL:
               return 6000;
            case DRAGGABLE:
               return 7000;
            case SELECT_POPUP:
               return 7020;
            case WIN_LOSE_OVERLAY:
               return 7999;
            case DIALOG:
               return 8000;
            case PAUSE_MENU:
               return 9002;
            case GLOBAL_UI:
               return 10000;
            default:
               return 0;
         }
      }
   }
}

