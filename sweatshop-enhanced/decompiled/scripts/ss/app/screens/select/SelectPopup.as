package ss.app.screens.select
{
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.utils.Tween;
   import ss.app.App;
   import ss.data.Level;
   import ss.data.LevelState;
   import ss.utils.AudioUtils;
   import ss.utils.Utils;
   
   public class SelectPopup extends EventDispatcher implements IDestroyable
   {
      
      public static const PLAY:String = "onPlay";
      
      public static const CLOSE:String = "onClose";
      
      private var _mc:MovieClip;
      
      public function SelectPopup(param1:MovieClip)
      {
         super();
         this._mc = param1;
         this._mc.addEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      public function show(param1:String) : void
      {
         if(this._mc.alpha == 0)
         {
            Utils.tweenInPanel(this._mc);
         }
         var _loc2_:Level = App.instance.levels.getLevel(param1);
         var _loc3_:LevelState = App.instance.session.getLevelState(param1);
         this._mc["title"].text = _loc2_.title;
         this._mc["copy"].text = _loc2_.summary;
         this._mc["medal"].gotoAndStop(_loc3_.medal);
         if(_loc3_.score > 0)
         {
            this._mc["score"].text = _loc3_.score + "%";
         }
         else
         {
            this._mc["score"].text = App.instance.text.getText("select.score.none");
         }
      }
      
      public function hide(param1:Boolean = true) : void
      {
         if(param1)
         {
            Tween.add(this._mc,100,{"alpha":0});
         }
         else
         {
            this._mc.alpha = 0;
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         switch(param1.target.name)
         {
            case "start":
               dispatchEvent(new CustomEvent(PLAY));
               AudioUtils.uiClick();
               break;
            case "close":
               dispatchEvent(new CustomEvent(CLOSE));
               AudioUtils.uiClose();
         }
      }
      
      public function destroy() : void
      {
         this._mc.removeEventListener(MouseEvent.CLICK,this.onClick);
      }
   }
}

