package ss.game.display
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.fatlib.interfaces.IDestroyable;
   import org.fatlib.utils.ArrayUtils;
   import ss.game.Game;
   
   public class PatchCollection implements IDestroyable
   {
      
      private var _mc:MovieClip;
      
      private var _patches:Array;
      
      private var _anyAvailable:Boolean;
      
      public var canOpenMenus:Boolean = true;
      
      public function PatchCollection(param1:MovieClip)
      {
         super();
         this._mc = param1;
         this.visible = false;
         this._patches = [];
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._mc.visible = param1;
      }
      
      public function get anyAvailable() : Boolean
      {
         return this._anyAvailable;
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      public function init(param1:XML, param2:Array) : void
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:MovieClip = null;
         var _loc7_:PatchBase = null;
         var _loc8_:Boolean = false;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:Object = null;
         var _loc12_:String = null;
         this._anyAvailable = false;
         var _loc3_:int = 1;
         for each(_loc4_ in param1.children())
         {
            if(_loc4_.nodeKind() != "text")
            {
               _loc5_ = _loc4_.@type;
               _loc6_ = this._mc["patch" + _loc3_];
               _loc8_ = true;
               _loc9_ = _loc4_.@color.toString();
               _loc10_ = this.getColorRGB(_loc9_);
               switch(_loc4_.name().toString())
               {
                  case "menu":
                     _loc7_ = new DropdownPatch(_loc6_,this._mc[_loc5_],_loc4_,param2);
                     _loc7_.addEventListener(DropdownPatch.OVER,this.onOpenDropdown);
                     _loc7_.addEventListener(DropdownPatch.DOWN,this.onOpenDropdown);
                     _loc7_.addEventListener(DropdownPatch.OUT,this.onCloseDropdown);
                     break;
                  case "icon":
                     _loc11_ = {
                        "key":_loc4_.@key.toString(),
                        "type":_loc4_.@type.toString(),
                        "category":_loc4_.@category.toString(),
                        "color":_loc10_
                     };
                     _loc12_ = _loc4_.@category;
                     _loc7_ = new IconPatch(_loc6_,_loc11_,_loc9_);
                     _loc7_.name = _loc11_.type;
                     _loc8_ = Game.level.getAvailibility(_loc5_);
                     _loc7_.isActive = _loc8_;
                     if(_loc8_)
                     {
                        _loc7_.price = Game.shop.getBuyPrice(_loc11_.key,Game.level.world);
                     }
                     if(ArrayUtils.contains(param2,_loc11_.type))
                     {
                        _loc7_.isNew = true;
                     }
                     break;
                  default:
                     throw new Error("Unknown node - " + _loc4_.name().toString());
               }
               _loc7_.icon = _loc4_.@type;
               _loc7_.setLabel(_loc4_.@resname,_loc4_.@effect,_loc10_);
               _loc7_.addEventListener(PatchEvent.CLICK,this.onClick);
               this._patches.push(_loc7_);
               _loc3_++;
               this._anyAvailable = this._anyAvailable || _loc8_;
            }
         }
      }
      
      private function onOpenDropdown(param1:Event) : void
      {
         var _loc2_:DropdownPatch = param1.target as DropdownPatch;
         this.closeAll(_loc2_.name);
         if(this.canOpenMenus)
         {
            _loc2_.open();
         }
      }
      
      private function onCloseDropdown(param1:Event) : void
      {
         var _loc2_:DropdownPatch = param1.target as DropdownPatch;
         this.closeAll();
      }
      
      public function getColorRGB(param1:String) : int
      {
         var _loc2_:int = 16777215;
         if(param1 == "yellow")
         {
            _loc2_ = 16776960;
         }
         if(param1 == "cyan")
         {
            _loc2_ = 65535;
         }
         if(param1 == "orange")
         {
            _loc2_ = 16750848;
         }
         return _loc2_;
      }
      
      public function hilite(param1:Boolean, param2:String, param3:Boolean = false) : Boolean
      {
         var _loc5_:HUDButton = null;
         var _loc4_:Boolean = false;
         for each(_loc5_ in this._patches)
         {
            _loc4_ ||= _loc5_.hilite(param1,param2,param3);
         }
         return _loc4_;
      }
      
      private function onClick(param1:Event) : void
      {
         var _loc2_:PatchBase = null;
         for each(_loc2_ in this._patches)
         {
            if(_loc2_ is DropdownPatch && param1.target != _loc2_)
            {
               (_loc2_ as DropdownPatch).close();
            }
         }
      }
      
      public function closeAll(param1:String = null) : void
      {
         var _loc2_:PatchBase = null;
         for each(_loc2_ in this._patches)
         {
            if(_loc2_ is DropdownPatch && _loc2_.name != param1)
            {
               (_loc2_ as DropdownPatch).close();
            }
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:PatchBase = null;
         for each(_loc1_ in this._patches)
         {
            _loc1_.removeEventListener(PatchEvent.CLICK,this.onClick);
            _loc1_.removeEventListener(DropdownPatch.OVER,this.onOpenDropdown);
            _loc1_.removeEventListener(DropdownPatch.DOWN,this.onOpenDropdown);
            _loc1_.removeEventListener(DropdownPatch.OUT,this.onCloseDropdown);
            _loc1_.destroy();
         }
      }
   }
}

