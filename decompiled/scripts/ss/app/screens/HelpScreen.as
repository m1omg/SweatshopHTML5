package ss.app.screens
{
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import org.fatlib.utils.ArrayUtils;
   import org.fatlib.utils.DisplayUtils;
   import ss.app.App;
   import ss.utils.AudioUtils;
   import ss.utils.Utils;
   
   public class HelpScreen extends BasePopup
   {
      
      private static var PAGE:int = 1;
      
      private var _mc:MovieClip;
      
      private var _prevMusic:String;
      
      private var _numPages:int;
      
      public function HelpScreen()
      {
         super();
      }
      
      override public function handleAdded() : void
      {
         var _loc2_:FrameLabel = null;
         this._mc = App.instance.resources.instantiateMovieClip("help","HelpScreenSymbol");
         display.addChild(this._mc);
         this._prevMusic = App.instance.audio.currentMusicTrack;
         App.instance.audio.playMusic("results");
         Utils.fadeFromBGColor(display);
         this._mc.stop();
         var _loc1_:Array = [];
         for each(_loc2_ in this._mc.currentLabels)
         {
            _loc1_.push(_loc2_.name);
         }
         this._numPages = 1;
         while(ArrayUtils.contains(_loc1_,"page" + (this._numPages + 1)))
         {
            ++this._numPages;
         }
         this.updatePage();
      }
      
      private function updatePage() : void
      {
         if(PAGE > this._numPages)
         {
            PAGE = this._numPages;
         }
         if(PAGE < 1)
         {
            PAGE = 1;
         }
         this._mc.gotoAndStop("page" + PAGE);
         this._mc["left"].visible = PAGE > 1;
         this._mc["right"].visible = PAGE < this._numPages;
         this._mc["page"].text = PAGE.toString();
         DisplayUtils.recursiveStop(this._mc);
      }
      
      override protected function handleClicked(param1:String) : void
      {
         switch(param1)
         {
            case "left":
               AudioUtils.uiClick();
               --PAGE;
               this.updatePage();
               break;
            case "right":
               AudioUtils.uiClick();
               ++PAGE;
               this.updatePage();
         }
      }
      
      override public function handleRemoved() : void
      {
         if(this._prevMusic)
         {
            App.instance.audio.playMusic(this._prevMusic);
         }
      }
   }
}

