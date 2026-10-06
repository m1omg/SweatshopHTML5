package ss.app.screens.select
{
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.interfaces.IDestroyable;
   import ss.Constants;
   import ss.data.LevelState;
   
   public class LevelIcon extends EventDispatcher implements IDestroyable
   {
      
      public static const CLICK:String = "onClick";
      
      public var state:LevelState;
      
      public var level:String;
      
      public var isHighestUnlocked:Boolean;
      
      private var _mc:MovieClip;
      
      private var _selected:Boolean = false;
      
      private var _over:Boolean = false;
      
      public function LevelIcon(param1:MovieClip)
      {
         super();
         this._mc = param1;
         this._mc.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         this._mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         this._mc.addEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         dispatchEvent(new CustomEvent(CLICK,{"level":this.level}));
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         this._over = true;
         this.refresh();
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         this._over = false;
         this.refresh();
      }
      
      public function refresh() : void
      {
         var _loc2_:String = null;
         this._mc.mouseChildren = false;
         if(this.state.unlocked)
         {
            this._mc["label"].visible = true;
            this._mc["label"].text = this.level.toString();
            this._mc.useHandCursor = true;
            this._mc.buttonMode = true;
            this._mc.mouseEnabled = true;
         }
         else
         {
            this._mc["label"].visible = false;
            this._mc.useHandCursor = false;
            this._mc.buttonMode = false;
            this._mc.mouseEnabled = false;
         }
         var _loc1_:String = "patch_open";
         if(this.state.unlocked)
         {
            if(this._over || this._selected)
            {
               _loc1_ = "patch_over";
            }
         }
         else
         {
            _loc1_ = "patch_locked";
         }
         this._mc["bronze"].visible = this.state.medal == Constants.BRONZE_MEDAL;
         this._mc["silver"].visible = this.state.medal == Constants.SILVER_MEDAL;
         this._mc["gold"].visible = this.state.medal == Constants.GOLD_MEDAL;
         this._mc["nuevo"].visible = this.state.unlocked && !this.state.hasWon;
         for each(_loc2_ in ["patch_over","patch_open","patch_locked"])
         {
            this._mc[_loc2_].visible = _loc2_ == _loc1_;
         }
      }
      
      public function destroy() : void
      {
         this._mc.removeEventListener(MouseEvent.ROLL_OVER,this.onOver);
         this._mc.removeEventListener(MouseEvent.ROLL_OUT,this.onOut);
         this._mc.removeEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         this.refresh();
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
   }
}

