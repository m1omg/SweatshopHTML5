package ss.game.factory
{
   import flash.display.MovieClip;
   import flash.geom.Point;
   import org.fatlib.Log;
   import ss.app.App;
   import ss.app.screens.scenes.StoryClientDialogRenderer;
   import ss.app.screens.scenes.StoryOutroDialogRenderer;
   import ss.data.LevelResult;
   import ss.data.Stats;
   import ss.game.Commands;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.components.*;
   import ss.game.components.ui.*;
   import ss.game.core.Canvas;
   import ss.game.core.Engine;
   import ss.game.core.Entity;
   import ss.game.core.Messenger;
   import ss.game.data.Shop;
   import ss.game.data.User;
   import ss.game.entities.*;
   import ss.story.StoryEngine;
   
   public class GameFactory
   {
      
      public function GameFactory()
      {
         super();
      }
      
      public static function setup() : void
      {
         var _loc3_:Entity = null;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc10_:String = null;
         var _loc11_:Object = null;
         var _loc1_:Object = App.instance.data["levels"][App.instance.session.currentLevelKey];
         if(!_loc1_)
         {
            throw new Error("Can\'t find level " + App.instance.session.currentLevelKey);
         }
         Game.engine = new Engine();
         Game.level = App.instance.levels.getLevel(App.instance.session.currentLevelKey);
         Game.canvas = new Canvas(Game.engine,Game.level.tileWidth,Game.level.tileHeight);
         Game.factory = new EntityFactory();
         Game.messenger = new Messenger();
         Game.user = new User(Game.level.startingCash,App.instance.session.hasReadCurrentLevel());
         Game.shop = new Shop(App.instance.data["shop"]);
         Game.story = new StoryEngine(Game.level.storyXML);
         Game.stats = new Stats();
         Game.result = new LevelResult(App.instance.session.currentLevelKey);
         var _loc2_:MovieClip = App.instance.resources.instantiateMovieClip("world" + Game.level.world,"TileGuideSymbol");
         if(Boolean(_loc2_) && Boolean(_loc2_["guide"]))
         {
            Game.canvas.tileOrigin.x = _loc2_["guide"].x;
            Game.canvas.tileOrigin.y = _loc2_["guide"].y;
         }
         Game.messenger.suppressFromLog(Commands.UNHILITE_BELT,Commands.HILITE_BELT,Messages.MOUSE_DOWN,Messages.MOUSE_UP,Messages.DEPLOYABLE_DESELECTED,Messages.DIALOG_LINE_RENDERED,Commands.HIDE_OVERLAY,Messages.SEQUENCE_BROADCAST,Messages.DEPLOYABLE_MOUSE_OUT,Messages.DEPLOYABLE_MOUSE_OVER);
         _loc3_ = Game.engine.construct();
         _loc3_.addComponent(new BackgroundRenderer());
         _loc3_.addComponent(new LevelLogicController());
         _loc3_.addComponent(new AudioComponent());
         _loc3_.addComponent(new TimerController());
         _loc3_.init("core");
         _loc3_ = Game.engine.construct(Environment);
         _loc3_.addComponent(new EnvironmentUpdater());
         _loc3_.addComponent(new EnvironmentFireController());
         _loc3_.addComponent(new EnvironmentRenderer(),"renderer");
         _loc3_.init("environment");
         _loc3_ = Game.engine.construct();
         _loc3_.addComponent(new HUDRenderer());
         _loc3_.addComponent(new InputHandler());
         _loc3_.addComponent(new PauseController());
         _loc3_.addComponent(new PauseMenuRenderer());
         _loc3_.addComponent(new TooltipLayerRenderer());
         _loc3_.addComponent(new LevelEndOverlayRenderer());
         _loc3_.init("controls");
         _loc3_ = Game.engine.construct(Selection);
         _loc3_.addComponent(new SelectionController());
         _loc3_.addComponent(new SelectionPopupRenderer());
         _loc3_.addComponent(new SelectionMapHiliter());
         (_loc3_ as Selection).dragRef = "draggable";
         _loc3_.init("selection");
         var _loc4_:Map = Game.engine.construct(Map) as Map;
         _loc4_.addComponent(new MapUpdater());
         _loc4_.init("map");
         _loc3_ = Game.engine.construct(DragInstance);
         _loc3_.addComponent(new DragController());
         _loc3_.addComponent(new DragIconRenderer());
         _loc3_.addComponent(new DragMapHiliter());
         (_loc3_ as DragInstance).mapRef = "map";
         _loc3_.init("draggable");
         var _loc5_:Sequence = Game.engine.construct(Sequence) as Sequence;
         if(_loc1_["sequence"])
         {
            _loc5_.load(_loc1_["sequence"]);
         }
         else
         {
            Log.warn("[GameFactory] no sequence found in level data");
         }
         _loc5_.addComponent(new SequencerController());
         _loc5_.beltRef = "belt";
         _loc5_.init("sequence");
         Game.level.numItems = _loc5_.getItemCount();
         var _loc6_:Belt = Game.engine.construct(Belt) as Belt;
         if(Boolean(_loc1_["map"]) && Boolean(_loc1_["map"]["belt"]))
         {
            _loc6_.load(_loc1_["map"]["belt"]);
         }
         else
         {
            Log.warn("[GameFactory] no belt found in level data");
         }
         _loc6_.addComponent(new BeltController());
         _loc6_.addComponent(new BeltRenderer());
         _loc6_.addComponent(new BeltInfoController(),"info");
         _loc6_.init("belt");
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_.width)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc6_.height)
            {
               if(_loc6_.getDirection(new Point(_loc7_,_loc8_)) != Belt.NONE)
               {
                  _loc4_.addBelt(new Point(_loc7_,_loc8_));
               }
               _loc8_++;
            }
            _loc7_++;
         }
         _loc4_.addBeltNode(_loc6_.startNodes[1],_loc6_.getDirection(_loc6_.startNodes[1]),true);
         _loc4_.addBeltNode(_loc6_.endNodes[1],_loc6_.getDirection(_loc6_.endNodes[1]),false);
         if(_loc6_.startNodes[2])
         {
            _loc4_.addBeltNode(_loc6_.startNodes[2],_loc6_.getDirection(_loc6_.startNodes[2]),true);
         }
         if(_loc6_.endNodes[2])
         {
            _loc4_.addBeltNode(_loc6_.endNodes[2],_loc6_.getDirection(_loc6_.endNodes[2]),false);
         }
         _loc3_ = Game.engine.construct(Story) as Story;
         _loc3_.addComponent(new StoryControlComponent());
         _loc3_.addComponent(new StoryGameDialogRenderer());
         (_loc3_ as Story).context = Story.GAME;
         _loc3_.init("story");
         _loc3_ = Game.engine.construct();
         _loc3_.addComponent(new StatsComponent());
         _loc3_.init("stats");
         if(Boolean(_loc1_["map"]) && Boolean(_loc1_["map"]["units"]))
         {
            for each(_loc9_ in _loc1_["map"]["units"])
            {
               _loc11_ = {};
               switch(_loc9_.unit)
               {
                  case "child":
                     _loc10_ = "child_1";
                     _loc11_.gender = "m";
                     break;
                  default:
                     _loc10_ = _loc9_.unit;
               }
               Game.factory.create(_loc10_,_loc9_.x,_loc9_.y,_loc11_,false,false);
            }
         }
         Game.messenger.broadcast(Commands.FORCE_UPDATE_ENVIRONMENT);
         Game.messenger.broadcast(Commands.FORCE_UPDATE_ENTIRE_MAP);
         Game.canvas.forceDepthSort(true);
      }
      
      public static function setupClientScene(param1:String, param2:MovieClip) : void
      {
         var _loc3_:Object = App.instance.data["levels"][param1];
         if(!_loc3_)
         {
            throw new Error("Can\'t find level " + param1);
         }
         Game.engine = new Engine();
         Game.level = App.instance.levels.getLevel(param1);
         Game.canvas = new Canvas(Game.engine);
         Game.messenger = new Messenger();
         var _loc4_:XML = Game.level.storyXML;
         Game.story = new StoryEngine(_loc4_);
         Game.user = new User(0,App.instance.session.hasReadCurrentLevel());
         var _loc5_:Story = Game.engine.construct(Story) as Story;
         _loc5_.addComponent(new StoryControlComponent());
         _loc5_.addComponent(new StoryClientDialogRenderer());
         _loc5_.addComponent(new AudioComponent());
         _loc5_.context = Story.CLIENT_SCENE;
         _loc5_.mc = param2;
         _loc5_.init("story");
      }
      
      public static function setupOutroScene(param1:String, param2:MovieClip) : void
      {
         var _loc3_:Object = App.instance.data["levels"][param1];
         if(!_loc3_)
         {
            throw new Error("Can\'t find level " + param1);
         }
         Game.engine = new Engine();
         Game.level = App.instance.levels.getLevel(param1);
         Game.canvas = new Canvas(Game.engine);
         Game.messenger = new Messenger();
         var _loc4_:XML = Game.level.storyXML;
         Game.story = new StoryEngine(_loc4_);
         Game.user = new User(0,App.instance.session.hasReadCurrentLevel());
         var _loc5_:Story = Game.engine.construct(Story) as Story;
         _loc5_.addComponent(new StoryControlComponent());
         _loc5_.addComponent(new StoryOutroDialogRenderer());
         _loc5_.addComponent(new AudioComponent());
         _loc5_.context = Story.OUTRO_SCENE;
         _loc5_.mc = param2;
         _loc5_.init("story");
      }
      
      public static function tearDown() : void
      {
         Game.engine.destroy();
         Game.engine = null;
         Game.level = null;
         if(Game.canvas)
         {
            Game.canvas.destroy();
         }
         Game.canvas = null;
         if(Game.factory)
         {
            Game.factory.destroy();
         }
         Game.factory = null;
         if(Game.messenger)
         {
            Game.messenger.destroy();
         }
         Game.messenger = null;
         if(Game.user)
         {
            Game.user.destroy();
         }
         Game.user = null;
         if(Game.shop)
         {
            Game.shop.destroy();
         }
         Game.shop = null;
         if(Game.story)
         {
            Game.story.destroy();
         }
         Game.story = null;
         Game.result = null;
         Game.stats = null;
      }
   }
}

