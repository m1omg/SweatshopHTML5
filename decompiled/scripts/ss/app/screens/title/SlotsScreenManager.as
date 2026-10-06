package ss.app.screens.title
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.fatlib.app.ScreenManager;
   import org.fatlib.events.CustomEvent;
   import ss.data.Session;
   import ss.utils.AudioUtils;
   import ss.utils.Utils;
   
   public class SlotsScreenManager extends ScreenManager
   {
      
      public static const CLOSE:String = "onClose";
      
      public static const ERASE:String = "onErase";
      
      public static const CONTINUE:String = "onContinue";
      
      public static const NEW:String = "onNew";
      
      public static const SLOTS_PAGE:String = "page1";
      
      public static const INFO_PAGE:String = "page2";
      
      public static const NAME_PAGE:String = "page3";
      
      private var _mc:MovieClip;
      
      private var _slotsInfo:Object;
      
      public var isNewGame:Boolean;
      
      public var newUsername:String;
      
      public var selectedSlot:int;
      
      public function SlotsScreenManager(param1:MovieClip)
      {
         super();
         this._mc = param1;
         this._slotsInfo = {};
         register(SLOTS_PAGE,SlotsScreen);
         register(INFO_PAGE,InfoScreen);
         register(NAME_PAGE,NameScreen);
         this._mc["close"].addEventListener(MouseEvent.CLICK,this.onClickClose);
      }
      
      override public function goto(param1:String, param2:Object = null, param3:String = null) : void
      {
         var _loc4_:String = null;
         for each(_loc4_ in [SLOTS_PAGE,INFO_PAGE,NAME_PAGE])
         {
            this._mc[_loc4_].visible = _loc4_ == param1;
         }
         super.goto(param1,param2,param3);
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      override public function destroy() : void
      {
         this._mc["close"].removeEventListener(MouseEvent.CLICK,this.onClickClose);
      }
      
      public function setInfo(param1:int, param2:Session) : void
      {
         this._slotsInfo[param1] = param2;
      }
      
      public function getInfo(param1:int) : Session
      {
         return this._slotsInfo[param1];
      }
      
      public function hide() : void
      {
         this._mc.visible = false;
      }
      
      public function show() : void
      {
         this._mc.visible = true;
         Utils.tweenInPanel(this._mc);
         this.goto(SLOTS_PAGE);
      }
      
      public function eraseSlot(param1:int) : void
      {
         dispatchEvent(new CustomEvent(ERASE,{"slot":param1}));
         this.goto(SLOTS_PAGE);
      }
      
      public function loadSlot() : void
      {
         if(this.isNewGame)
         {
            dispatchEvent(new CustomEvent(NEW,{
               "slot":this.selectedSlot,
               "name":this.newUsername
            }));
         }
         else
         {
            dispatchEvent(new CustomEvent(CONTINUE,{"slot":this.selectedSlot}));
         }
      }
      
      private function onClickClose(param1:MouseEvent) : void
      {
         AudioUtils.uiClose();
         dispatchEvent(new Event(CLOSE));
      }
   }
}

