package ss.app.screens
{
   import org.fatlib.app.Screen;
   import ss.app.App;
   import ss.utils.Utils;
   
   public class SplashScreen extends Screen
   {
      
      private var Splash:Class = SplashScreen_Splash;
      
      private var _clicked:Boolean;
      
      public function SplashScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         display.addChild(new this.Splash());
         Utils.fadeFromBGColor(display);
         _delay.create(3000,this.done);
      }
      
      private function done() : void
      {
         if(!App.instance.data)
         {
            _delay.create(500,this.done);
         }
         else
         {
            gotoScreen(App.TITLE_SCREEN);
         }
      }
      
      override protected function handleClicked(param1:String) : void
      {
         if(this._clicked)
         {
            return;
         }
         this._clicked = true;
         this.done();
      }
   }
}

