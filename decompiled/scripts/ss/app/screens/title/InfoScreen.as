package ss.app.screens.title
{
   import com.adobe.serialization.json.JSON;
   import flash.events.MouseEvent;
   import org.fatlib.Log;
   import ss.Constants;
   import ss.data.Session;
   import ss.utils.AudioUtils;
   
   public class InfoScreen extends BaseSlotsScreen
   {
      
      public function InfoScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Session = null;
         var _loc8_:Object = null;
         if(slotsManager.isNewGame)
         {
            _loc1_ = slotsManager.newUsername;
            _loc2_ = 0;
            _loc3_ = 0;
            _loc4_ = 0;
            _loc5_ = 0;
            _loc6_ = 0;
         }
         else
         {
            _loc7_ = slotsManager.getInfo(slotsManager.selectedSlot);
            Log.log("[InfoScreen] " + com.adobe.serialization.json.JSON.encode(_loc7_.toObject()));
            _loc1_ = _loc7_.username;
            _loc2_ = _loc7_.getLevelsCompleted();
            _loc3_ = _loc7_.getTrophiesAwarded();
            _loc8_ = _loc7_.getMedalCounts();
            _loc4_ = int(_loc8_[Constants.GOLD_MEDAL]);
            _loc5_ = int(_loc8_[Constants.SILVER_MEDAL]);
            _loc6_ = int(_loc8_[Constants.BRONZE_MEDAL]);
         }
         mc["username"].text = _loc1_;
         mc["stages"].text = _loc2_ + " / 30";
         mc["trophies"].text = _loc3_ + " / 20";
         mc["gold"].text = _loc4_;
         mc["silver"].text = _loc5_;
         mc["bronze"].text = _loc6_;
         mc.addEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      override public function handleRemoved() : void
      {
         mc.removeEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         switch(param1.target.name)
         {
            case "back":
               if(slotsManager.isNewGame)
               {
                  gotoScreen(SlotsScreenManager.NAME_PAGE);
               }
               else
               {
                  gotoScreen(SlotsScreenManager.SLOTS_PAGE);
               }
               break;
            case "cont":
               AudioUtils.uiNav();
               slotsManager.loadSlot();
         }
      }
   }
}

