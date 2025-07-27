package idk.utils;

import flixel.util.FlxColor;

class ColorUtil {
    public static inline var TRANSPARENT:Int = cast FlxColor.TRANSPARENT;
    public static inline var WHITE:Int = cast FlxColor.WHITE;
    public static inline var GRAY:Int = cast FlxColor.GRAY;
    public static inline var BLACK:Int = cast FlxColor.BLACK;
    public static inline var GREEN:Int = cast FlxColor.GREEN;
    public static inline var LIME:Int = cast FlxColor.LIME;
    public static inline var YELLOW:Int = cast FlxColor.YELLOW;
    public static inline var ORANGE:Int = cast FlxColor.ORANGE;
    public static inline var RED:Int = cast FlxColor.RED;
    public static inline var PURPLE:Int = cast FlxColor.PURPLE;
    public static inline var BLUE:Int = cast FlxColor.BLUE;
    public static inline var BROWN:Int = cast FlxColor.BROWN;
    public static inline var PINK:Int = cast FlxColor.PINK;
    public static inline var MAGENTA:Int = cast FlxColor.MAGENTA;
    public static inline var CYAN:Int = cast FlxColor.CYAN;

    public static inline function fromInt(value:Int):Int {
        return cast FlxColor.fromInt(value);
    }

    public static inline function fromRGB(red:Int, green:Int, blue:Int, alpha:Int = 255):Int {
        return cast FlxColor.fromRGB(red, green, blue, alpha);
    }

    public static inline function fromRGBFloat(red:Float, green:Float, blue:Float, alpha:Float = 1):Int {
        return cast FlxColor.fromRGBFloat(red, green, blue, alpha);
    }

    public static inline function fromCMYK(cyan:Float, magenta:Float, yellow:Float, black:Float, alpha:Float = 1):Int {
        return cast FlxColor.fromCMYK(cyan, magenta, yellow, black, alpha);
    }

    public static inline function fromHSB(hue:Float, saturation:Float, brightness:Float, alpha:Float = 1):Int {
        return cast FlxColor.fromHSB(hue, saturation, brightness, alpha);
    }

    public static inline function fromHSL(hue:Float, saturation:Float, lightness:Float, alpha:Float = 1):Int {
        return cast FlxColor.fromHSL(hue, saturation, lightness, alpha);
    }

    public static function fromString(str:String):Int {
        var color:Null<FlxColor> = FlxColor.fromString(str);
        return color != null ? cast color : BLACK;
    }

    public static function getHSBColorWheel(alpha:Int = 255):Array<Int> {
        return [for (color in FlxColor.getHSBColorWheel(alpha)) cast color];
    }

    public static inline function interpolate(color1:Int, color2:Int, factor:Float = 0.5):Int {
        return cast FlxColor.interpolate(cast color1, cast color2, factor);
    }

    public static function gradient(color1:Int, color2:Int, steps:Int, ?ease:Float->Float):Array<Int> {
        return [for (color in FlxColor.gradient(cast color1, cast color2, steps, ease)) cast color];
    }
}