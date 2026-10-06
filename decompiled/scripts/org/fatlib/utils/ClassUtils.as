package org.fatlib.utils
{
   import flash.display.MovieClip;
   import flash.utils.*;
   
   public class ClassUtils
   {
      
      public function ClassUtils()
      {
         super();
      }
      
      public static function getClassName(param1:Object) : String
      {
         return getFullClassName(param1).split("::")[1];
      }
      
      public static function instantiateSymbol(param1:MovieClip, param2:String = "Content") : Object
      {
         var sup:String;
         var inst:Object = null;
         var classReference:Class = null;
         var swf:MovieClip = param1;
         var linkageID:String = param2;
         try
         {
            classReference = swf.loaderInfo.applicationDomain.getDefinition(linkageID) as Class;
         }
         catch(r:Error)
         {
            throw new Error("No symbol with linkage \"" + linkageID + "\" found in library");
         }
         sup = getSuperClassName(classReference);
         switch(sup)
         {
            case "BitmapDataObject":
               inst = new classReference(0,0);
               break;
            default:
               inst = new classReference();
         }
         return inst;
      }
      
      public static function getFullClassName(param1:Object) : String
      {
         return getQualifiedClassName(param1);
      }
      
      private static function getSuperClassName(param1:Object) : String
      {
         var _loc2_:String = describeType(param1).factory.extendsClass.@type;
         return _loc2_.split("::")[1];
      }
   }
}

