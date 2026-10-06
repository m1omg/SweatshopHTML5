package ss.app.screens.title
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import ss.utils.AudioUtils;
   
   public class NameScreen extends BaseSlotsScreen
   {
      
      private var _username:TextField;
      
      public function NameScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         this._username = mc["username"];
         this._username.text = "";
         this._username.restrict = "A-Za-z0-9 !*():.,";
         this._username.maxChars = 12;
         mc.stage.focus = this._username;
         mc.addEventListener(MouseEvent.CLICK,this.onClick);
         mc.addEventListener(Event.ENTER_FRAME,this.onFrame);
         mc["ok"].visible = false;
      }
      
      override public function handleRemoved() : void
      {
         mc.removeEventListener(MouseEvent.CLICK,this.onClick);
         mc.removeEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         switch(param1.target.name)
         {
            case "back":
               gotoScreen(SlotsScreenManager.SLOTS_PAGE);
               break;
            case "ok":
               AudioUtils.uiClick();
               slotsManager.isNewGame = true;
               slotsManager.newUsername = this._username.text;
               slotsManager.loadSlot();
         }
      }
      
      private function onFrame(param1:Event) : void
      {
         mc["ok"].visible = this._username.text.length > 0;
      }
   }
}

