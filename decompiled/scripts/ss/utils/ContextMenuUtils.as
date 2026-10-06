package ss.utils
{
   import flash.display.DisplayObjectContainer;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import ss.Constants;
   
   public class ContextMenuUtils
   {
      
      private static var _contextMenu:ContextMenu;
      
      public function ContextMenuUtils()
      {
         super();
      }
      
      public static function init(param1:DisplayObjectContainer) : void
      {
         _contextMenu = new ContextMenu();
         _contextMenu.hideBuiltInItems();
         _contextMenu.customItems.push(new ContextMenuItem("© Littleloud 2011"));
         _contextMenu.customItems.push(new ContextMenuItem(Constants.VERSION));
         param1.contextMenu = _contextMenu;
      }
   }
}

