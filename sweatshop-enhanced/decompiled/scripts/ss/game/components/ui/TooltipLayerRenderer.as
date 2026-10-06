package ss.game.components.ui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import ss.Constants;
   import ss.game.Commands;
   import ss.game.DepthManager;
   import ss.game.Game;
   import ss.game.core.IMessageReceiver;
   import ss.game.core.Renderer;
   import ss.game.display.CashTooltip;
   import ss.game.display.IconTooltip;
   import ss.game.display.Tooltip;
   
   public class TooltipLayerRenderer extends Renderer implements IMessageReceiver
   {
      
      private var _container:Sprite;
      
      private var _tts:Array;
      
      public function TooltipLayerRenderer()
      {
         super();
      }
      
      override public function prepare() : void
      {
         Game.messenger.register(this,Commands.CREATE_CASH_TOOLTIP,Commands.CREATE_ICON_TOOLTIP);
         this._container = new Sprite();
         addElement(this._container).depth = DepthManager.getDepth(DepthManager.TOOLTIPS);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Commands.CREATE_CASH_TOOLTIP:
               this.launchCashTooltip(param2);
               break;
            case Commands.CREATE_ICON_TOOLTIP:
               this.launchIconTooltip(param2);
         }
      }
      
      override public function destroy() : void
      {
         var _loc1_:Tooltip = null;
         super.destroy();
         while(this._container.numChildren > 0)
         {
            _loc1_ = this._container.getChildAt(0) as Tooltip;
            this._container.removeChild(_loc1_);
            _loc1_.destroy();
         }
      }
      
      private function launchCashTooltip(param1:Object) : void
      {
         var _loc2_:CashTooltip = new CashTooltip(true);
         var _loc3_:Point = Game.canvas.tileCentreToScreen(param1.tile);
         var _loc4_:Number = 0;
         if(Boolean(param1.bonus) && param1.bonus != 0)
         {
            _loc4_ = Number(param1.bonus);
         }
         _loc2_.setAmount(param1.amount,false,_loc4_);
         _loc2_.color = Constants.DARK_GREEN;
         if(param1.color)
         {
            _loc2_.color = param1.color;
         }
         var _loc5_:Number = 0;
         if(param1.offsetY)
         {
            _loc5_ = Number(param1.offsetY);
         }
         _loc2_.x = _loc3_.x;
         _loc2_.y = _loc3_.y + _loc5_;
         _loc2_.addEventListener(Event.COMPLETE,this.onComplete,false,0,true);
         this._container.addChild(_loc2_);
      }
      
      private function launchIconTooltip(param1:Object) : void
      {
         var _loc2_:IconTooltip = new IconTooltip(param1.icon);
         var _loc3_:Point = Game.canvas.tileCentreToScreen(param1.tile);
         var _loc4_:Number = 0;
         if(param1.offsetY)
         {
            _loc4_ = Number(param1.offsetY);
         }
         _loc2_.x = _loc3_.x;
         _loc2_.y = _loc3_.y + _loc4_;
         _loc2_.addEventListener(Event.COMPLETE,this.onComplete,false,0,true);
         this._container.addChild(_loc2_);
      }
      
      private function onComplete(param1:Event) : void
      {
         var _loc2_:Tooltip = param1.target as Tooltip;
         this._container.removeChild(_loc2_);
         _loc2_.destroy();
      }
   }
}

