package ss.app.process
{
   import flash.events.Event;
   import org.fatlib.Log;
   import org.fatlib.events.LoadProgressEvent;
   import org.fatlib.process.AsyncProcess;
   import ss.app.App;
   import ss.resources.ResourceIndex;
   
   public class RegisterResourcesProcess extends AsyncProcess
   {
      
      public function RegisterResourcesProcess()
      {
         super();
      }
      
      override public function execute() : void
      {
         Log.log("[RegisterResourcesProcess] execute");
         App.instance.resources.addEventListener(LoadProgressEvent.LOADED,this.onComplete);
         App.instance.resources.addResource("hat_maker_m",ResourceIndex.HatMakerM);
         App.instance.resources.addResource("hat_maker_f",ResourceIndex.HatMakerF);
         App.instance.resources.addResource("bag_maker_m",ResourceIndex.BagMakerM);
         App.instance.resources.addResource("bag_maker_f",ResourceIndex.BagMakerF);
         App.instance.resources.addResource("shirt_maker_m",ResourceIndex.ShirtMakerM);
         App.instance.resources.addResource("shirt_maker_f",ResourceIndex.ShirtMakerF);
         App.instance.resources.addResource("shoe_maker_m",ResourceIndex.ShoeMakerM);
         App.instance.resources.addResource("shoe_maker_f",ResourceIndex.ShoeMakerF);
         App.instance.resources.addResource("child_m",ResourceIndex.ChildM);
         App.instance.resources.addResource("child_f",ResourceIndex.ChildF);
         App.instance.resources.addResource("packer",ResourceIndex.Packer);
         App.instance.resources.addResource("fire_officer",ResourceIndex.FireOfficer);
         App.instance.resources.addResource("engineer",ResourceIndex.Engineer);
         App.instance.resources.addResource("superstar",ResourceIndex.Superstar);
         App.instance.resources.addResource("features",ResourceIndex.Features);
         App.instance.resources.addResource("belt",ResourceIndex.Belt);
         App.instance.resources.addResource("world1",ResourceIndex.World1);
         App.instance.resources.addResource("world2",ResourceIndex.World2);
         App.instance.resources.addResource("world3",ResourceIndex.World3);
         App.instance.resources.addResource("item",ResourceIndex.Items);
         App.instance.resources.addResource("console",ResourceIndex.Console);
         App.instance.resources.addResource("ui",ResourceIndex.UI);
         App.instance.resources.addResource("hud",ResourceIndex.HUD);
         App.instance.resources.addResource("music",ResourceIndex.Music);
         App.instance.resources.addResource("sfx",ResourceIndex.SFX);
         App.instance.resources.addResource("clients",ResourceIndex.Clients);
         App.instance.resources.addResource("credits",ResourceIndex.Credits);
         App.instance.resources.addResource("outro",ResourceIndex.Outro);
         App.instance.resources.addResource("help",ResourceIndex.Help);
         App.instance.resources.addResource("movie",ResourceIndex.Movie);
         App.instance.resources.startLoading();
      }
      
      private function onComplete(param1:Event) : void
      {
         App.instance.resources.removeEventListener(LoadProgressEvent.LOADED,this.onComplete);
         done();
      }
   }
}

