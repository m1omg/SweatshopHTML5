package ss.game.components
{
   import org.fatlib.utils.ArrayUtils;
   import ss.app.App;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.core.Component;
   import ss.game.entities.MapEntity;
   import ss.game.entities.Worker;
   
   public class StatsComponent extends Component
   {
      
      private var _typesHired:Array;
      
      public function StatsComponent()
      {
         super();
      }
      
      override public function prepare() : void
      {
         this._typesHired = [];
         Game.messenger.register(this,Messages.DEPLOYABLE_ADDED,Messages.UNIT_UPGRADED,Messages.WORKER_STATE_CHANGED,Messages.FEATURE_ACTIVATED,Messages.TIRED_WORKER_REFRESHED);
      }
      
      override public function receiveMessage(param1:String, param2:Object) : void
      {
         switch(param1)
         {
            case Messages.DEPLOYABLE_ADDED:
               if(param2["recordStat"])
               {
                  this.handleDeployableAdded(param2.type);
               }
               break;
            case Messages.WORKER_STATE_CHANGED:
               this.handleWorkerStateChanged(param2.state,param2.type);
               break;
            case Messages.TIRED_WORKER_REFRESHED:
               this.handleRefreshed();
               break;
            case Messages.UNIT_UPGRADED:
               this.handleUpgraded();
         }
      }
      
      private function handleUpgraded() : void
      {
         ++App.instance.session.stats.unitsUpgraded;
         ++Game.stats.unitsUpgraded;
         this.changed();
      }
      
      private function handleRefreshed() : void
      {
         ++App.instance.session.stats.tiredWorkersRefreshed;
         ++Game.stats.tiredWorkersRefreshed;
         this.changed();
      }
      
      private function handleWorkerStateChanged(param1:String, param2:String) : void
      {
         switch(param1)
         {
            case Worker.INJURED_STATE:
               this.handleInjured(param2);
               break;
            case MapEntity.SOOT_STATE:
            case Worker.DEAD_EXHAUSTION_STATE:
               this.handleKilled(param2);
         }
      }
      
      private function handleInjured(param1:String) : void
      {
         if(this.isChild(param1))
         {
            ++App.instance.session.stats.childrenHated;
         }
         ++Game.stats.workersInjured;
         ++App.instance.session.stats.workersInjured;
         this.changed();
      }
      
      private function handleKilled(param1:String) : void
      {
         if(this.isChild(param1))
         {
            ++App.instance.session.stats.childrenHated;
         }
         ++Game.stats.workersKilled;
         ++App.instance.session.stats.workersKilled;
         this.changed();
      }
      
      private function handleDeployableAdded(param1:String) : void
      {
         if(this.isWorker(param1))
         {
            ++Game.stats.unitsHired;
            ++App.instance.session.stats.unitsHired;
            if(!ArrayUtils.contains(this._typesHired,param1))
            {
               this._typesHired.push(param1);
            }
            if(this._typesHired.length > Game.stats.typesHired)
            {
               Game.stats.typesHired = this._typesHired.length;
            }
         }
         if(this.isFeature(param1))
         {
            ++Game.stats.featuresDeployed;
            ++App.instance.session.stats.featuresDeployed;
         }
         Game.stats.addDeployed(param1);
         this.changed();
      }
      
      private function changed() : void
      {
         Game.messenger.broadcast(Messages.STATS_UPDATED);
      }
      
      private function isWorker(param1:String) : Boolean
      {
         var _loc2_:Array = ["child","hat_maker","shirt_maker","bag_maker","shoe_maker"];
         return ArrayUtils.contains(_loc2_,param1);
      }
      
      private function isFeature(param1:String) : Boolean
      {
         var _loc2_:Array = ["water","cola","juice","fan","toilet","heater","radio","sign","tannoy"];
         return ArrayUtils.contains(_loc2_,param1);
      }
      
      private function isChild(param1:String) : Boolean
      {
         return param1 == "child";
      }
      
      private function isToilet(param1:String) : Boolean
      {
         return param1 == "toilet";
      }
   }
}

