package ss.app.process
{
   import org.fatlib.Log;
   import org.fatlib.process.SyncProcess;
   import ss.app.App;
   import ss.app.screens.ClientScreen;
   import ss.app.screens.CreditsScreen;
   import ss.app.screens.EndCreditsScreen;
   import ss.app.screens.EndScreen;
   import ss.app.screens.GameScreen;
   import ss.app.screens.HelpScreen;
   import ss.app.screens.MovieScreen;
   import ss.app.screens.OutroScreen;
   import ss.app.screens.PlayerScreen;
   import ss.app.screens.ResultsScreen;
   import ss.app.screens.SelectScreen;
   import ss.app.screens.SplashScreen;
   import ss.app.screens.TitleScreen;
   
   public class RegisterScreensProcess extends SyncProcess
   {
      
      public function RegisterScreensProcess()
      {
         super();
      }
      
      override public function execute() : void
      {
         Log.log("[RegisterScreensProcess] execute");
         App.instance.screens.register(App.TITLE_SCREEN,TitleScreen);
         App.instance.screens.register(App.SPLASH_SCREEN,SplashScreen);
         App.instance.screens.register(App.SELECT_SCREEN,SelectScreen);
         App.instance.screens.register(App.GAME_SCREEN,GameScreen);
         App.instance.screens.register(App.RESULTS_SCREEN,ResultsScreen);
         App.instance.screens.register(App.CLIENT_SCREEN,ClientScreen);
         App.instance.screens.register(App.MOVIE_SCREEN,MovieScreen);
         App.instance.screens.register(App.OUTRO_SCREEN,OutroScreen);
         App.instance.screens.register(App.END_CREDITS_SCREEN,EndCreditsScreen);
         App.instance.screens.register(App.END_SCREEN,EndScreen);
         App.instance.popups.register(App.PLAYER_SCREEN,PlayerScreen);
         App.instance.popups.register(App.HELP_SCREEN,HelpScreen);
         App.instance.popups.register(App.CREDITS_SCREEN,CreditsScreen);
      }
   }
}

