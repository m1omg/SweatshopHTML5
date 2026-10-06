package ss.app.screens.select
{
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import org.fatlib.events.CustomEvent;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.utils.Tween;
   import ss.app.App;
   import ss.utils.AudioUtils;
   
   public class WorldDialog extends EventDispatcher implements IDestroyable
   {
      
      public static const LEVEL_SELECTED:String = "onLevelSelected";
      
      public static const LEVEL_DESELECTED:String = "onLevelDeelected";
      
      private var _mc:MovieClip;
      
      private var _icons:Array;
      
      public function WorldDialog(param1:MovieClip)
      {
         var _loc3_:LevelIcon = null;
         super();
         this._mc = param1;
         this._icons = new Array();
         var _loc2_:int = 1;
         while(_loc2_ <= 10)
         {
            _loc3_ = new LevelIcon(this._mc["lev" + _loc2_]);
            _loc3_.addEventListener(LevelIcon.CLICK,this.onClickIcon);
            this._icons.push(_loc3_);
            _loc2_++;
         }
      }
      
      private function onClickIcon(param1:CustomEvent) : void
      {
         var _loc2_:String = param1.data.level;
         var _loc3_:LevelIcon = param1.currentTarget as LevelIcon;
         AudioUtils.uiOpen();
         dispatchEvent(new CustomEvent(LEVEL_SELECTED,{"level":_loc2_}));
      }
      
      public function hide(param1:Boolean = false, param2:Function = null) : void
      {
         if(param1)
         {
            Tween.add(this._mc,100,{"alpha":0},null,param2);
         }
         else
         {
            this._mc.alpha = 0;
         }
      }
      
      public function show(param1:int, param2:Boolean = false, param3:Function = null) : void
      {
         var _loc5_:LevelIcon = null;
         var _loc6_:String = null;
         var _loc4_:int = 1;
         while(_loc4_ <= 10)
         {
            _loc5_ = this._icons[_loc4_ - 1];
            _loc6_ = ((param1 - 1) * 10 + _loc4_).toString();
            _loc5_.level = _loc6_;
            _loc5_.state = App.instance.session.getLevelState(_loc6_);
            _loc5_.isHighestUnlocked = App.instance.session.getHighestLevelUnlockedUnfinished() == _loc5_.level;
            _loc5_.refresh();
            _loc4_++;
         }
         this._mc["title"].text = App.instance.text.getText("select.world." + param1);
         if(App.instance.session.getHighestWorldUnlocked() >= param1)
         {
            this._mc["subtitle"].htmlText = App.instance.text.getText("select.world." + param1 + ".sub");
         }
         else
         {
            this._mc["subtitle"].htmlText = "";
         }
         if(param2)
         {
            Tween.add(this._mc,100,{"alpha":1},null,param3);
         }
         else
         {
            this._mc.alpha = 1;
         }
      }
      
      public function select(param1:String) : void
      {
         var _loc2_:LevelIcon = null;
         for each(_loc2_ in this._icons)
         {
            if(_loc2_.level == param1)
            {
               _loc2_.selected = true;
            }
            else
            {
               _loc2_.selected = false;
            }
         }
      }
      
      public function deselectAll() : void
      {
         var _loc1_:LevelIcon = null;
         for each(_loc1_ in this._icons)
         {
            _loc1_.selected = false;
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:LevelIcon = null;
         for each(_loc1_ in this._icons)
         {
            _loc1_.removeEventListener(LevelIcon.CLICK,this.onClickIcon);
         }
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
   }
}

