package jsonstuff;

import haxe.Json;
import openfl.utils.Assets;

typedef StageData = {
    var zoom:Float;
    var ?isPixel:Bool;
    var bf:Array<Float>;
    var dad:Array<Float>;
    var gf:Array<Float>;
    var ?camBF:Array<Float>;
    var ?camDad:Array<Float>;
}

class Stage {
    public function new() {
        
    }
    public static function getStage(stage:String = 'stage'):StageData {
        var rawJson:String = '';
        var stagePath = 'assets/stages/' + stage + '.json';

        if (Assets.exists(stagePath))
            rawJson = Assets.getText(stagePath);
        else
            return null;

        return Json.parse(rawJson);
    }
}