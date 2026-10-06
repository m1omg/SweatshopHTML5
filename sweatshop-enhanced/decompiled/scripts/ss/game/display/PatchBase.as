package ss.game.display
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import ss.app.App;
   import ss.utils.Utils;
   
   public class PatchBase extends HUDButton
   {
      
      protected var _price:Number;
      
      private var _isActive:Boolean;
      
      private var _label:MovieClip;
      
      public function PatchBase(param1:MovieClip)
      {
         super(param1);
         _mc["button"].visible = false;
         _mc["arrow"].visible = false;
         _mc["menuhit"].visible = false;
         _mc["menuhit"].stop();
         _mc["menuhit"].mouseEnabled = _mc["menuhit"].mouseChildren = false;
         _mc["nuevo"].visible = false;
      }
      
      public function set icon(param1:String) : void
      {
         _mc["icon"].gotoAndStop(param1);
         this.applyIconEffect();
         refresh();
      }
      
      protected function applyIconEffect() : void
      {
      }
      
      public function showLabel() : void
      {
         if(this._label)
         {
            this._label.visible = true;
         }
         Utils.tweenInTooltip(this._label);
      }
      
      public function hideLabel() : void
      {
         if(this._label)
         {
            this._label.visible = false;
         }
      }
      
      public function setLabel(param1:String, param2:String = null, param3:int = 16777215) : void
      {
         this._label = _mc["tooltip"];
         this._label["label"].text = App.instance.text.getText(param1);
         if(param2)
         {
            this._label["effect"].text = App.instance.text.getText(param2);
            (this._label["effect"] as TextField).textColor = param3;
         }
         else
         {
            this._label["effect"].visible = false;
         }
         refresh();
         this.hideLabel();
      }
      
      public function set price(param1:Number) : void
      {
         this._price = param1;
         _mc["button"].visible = true;
         _mc["button"]["price"]["price"].text = Utils.formatCash(param1);
         refresh();
      }
      
      public function set isNew(param1:Boolean) : void
      {
         _mc["nuevo"].visible = param1;
      }
   }
}

