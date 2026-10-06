package ss.app.screens.title
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.fatlib.events.CustomEvent;
   import ss.app.App;
   import ss.app.ConfirmPopup;
   import ss.data.Session;
   import ss.utils.AudioUtils;
   
   public class SlotsScreen extends BaseSlotsScreen
   {
      
      private var _confirm:ConfirmPopup;
      
      private var _selectedSlot:int;
      
      public function SlotsScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Session = null;
         var _loc1_:int = 1;
         while(_loc1_ <= 3)
         {
            mc["confirm" + _loc1_].visible = false;
            _loc2_ = mc["slot" + _loc1_];
            _loc2_["num"].text = _loc1_ + ".";
            _loc2_["num"].mouseEnabled = _loc2_["num"].tabEnabled = false;
            _loc2_["num"].text = _loc1_ + ".";
            _loc2_["num"].mouseEnabled = _loc2_["num"].tabEnabled = false;
            _loc2_["username"].mouseEnabled = _loc2_["username"].tabEnabled = false;
            _loc3_ = slotsManager.getInfo(_loc1_);
            if(_loc3_)
            {
               _loc2_["username"].text = _loc3_.username;
            }
            else
            {
               _loc2_["username"].text = App.instance.text.getText("title.slots.new");
               _loc2_["trash"].visible = false;
            }
            _loc1_++;
         }
         slotsManager.isNewGame = false;
         mc.addEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      override public function handleRemoved() : void
      {
         mc.removeEventListener(MouseEvent.CLICK,this.onClick);
         this.enableButtons();
         if(this._confirm)
         {
            this._confirm.removeEventListener(ConfirmPopup.CLICK,this.onClickConfirm);
            this._confirm.destroy();
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         switch(param1.target.parent.name)
         {
            case "slot1":
               this._selectedSlot = 1;
               break;
            case "slot2":
               this._selectedSlot = 2;
               break;
            case "slot3":
               this._selectedSlot = 3;
         }
         if(param1.target.name == "trash")
         {
            AudioUtils.uiConfirm();
            this.disableButtons();
            this._confirm = new ConfirmPopup(mc["confirm" + this._selectedSlot],mc);
            this._confirm.addEventListener(ConfirmPopup.CLICK,this.onClickConfirm);
            this._confirm.show();
         }
         else if(param1.target.name == "button")
         {
            AudioUtils.uiClick();
            if(slotsManager.getInfo(this._selectedSlot))
            {
               slotsManager.isNewGame = false;
               slotsManager.selectedSlot = this._selectedSlot;
               gotoScreen(SlotsScreenManager.INFO_PAGE);
            }
            else
            {
               slotsManager.selectedSlot = this._selectedSlot;
               slotsManager.isNewGame = true;
               gotoScreen(SlotsScreenManager.NAME_PAGE);
            }
         }
      }
      
      private function onClickConfirm(param1:CustomEvent) : void
      {
         this.enableButtons();
         if(param1.data.yes)
         {
            slotsManager.eraseSlot(this._selectedSlot);
         }
         this._confirm.hide();
         this._confirm.removeEventListener(ConfirmPopup.CLICK,this.onClickConfirm);
         this._confirm.destroy();
      }
      
      private function disableButtons() : void
      {
         var _loc1_:int = 1;
         while(_loc1_ <= 3)
         {
            mc["slot" + _loc1_].mouseChildren = mc["slot" + _loc1_].mouseEnabled = false;
            mc["slot" + _loc1_].tabChildren = mc["slot" + _loc1_].tabEnabled = false;
            _loc1_++;
         }
      }
      
      private function enableButtons() : void
      {
         var _loc1_:int = 1;
         while(_loc1_ <= 3)
         {
            mc["slot" + _loc1_].mouseChildren = mc["slot" + _loc1_].mouseEnabled = true;
            mc["slot" + _loc1_].tabChildren = mc["slot" + _loc1_].tabEnabled = true;
            _loc1_++;
         }
      }
   }
}

