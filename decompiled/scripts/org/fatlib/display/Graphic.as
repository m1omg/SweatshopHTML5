package org.fatlib.display
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import org.fatlib.interfaces.IDestroyable;
   
   public class Graphic extends Sprite implements IDestroyable
   {
      
      public static const DEFAULT:String = "default";
      
      public static const BLANK:String = "blank";
      
      private var _states:Object;
      
      private var _currentState:DisplayObject;
      
      private var _currentStateName:String;
      
      private var _interactable:Boolean;
      
      private var _childrenInteractable:Boolean;
      
      private var _interactive:Boolean;
      
      private var _userData:Object = {};
      
      public function Graphic(param1:DisplayObject = null)
      {
         super();
         this._states = [];
         this.registerState(BLANK,new MovieClip());
         if(param1)
         {
            this.registerState(DEFAULT,param1);
            this.showState(DEFAULT);
         }
         this._interactable = false;
         this._childrenInteractable = true;
         this.interactive = true;
         addEventListener(Event.ENTER_FRAME,this.onFrame,false,0,true);
      }
      
      public function registerState(param1:*, param2:DisplayObject = null) : void
      {
         if(!param2)
         {
            param2 = new Sprite();
         }
         this._states[param1] = param2;
      }
      
      public function showState(param1:*) : void
      {
         if(this.hasState(param1))
         {
            if(this._currentState)
            {
               removeChild(this._currentState);
            }
            this._currentState = this.getState(param1);
            this._currentStateName = param1;
            addChild(this._currentState);
            return;
         }
         throw new IllegalOperationError("No such state as " + param1);
      }
      
      public function get currentState() : DisplayObject
      {
         return this._currentState;
      }
      
      public function get currentStateName() : *
      {
         return this._currentStateName;
      }
      
      public function hasState(param1:*) : Boolean
      {
         return this._states[param1] != undefined;
      }
      
      public function getChild(param1:String) : *
      {
         var _loc2_:* = getChildByName(param1);
         return getChildByName(param1);
      }
      
      public function hasChild(param1:String) : Boolean
      {
         var _loc2_:* = getChildByName(param1);
         return _loc2_ != null;
      }
      
      public function getNumStates(param1:Boolean = false) : int
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         for(_loc3_ in this._states)
         {
            if(_loc3_ != BLANK || param1)
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public function getState(param1:*) : DisplayObject
      {
         return this._states[param1];
      }
      
      protected function handleFrame() : void
      {
      }
      
      public function destroy() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      public function get interactable() : Boolean
      {
         return this._interactable;
      }
      
      public function set interactable(param1:Boolean) : void
      {
         this._interactable = param1;
         this.interactive = this._interactive;
      }
      
      public function get childrenInteractable() : Boolean
      {
         return this._childrenInteractable;
      }
      
      public function set childrenInteractable(param1:Boolean) : void
      {
         this._childrenInteractable = param1;
         this.interactive = this._interactive;
      }
      
      public function set actAsButton(param1:Boolean) : void
      {
         buttonMode = useHandCursor = param1;
         this.interactable = true;
         this.childrenInteractable = false;
      }
      
      public function set interactive(param1:Boolean) : void
      {
         this._interactive = param1;
         if(this._interactive)
         {
            mouseEnabled = tabEnabled = this._interactable;
            mouseChildren = tabChildren = this._childrenInteractable;
            this.handleMadeInteractive();
         }
         else
         {
            mouseChildren = tabChildren = false;
            mouseEnabled = tabEnabled = false;
            this.handleMadeNonInteractive();
         }
      }
      
      public function get interactive() : Boolean
      {
         return this._interactive;
      }
      
      public function get userData() : Object
      {
         return this._userData;
      }
      
      public function set userData(param1:Object) : void
      {
         this._userData = param1;
      }
      
      protected function handleMadeInteractive() : void
      {
      }
      
      protected function handleMadeNonInteractive() : void
      {
      }
      
      private function onFrame(param1:Event) : void
      {
         this.handleFrame();
      }
   }
}

