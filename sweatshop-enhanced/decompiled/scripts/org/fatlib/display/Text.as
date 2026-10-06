package org.fatlib.display
{
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import org.fatlib.events.TextInputEvent;
   import org.fatlib.utils.Delay;
   import org.fatlib.utils.DisplayUtils;
   
   public class Text extends Graphic
   {
      
      private var _textField:TextField = new TextField();
      
      private var _textFormat:TextFormat;
      
      private var _isInput:Boolean;
      
      private var _isHTML:Boolean;
      
      private var _inputHilite:Graphic;
      
      private var _hiliteColor:int;
      
      private var _hiliteAlpha:Number;
      
      private var _beingEdited:Boolean = false;
      
      private var _delay:Delay = new Delay();
      
      public function Text(param1:String, param2:String = null, param3:int = 0, param4:Boolean = false, param5:int = 0, param6:Number = 0, param7:Number = 0)
      {
         if(param3 == 0)
         {
            param3 = 16;
         }
         if(param2)
         {
            this._textField.embedFonts = true;
         }
         this._textFormat = new TextFormat(param2,param3);
         this._textField.textColor = param5;
         this._isHTML = param4;
         this._textField.multiline = true;
         if(param6 == 0)
         {
            this._textField.autoSize = TextFieldAutoSize.LEFT;
            this._textField.wordWrap = false;
         }
         else
         {
            this._textField.width = param6;
            if(param7 == 0)
            {
               param7 = 100;
            }
            this._textField.height = param7;
            this._textField.wordWrap = true;
         }
         if(this._isHTML)
         {
            this._textField.htmlText = param1;
         }
         else
         {
            this._textField.text = param1;
         }
         this.setInputHiliteStyle();
         this._inputHilite = new Graphic(DisplayUtils.createRectangle(0,0,1,20,this._hiliteColor));
         this._inputHilite.alpha = this._hiliteAlpha;
         this._inputHilite.visible = false;
         this._textField.addEventListener(TextEvent.TEXT_INPUT,this.onTextInput);
         this._textField.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this._textField.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this._textField.addEventListener(FocusEvent.FOCUS_IN,this.onFocusIn);
         this._textField.addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
         var _loc8_:Graphic = new Graphic();
         _loc8_.addChild(this._inputHilite);
         _loc8_.addChild(this._textField);
         super(_loc8_);
         this.isInput = false;
      }
      
      public function set characterLimit(param1:int) : void
      {
         this._textField.maxChars = param1;
      }
      
      public function set font(param1:String) : void
      {
         this._textField.embedFonts = true;
         this._textFormat.font = param1;
         this._textField.defaultTextFormat = this._textFormat;
         this._textField.setTextFormat(this._textFormat);
      }
      
      public function set text(param1:String) : void
      {
         if(!param1)
         {
            param1 = "";
         }
         if(this._isHTML)
         {
            this._textField.htmlText = param1;
         }
         else
         {
            this._textField.text = param1;
         }
      }
      
      public function get text() : String
      {
         if(this._isHTML)
         {
            return this._textField.htmlText;
         }
         return this._textField.text;
      }
      
      public function set color(param1:int) : void
      {
         this._textField.textColor = param1;
      }
      
      public function get isInput() : Boolean
      {
         return this._isInput;
      }
      
      public function set isInput(param1:Boolean) : void
      {
         this._isInput = param1;
         if(this._isInput)
         {
            this._textField.selectable = true;
            this._textField.type = TextFieldType.INPUT;
         }
         else
         {
            this._textField.selectable = false;
            this._textField.type = TextFieldType.DYNAMIC;
         }
      }
      
      public function setInputHiliteStyle(param1:int = 16776960, param2:Number = 0.3) : void
      {
         this._hiliteColor = param1;
         this._hiliteAlpha = param2;
      }
      
      override public function destroy() : void
      {
         this._delay.destroy();
      }
      
      override protected function handleMadeInteractive() : void
      {
         super.handleMadeInteractive();
         this._textField.selectable = true;
      }
      
      override protected function handleMadeNonInteractive() : void
      {
         super.handleMadeNonInteractive();
         this._textField.selectable = false;
      }
      
      private function onTextInput(param1:TextEvent) : void
      {
         this._delay.create(100,this.dispatchTextInputEvent);
      }
      
      private function dispatchTextInputEvent() : void
      {
         dispatchEvent(new TextInputEvent(TextInputEvent.TEXT_INPUT,this._textField.text));
      }
      
      private function onFocusIn(param1:Event) : void
      {
         if(!this._isInput)
         {
            return;
         }
         this._inputHilite.visible = true;
         this._beingEdited = true;
      }
      
      private function onFocusOut(param1:Event) : void
      {
         if(!this._isInput)
         {
            return;
         }
         this._inputHilite.visible = false;
         this._beingEdited = false;
      }
      
      private function onRollOver(param1:Event) : void
      {
         if(!this._isInput)
         {
            return;
         }
         this._inputHilite.visible = true;
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         if(!this._isInput)
         {
            return;
         }
         if(!this._beingEdited)
         {
            this._inputHilite.visible = false;
         }
      }
      
      override protected function handleFrame() : void
      {
         this._inputHilite.width = this._textField.textWidth;
      }
   }
}

