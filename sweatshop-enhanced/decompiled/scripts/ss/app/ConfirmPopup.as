package ss.app
{
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.utils.MovieClipListener;
   import ss.utils.AudioUtils;
   
   public class ConfirmPopup extends EventDispatcher implements IDestroyable
   {
      
      public static const CLICK:String = "onClick";
      
      private var _mcl:MovieClipListener;
      
      private var _mc:MovieClip;
      
      private var _btn:InteractiveObject;
      
      private var _deactivateRadius:Number;
      
      public function ConfirmPopup(param1:MovieClip, param2:InteractiveObject = null, param3:Number = 150)
      {
         super();
         this._mc = param1;
         this._btn = param2;
         this._mcl = new MovieClipListener(param1);
         this._mcl.addEventListener(Event.CHANGE,this.onChangeFrame);
         this.hide();
         this._mc.addEventListener(MouseEvent.CLICK,this.onClick);
         this._mc.addEventListener(Event.ENTER_FRAME,this.onFrame);
         this._deactivateRadius = param3;
      }
      
      private function onFrame(param1:Event) : void
      {
         if(this._mc.visible && this._mc.mouseX * this._mc.mouseX + this._mc.mouseY * this._mc.mouseY > this._deactivateRadius * this._deactivateRadius)
         {
            this.no(false);
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         switch(param1.target.name)
         {
            case "yes":
               AudioUtils.uiYes();
               dispatchEvent(new CustomEvent(CLICK,{"yes":true}));
               break;
            case "no":
               this.no();
         }
      }
      
      private function no(param1:Boolean = true) : void
      {
         if(param1)
         {
            AudioUtils.uiNo();
         }
         dispatchEvent(new CustomEvent(CLICK,{"yes":false}));
      }
      
      private function onChangeFrame(param1:Event) : void
      {
         if(this._mcl.currentLabel == "done")
         {
            this._mcl.mc.stop();
         }
      }
      
      public function show() : void
      {
         this._mcl.mc.gotoAndPlay("show");
         this._mcl.mc.visible = true;
         if(this._btn)
         {
            this._btn.mouseEnabled = false;
         }
      }
      
      public function hide() : void
      {
         this._mcl.mc.gotoAndStop("hide");
         this._mcl.mc.visible = false;
         if(this._btn)
         {
            this._btn.mouseEnabled = true;
         }
      }
      
      public function destroy() : void
      {
         this._mc.removeEventListener(MouseEvent.CLICK,this.onClick);
         this._mc.removeEventListener(Event.ENTER_FRAME,this.onFrame);
         this._mcl.removeEventListener(Event.CHANGE,this.onChangeFrame);
         this._mcl.destroy();
         this._mc.stop();
      }
   }
}

