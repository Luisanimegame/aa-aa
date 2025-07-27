package utils;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import openfl.display.BlendMode;

using StringTools;
class CoreUtils {
    public static function insertCamera(index:Int, camera:FlxCamera, defaultDraw:Bool = false):Void {
        var currentCameras = FlxG.cameras.list.copy();
        for (cam in currentCameras)
            FlxG.cameras.remove(cam, false);

        currentCameras.insert(index, camera);
        for (cam in currentCameras) {
            @:privateAccess
            FlxG.cameras.add(cam, FlxG.cameras.defaults.contains(cam) || (cam == camera && defaultDraw));
        }
    }
    public static function FlxEaseFromString(?ease:String = '') {
        switch(ease.toLowerCase().trim()) {
            case 'backin': return FlxEase.backIn;
            case 'backinout': return FlxEase.backInOut;
            case 'backout': return FlxEase.backOut;
            case 'bouncein': return FlxEase.bounceIn;
            case 'bounceinout': return FlxEase.bounceInOut;
            case 'bounceout': return FlxEase.bounceOut;
            case 'circin': return FlxEase.circIn;
            case 'circinout': return FlxEase.circInOut;
            case 'circout': return FlxEase.circOut;
            case 'cubein': return FlxEase.cubeIn;
            case 'cubeinout': return FlxEase.cubeInOut;
            case 'cubeout': return FlxEase.cubeOut;
            case 'elasticin': return FlxEase.elasticIn;
            case 'elasticinout': return FlxEase.elasticInOut;
            case 'elasticout': return FlxEase.elasticOut;
            case 'expoin': return FlxEase.expoIn;
            case 'expoinout': return FlxEase.expoInOut;
            case 'expoout': return FlxEase.expoOut;
            case 'quadin': return FlxEase.quadIn;
            case 'quadinout': return FlxEase.quadInOut;
            case 'quadout': return FlxEase.quadOut;
            case 'quartin': return FlxEase.quartIn;
            case 'quartinout': return FlxEase.quartInOut;
            case 'quartout': return FlxEase.quartOut;
            case 'quintin': return FlxEase.quintIn;
            case 'quintinout': return FlxEase.quintInOut;
            case 'quintout': return FlxEase.quintOut;
            case 'sinein': return FlxEase.sineIn;
            case 'sineinout': return FlxEase.sineInOut;
            case 'sineout': return FlxEase.sineOut;
            case 'smoothstepin': return FlxEase.smoothStepIn;
            case 'smoothstepinout': return FlxEase.smoothStepInOut;
            case 'smoothstepout': return FlxEase.smoothStepInOut;
            case 'smootherstepin': return FlxEase.smootherStepIn;
            case 'smootherstepinout': return FlxEase.smootherStepInOut;
            case 'smootherstepout': return FlxEase.smootherStepOut;
        }
        return FlxEase.linear;
    }
    @:access(openfl.display.BlendMode)
    public static function blendModeFromString(blend:String):BlendMode
        return BlendMode.fromString(blend.toLowerCase().trim());
    public static function cameraFromString(camera:String):FlxCamera {
        switch (camera.toLowerCase()) {
            case 'camgame' | 'game': return PlayState.instance.camGame;
            case 'camgame2' | 'game2': return PlayState.instance.camGame2;
            case 'camhud' | 'hud': return PlayState.instance.camHUD;
            case 'camother' | 'other' | 'camhud2' | 'hud2': return PlayState.instance.camHUD2;
        }
        return PlayState.instance.camGame;
    }
}