package ss.game.factory
{
   import flash.geom.Point;
   import org.fatlib.interfaces.IDestroyable;
   import ss.Values;
   import ss.app.App;
   import ss.game.Game;
   import ss.game.Messages;
   import ss.game.components.*;
   import ss.game.components.units.*;
   import ss.game.core.Engine;
   import ss.game.core.Entity;
   import ss.game.data.Effect;
   import ss.game.entities.*;
   import ss.utils.Utils;
   
   public class EntityFactory implements IDestroyable
   {
      
      public static const CATEGORY:String = "category";
      
      public static const WORKER:String = "worker";
      
      public static const OFFICER:String = "officer";
      
      public static const FEATURE:String = "feature";
      
      public static const ITEM:String = "item";
      
      public static const EFFECT:String = "effect";
      
      public static const LEVEL:String = "level";
      
      public static const TYPE:String = "type";
      
      public static const RANGE:String = "range";
      
      public static const CAN_LEVEL_UP:String = "can_level_up";
      
      public static const CAN_EXPLODE:String = "can_explode";
      
      public static const NEXT_LEVEL_NAME:String = "next_level_name";
      
      public static const STAMINA:String = "stamina";
      
      public static const SKILL_HAT:String = "skill_hat";
      
      public static const SKILL_SHOE:String = "skill_shoe";
      
      public static const SKILL_SHIRT:String = "skill_shirt";
      
      public static const SKILL_BAG:String = "skill_bag";
      
      public static const SKILL_PACK:String = "skill_pack";
      
      public static const EFFECT_TYPE:String = "effect_type";
      
      public static const EFFECT_AMOUNT:String = "effect_amount";
      
      public static const COMPLEXITY:String = "complexity";
      
      public static const WORK_TYPE:String = "work_type";
      
      public static const EFFECTS:String = "effects";
      
      public static const AMBIENT:String = "ambient";
      
      public static const PLUS1:String = "plus1";
      
      public static const PLUS2:String = "plus2";
      
      public static const PLUS3:String = "plus3";
      
      public static const MINUS1:String = "minus1";
      
      public static const MINUS2:String = "minus2";
      
      public static const MINUS3:String = "minus3";
      
      public static const BAG:String = "bag";
      
      public static const SHOES:String = "shoes";
      
      public static const HAT:String = "hat";
      
      public static const SHIRT:String = "shirt";
      
      public static const PACKER:String = "packer";
      
      private var _ids:Object;
      
      public function EntityFactory()
      {
         super();
      }
      
      public function create(param1:String, param2:int, param3:int, param4:Object = null, param5:Boolean = true, param6:Boolean = true) : Boolean
      {
         var _loc7_:MapEntity = null;
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         if(!Utils.isActiveTile(new Point(param2,param3),Game.level.world))
         {
            return false;
         }
         if(!param4)
         {
            param4 = {};
         }
         var _loc8_:Object = this.getRows(WORKER);
         if(_loc8_[param1])
         {
            _loc7_ = this.addWorker(_loc8_[param1].type,param2,param3,param4);
         }
         if(!_loc7_)
         {
            _loc9_ = this.getRows(FEATURE);
            if(_loc9_[param1])
            {
               switch(param1)
               {
                  case "box":
                     _loc7_ = this.addBox(param1,param2,param3,param4);
                     break;
                  case "hazard":
                     _loc7_ = this.addHazard(param1,param2,param3);
                     break;
                  default:
                     _loc7_ = this.addFeature(_loc9_[param1].type,param2,param3,param4);
               }
            }
         }
         if(!_loc7_)
         {
            _loc10_ = this.getRows(OFFICER);
            if(_loc10_[param1])
            {
               _loc7_ = this.addOfficer(_loc10_[param1].type,param2,param3,param4);
            }
         }
         if(!_loc7_)
         {
            throw new Error("Don\'t know how to create something with key " + param1);
         }
         Game.canvas.forceDepthSort();
         if(Values.DEBUG_MODE)
         {
            _loc7_.addComponent(new DebugBubbleRenderer());
         }
         if(param6)
         {
            Game.messenger.broadcast(Messages.DEPLOYABLE_ADDED,{
               "tile":_loc7_.position,
               "id":_loc7_.id,
               "type":_loc7_.type,
               "recordStat":param5
            });
         }
         if(Game.engine.paused)
         {
            _loc7_.broadcastLocalMessage(Engine.ENGINE_PAUSED);
         }
         return true;
      }
      
      public function createItem(param1:String, param2:int, param3:int) : Item
      {
         var _loc4_:Item = this.addItem(param1 + "_" + Game.level.world,param2,param3);
         Game.canvas.forceDepthSort();
         return _loc4_;
      }
      
      public function removeDeployable(param1:String) : void
      {
         var _loc2_:Entity = Game.engine.find(param1);
         Game.engine.removeEntity(param1);
         Game.messenger.broadcast(Messages.DEPLOYABLE_REMOVED,{
            "tile":_loc2_.position,
            "id":_loc2_.id
         });
      }
      
      public function levelUp(param1:Unit) : void
      {
         if(!param1.canLevelUp)
         {
            throw new Error("Can\'t level up a " + param1.key);
         }
         ++param1.level;
         if(param1 is Worker)
         {
            this.configureWorker(param1 as Worker);
         }
         else
         {
            this.configureOfficer(param1 as Officer);
         }
         Game.messenger.broadcast(Messages.UNIT_UPGRADED,{"id":param1.id});
      }
      
      public function getRow(param1:String, param2:String) : Object
      {
         if(App.instance.data[param1][param2])
         {
            return App.instance.data[param1][param2];
         }
         return {};
      }
      
      private function getRows(param1:String) : Object
      {
         return App.instance.data[param1];
      }
      
      public function getValue(param1:String, param2:String, param3:String = "value") : *
      {
         return App.instance.data[param2][param1][param3];
      }
      
      public function destroy() : void
      {
         this._ids = null;
      }
      
      protected function addWorker(param1:String, param2:int, param3:int, param4:Object = null) : Worker
      {
         if(!param4)
         {
            param4 = {};
         }
         var _loc5_:int = 1;
         if(param4.level)
         {
            _loc5_ = int(param4.level);
         }
         var _loc6_:Worker = Game.engine.construct(Worker) as Worker;
         _loc6_.category = WORKER;
         _loc6_.type = param1;
         _loc6_.level = _loc5_;
         _loc6_.position = new Point(param2,param3);
         this.configureWorker(_loc6_);
         _loc6_.addComponent(new WorkerEnergyController());
         _loc6_.addComponent(new WorkerExhaustionRenderer());
         _loc6_.addComponent(new WorkerController());
         _loc6_.addComponent(new WorkerRenderer(),"renderer");
         _loc6_.addComponent(new UnitLevelRenderer());
         _loc6_.addComponent(new WorkerStateController());
         _loc6_.addComponent(new WorkerEffectOverlayRenderer());
         _loc6_.addComponent(new WorkerStateOverlayRenderer());
         _loc6_.addComponent(new WorkerAccidentController());
         _loc6_.environmentRef = "environment";
         _loc6_.mapRef = "map";
         _loc6_.beltRef = "belt";
         _loc6_.beltInfoRef = "belt.info";
         if(param4.gender)
         {
            _loc6_.gender = param4.gender;
         }
         else
         {
            _loc6_.gender = "m";
         }
         _loc6_.init(this.generateID(_loc6_.type));
         return _loc6_;
      }
      
      private function addOfficer(param1:String, param2:int, param3:int, param4:Object = null) : Officer
      {
         if(!param4)
         {
            param4 = {};
         }
         var _loc5_:int = 1;
         if(param4.level)
         {
            _loc5_ = int(param4.level);
         }
         var _loc6_:Officer = Game.engine.construct(Officer) as Officer;
         _loc6_.category = OFFICER;
         _loc6_.position = new Point(param2,param3);
         _loc6_.type = param1;
         _loc6_.level = _loc5_;
         this.configureOfficer(_loc6_);
         _loc6_.environmentRef = "environment";
         _loc6_.mapRef = "map";
         _loc6_.addComponent(new UnitLevelRenderer());
         _loc6_.addComponent(new OfficerRenderer());
         _loc6_.init(this.generateID(_loc6_.type));
         return _loc6_;
      }
      
      private function addItem(param1:String, param2:int, param3:int, param4:Object = null) : Item
      {
         var _loc5_:Item = Game.engine.construct(Item) as Item;
         var _loc6_:Object = this.getRow(ITEM,param1);
         _loc5_.category = ITEM;
         _loc5_.key = param1;
         _loc5_.type = _loc6_[TYPE];
         _loc5_.workComplexity = _loc6_[COMPLEXITY];
         _loc5_.workType = _loc6_[WORK_TYPE];
         _loc5_.position = new Point(param2,param3);
         _loc5_.addComponent(new ItemController());
         _loc5_.addComponent(new ItemRenderer(),"renderer");
         if(Values.SHOW_ITEM_PROGRESS_BAR)
         {
            _loc5_.addComponent(new ItemProgressBarRenderer());
         }
         _loc5_.addComponent(new FireRenderer());
         _loc5_.beltRef = "belt";
         _loc5_.environmentRef = "environment";
         _loc5_.init(this.generateID(_loc5_.type));
         return _loc5_;
      }
      
      private function addBox(param1:String, param2:int, param3:int, param4:Object) : MapEntity
      {
         var _loc5_:MapEntity = Game.engine.construct(MapEntity) as MapEntity;
         _loc5_.category = "box";
         _loc5_.type = param1;
         _loc5_.key = null;
         _loc5_.mapRef = "map";
         _loc5_.environmentRef = "environment";
         _loc5_.position = new Point(param2,param3);
         _loc5_.addComponent(new BoxRenderer());
         _loc5_.addComponent(new BoxFireController());
         _loc5_.init(this.generateID(param1));
         return _loc5_;
      }
      
      private function addHazard(param1:String, param2:int, param3:int) : MapEntity
      {
         var _loc4_:FireHazard = Game.engine.construct(FireHazard) as FireHazard;
         _loc4_.position = new Point(param2,param3);
         _loc4_.type = param1;
         var _loc5_:Object = this.getRow(FEATURE,param1);
         _loc4_.effect = this.parseEffect(_loc5_["action"]);
         _loc4_.effect.range = parseInt(_loc5_["range"]);
         _loc4_.effect.stackEffects = true;
         _loc4_.effect.position = _loc4_.position;
         _loc4_.activateChance = Values.FIRE_HAZARD_ACTIVATE_CHANCE;
         _loc4_.addComponent(new FireHazardRenderer());
         _loc4_.addComponent(new FireHazardController());
         _loc4_.init(this.generateID(param1));
         return _loc4_ as MapEntity;
      }
      
      private function addFeature(param1:String, param2:int, param3:int, param4:Object = null) : Feature
      {
         var _loc9_:Effect = null;
         var _loc10_:String = null;
         var _loc5_:Feature = Game.engine.construct(Feature) as Feature;
         var _loc6_:Object = App.instance.data[FEATURE][param1];
         _loc5_.category = _loc6_["category"];
         _loc5_.type = param1;
         _loc5_.key = param1;
         _loc5_.position = new Point(param2,param3);
         _loc5_.duration = parseInt(_loc6_["duration"]);
         _loc5_.overlayColor = parseInt("0x" + _loc6_["color"]);
         var _loc7_:Array = _loc6_["action"].split(" ");
         var _loc8_:int = parseInt(_loc6_["range"]);
         _loc5_.range = _loc8_;
         _loc5_.mapRef = "map";
         _loc5_.isAmbient = _loc6_["mode"] == "ambient";
         for each(_loc10_ in _loc7_)
         {
            _loc9_ = this.parseEffect(_loc10_);
            if(_loc9_)
            {
               _loc9_.range = _loc8_;
               _loc9_.position = _loc5_.position.clone();
               _loc5_.addEffect(_loc9_);
            }
         }
         _loc5_.addComponent(new FeatureController());
         _loc5_.addComponent(new FeatureRenderer());
         _loc5_.init(this.generateID(_loc5_.type));
         return _loc5_;
      }
      
      private function configureWorker(param1:Worker) : void
      {
         if(!param1.level || !param1.type)
         {
            throw new Error("type and position must be set first!");
         }
         param1.key = param1.type + "_" + param1.level;
         var _loc2_:Object = this.getRow(WORKER,param1.key);
         param1.level = _loc2_[LEVEL];
         param1.canLevelUp = _loc2_[CAN_LEVEL_UP];
         param1.stamina = _loc2_[STAMINA];
         param1.skillHat = _loc2_[SKILL_HAT];
         param1.skillPack = _loc2_[SKILL_PACK];
         param1.skillShoes = _loc2_[SKILL_SHOE];
         param1.skillShirt = _loc2_[SKILL_SHIRT];
         param1.skillBag = _loc2_[SKILL_BAG];
         param1.canExplode = _loc2_[CAN_EXPLODE];
         param1.reset();
      }
      
      private function configureOfficer(param1:Officer) : void
      {
         var _loc4_:String = null;
         var _loc5_:Effect = null;
         if(!param1.type || !param1.position || !param1.level)
         {
            throw new Error("level, type and position must be set first!");
         }
         param1.key = param1.type + "_" + param1.level;
         var _loc2_:Object = this.getRow(OFFICER,param1.key);
         param1.category = _loc2_[CATEGORY];
         param1.level = _loc2_[LEVEL];
         param1.canLevelUp = _loc2_[CAN_LEVEL_UP];
         param1.removeAllEffects();
         var _loc3_:Object = _loc2_[EFFECTS];
         for(_loc4_ in _loc3_)
         {
            _loc5_ = new Effect();
            _loc5_.range = _loc2_[RANGE];
            _loc5_.position = param1.position.clone();
            _loc5_.type = _loc4_;
            _loc5_.amount = _loc3_[_loc4_];
            _loc5_.stackEffects = true;
            param1.addEffect(_loc5_);
         }
         param1.reset();
      }
      
      private function parseEffect(param1:String) : Effect
      {
         if(param1 == "")
         {
            return null;
         }
         var _loc2_:Effect = new Effect();
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(param1.charAt(param1.length - 1) == "+")
         {
            _loc3_++;
            param1 = param1.substr(0,param1.length - 1);
         }
         while(param1.charAt(param1.length - 1) == "-")
         {
            _loc4_++;
            param1 = param1.substr(0,param1.length - 1);
         }
         switch(param1)
         {
            case "energy":
               _loc2_.type = Environment.RECHARGE_MODIFIER;
               break;
            case "skill":
               _loc2_.type = Environment.SKILL_MODIFIER;
               break;
            case "stamina":
               _loc2_.type = Environment.STAMINA_MODIFIER;
               break;
            case "fire":
               _loc2_.type = Environment.FIRE_RISK;
               break;
            case "accident":
               _loc2_.type = Environment.ACCIDENT_RISK;
               break;
            case "cash":
               _loc2_.type = Environment.CASH_BONUS;
               break;
            default:
               _loc2_.type = param1;
         }
         var _loc5_:Object = App.instance.data[EFFECT][param1];
         if(_loc5_)
         {
            switch(_loc3_ - _loc4_)
            {
               case -3:
                  _loc2_.amount = _loc5_[MINUS3];
                  _loc2_.stackEffects = true;
                  break;
               case -2:
                  _loc2_.amount = _loc5_[MINUS2];
                  _loc2_.stackEffects = true;
                  break;
               case -1:
                  _loc2_.amount = _loc5_[MINUS1];
                  _loc2_.stackEffects = true;
                  break;
               case 1:
                  _loc2_.amount = _loc5_[PLUS1];
                  _loc2_.stackEffects = false;
                  break;
               case 2:
                  _loc2_.amount = _loc5_[PLUS2];
                  _loc2_.stackEffects = false;
                  break;
               case 3:
                  _loc2_.amount = _loc5_[PLUS3];
                  _loc2_.stackEffects = false;
                  break;
               default:
                  throw new Error("Unknown effect amount");
            }
         }
         return _loc2_;
      }
      
      private function generateID(param1:String) : String
      {
         if(!this._ids)
         {
            this._ids = {};
         }
         if(!this._ids[param1])
         {
            this._ids[param1] = 0;
         }
         var _loc2_:String = param1 + this._ids[param1].toString();
         ++this._ids[param1];
         return _loc2_;
      }
   }
}

