package;

import flixel.FlxG;
import flixel.math.FlxMath;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

using StringTools;

class CoolUtil
{
    public static var difficultyArray:Array<String> = ['easy', 'normal', 'hard'];
    public static var defaultDiff:String = 'normal';

    public static function difficultyString(val:Int):String
        return difficultyArray[val];

    public static function coolTextFile(path:String):Array<String>
    {
        var daList:Array<String> = [];
        if (Util.exists(path))
            daList = Util.getContent(path).trim().split('\n');
        for (i in 0...daList.length)
            daList[i] = daList[i].trim();
        return daList;
    }

    public static function numberArray(max:Int, ?min = 0):Array<Int>
    {
        var result:Array<Int> = [];
        for (i in min...max) result.push(i);
        return result;
    }

    /**
     * Lerps camera, but accountsfor framerate shit? 
     * Right now it's simply for use to change the followLerp variable of a camera during update
     * TODO LATER MAYBE:
		 * Actually make and modify the scroll and lerp shit in it's own function
		 * instead of solely relying on changing the lerp on the fly
     */
    public static function camLerpShit(lerp:Float):Float
        return lerp * (FlxG.elapsed / (1 / 60));

    /**
    * just lerp that does camLerpShit for u so u dont have to do it every time
    */
    public static function coolLerp(a:Float, b:Float, ratio:Float):Float
        return FlxMath.lerp(a, b, camLerpShit(ratio));

    public static function clamp(value:Float, min:Float, max:Float):Float
        return Math.max(min, Math.min(max, value));
}