package ss.utils
{
   import org.fatlib.interfaces.IDestroyable;
   import ss.Constants;
   
   public class TextManager implements IDestroyable
   {
      
      public function TextManager()
      {
         super();
      }
      
      public function getText(param1:String) : String
      {
         switch(param1)
         {
            case "ui.tooltip.sound_on":
               return "SOUND ON";
            case "ui.tooltip.sound_off":
               return "SOUND OFF";
            case "ui.tooltip.player":
               return "MY C.V.";
            case "ui.tooltip.help":
               return "HELP";
            case "ui.tooltip.pause":
               return "PAUSE";
            case "title.slots.new":
               return "<NEW GAME>";
            case "title.slots.select.empty":
               return "SELECT AN EMPTY SLOT";
            case "title.slots.select.load":
               return "SELECT A GAME TO LOAD";
            case "title.slots.name":
               return "ENTER YOUR NAME";
            case "stats.trophy.secret":
               return "SECRET!";
            case "select.world.1":
               return "FACTORY 1";
            case "select.world.2":
               return "FACTORY 2";
            case "select.world.3":
               return "FACTORY 3";
            case "select.world.1.sub":
               return "Supplier of goods to <font color=\"#DD0000\">Crymark</font>";
            case "select.world.2.sub":
               return "Supplier of goods to <font color=\"#DD0000\">TopSham</font>";
            case "select.world.3.sub":
               return "Supplier of goods to <font color=\"#DD0000\">MaulMart</font>";
            case "select.score.none":
               return "N/A";
            case "selection.feature.action":
               return "USE";
            case "selection.feature.sell":
               return "SCRAP";
            case "selection.unit.action":
               return "UPGRADE";
            case "selection.unit.sell":
               return "FIRE";
            case "selection.unit.max":
               return "MAX";
            case "entity.child":
               return "CHILD";
            case "entity.hat_maker":
               return "HAT MAKER";
            case "entity.shirt_maker":
               return "SHIRT MAKER";
            case "entity.bag_maker":
               return "BAG MAKER";
            case "entity.shoe_maker":
               return "SHOE MAKER";
            case "entity.packer":
               return "PACKER";
            case "entity.fire_officer":
               return "FIRE OFFICER";
            case "entity.engineer":
               return "ENGINEER";
            case "entity.superstar":
               return "ROBOT";
            case "hud.features":
               return "FEATURES";
            case "hud.special":
               return "SPECIAL WORKERS";
            case "hud.belt.slow":
               return "BELT SPEED";
            case "hud.belt.fast":
               return "BELT SPEED";
            case "entity.water":
               return "WATER";
            case "entity.water.effect":
               return "ENERGY+";
            case "entity.cola":
               return "COLA";
            case "entity.cola.effect":
               return "ENERGY++";
            case "entity.juice":
               return "JUICE";
            case "entity.juice.effect":
               return "ENERGY+++";
            case "entity.fan":
               return "FAN";
            case "entity.fan.effect":
               return "CASH+";
            case "entity.toilet":
               return "TOILET";
            case "entity.toilet.effect":
               return "CASH++";
            case "entity.heater":
               return "HEATER";
            case "entity.heater.effect":
               return "CASH+++";
            case "entity.radio":
               return "RADIO";
            case "entity.radio.effect":
               return "SKILL+";
            case "entity.sign":
               return "LED SIGN";
            case "entity.sign.effect":
               return "SKILL++";
            case "entity.tannoy":
               return "TANNOY";
            case "entity.tannoy.effect":
               return "SKILL+++";
            case "belt.ready":
               return "READY";
            case "belt.done":
               return "DONE";
            case "belt.hat":
               return "HATS";
            case "belt.hat_special":
               return "HATS";
            case "belt.shoes":
               return "SHOES";
            case "belt.shoes_special":
               return "SHOES";
            case "belt.shirt":
               return "SHIRTS";
            case "belt.shirt_special":
               return "SHIRTS";
            case "belt.bag":
               return "BAGS";
            case "belt.bag_special":
               return "BAGS";
            case Constants.BRONZE_MEDAL:
               return "BRONZE";
            case Constants.SILVER_MEDAL:
               return "SILVER";
            case Constants.GOLD_MEDAL:
               return "GOLD";
            default:
               return "_" + param1;
         }
      }
      
      public function hasText(param1:String) : Boolean
      {
         return this.getText(param1) != "_" + param1;
      }
      
      public function destroy() : void
      {
      }
   }
}

