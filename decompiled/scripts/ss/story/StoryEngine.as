package ss.story
{
   import org.fatlib.Log;
   import org.fatlib.interfaces.IDestroyable;
   
   public class StoryEngine implements IDestroyable
   {
      
      public var currentChunkType:String;
      
      private var _xml:XML;
      
      private var _lines:Array;
      
      public function StoryEngine(param1:XML)
      {
         super();
         this._xml = param1;
      }
      
      public function trigger(param1:String, param2:Object = null) : Boolean
      {
         var chunk:XML = null;
         var attr:XMLList = null;
         var i:int = 0;
         var lines:XMLList = null;
         var line:XML = null;
         var name:String = null;
         var value:String = null;
         var type:String = param1;
         var match:Object = param2;
         if(!match)
         {
            match = {};
         }
         chunk = this._xml.chunk.(@trigger == type)[0];
         if(!chunk)
         {
            return false;
         }
         attr = chunk.attributes();
         i = 0;
         while(i < attr.length())
         {
            name = attr[i].name();
            value = attr[i].toString();
            if(name != "trigger")
            {
               if(!match[name])
               {
                  Log.log("[StoryEngine] failed to match <" + name + "=\"" + value + "\"> (no property \"" + name + "\" found in match object, or value is null)");
                  return false;
               }
               if(match[name] != value)
               {
                  Log.log("[StoryEngine] failed to match <" + name + "=\"" + value + "\"> ( got \"" + match[name] + "\")");
                  return false;
               }
            }
            i++;
         }
         this._lines = [];
         lines = chunk.children();
         for each(line in lines)
         {
            if(line.nodeKind() != "text")
            {
               this._lines.push(line);
            }
         }
         if(this.hasNextLine)
         {
            this.currentChunkType = type;
         }
         else
         {
            this.currentChunkType = null;
         }
         return this.hasNextLine;
      }
      
      public function get hasNextLine() : Boolean
      {
         return Boolean(this._lines) && this._lines.length > 0;
      }
      
      public function getNextLine() : XML
      {
         return this._lines.shift();
      }
      
      public function destroy() : void
      {
         this._xml = null;
         this._lines = null;
      }
   }
}

