package utils;

import openfl.utils.Assets;
import sys.io.File;
import sys.FileSystem;
import haxe.crypto.Md5;
import lime.system.System;
import openfl.display.BitmapData;

using StringTools;

/**
 * ...
 * @author Idklool (idklel01)
 */

class Util
{
    public static function getContent(id:String):String
    {
        return Assets.getText(id);
    }

    public static function exists(id:String):Bool
    {
        return Assets.exists(id);
    }

    public static function getBytes(id:String)
    {
        return Assets.getBytes(id);
    }

    public static function readDirectory(library:String):Array<String>
    {
        return Assets.list().filter(text -> text.indexOf(library) != -1);
    }

    public static function fromFile(id:String)
    {
        return Assets.getBitmapData(id);
    }

    public static function getPath(id:String) {
        #if android
            var path:String = System.applicationStorageDirectory;
            var file = Assets.getBytes(id);
            var md5 = Md5.encode(Md5.make(file).toString());
            var filePath = path + md5;

            if (!FileSystem.exists(filePath))
                File.saveBytes(filePath, file);
            return filePath;
        #else
            return id;
        #end
    }
}