package ss.game.entities
{
   import ss.game.core.Entity;
   
   public class Selection extends Entity
   {
      
      public static const DESELECTED_MSG:String = "DESELECTED_MSG";
      
      public static const POPUP_CLICKED_MSG:String = "POPUP_CLICKED_MSG";
      
      public static const ACTION_BUTTON:String = "select_action";
      
      public static const SELL_BUTTON:String = "select_sell";
      
      public static const CLOSE_BUTTON:String = "select_close";
      
      public var currentlySelectedID:String;
      
      public var dragRef:String;
      
      public function Selection()
      {
         super();
      }
      
      public function deselect() : void
      {
         broadcastLocalMessage(DESELECTED_MSG);
      }
   }
}

