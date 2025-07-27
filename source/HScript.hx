package;

import openfl.utils.Assets;
import flixel.FlxBasic;
import flixel.FlxG;
import idk.Script;

using StringTools;

class HScript extends Script {
    public function new(file:String) {
        super(file);
        preset();
        setClassVars(PlayState);
        setClassVars(PlayState.instance);
        call('create', []);
    }

    override function preset() {
        super.preset();
        set('FlxG', flixel.FlxG);
        set('FlxSprite', flixel.FlxSprite);
        set('FlxCamera', flixel.FlxCamera);
        set('FlxFlicker', flixel.effects.FlxFlicker);
        set('FlxMath', flixel.math.FlxMath);
        set('FlxSound', flixel.system.FlxSound);
        set('FlxTween', flixel.tweens.FlxTween);
        set('FlxEase', flixel.tweens.FlxEase);
        set('FlxTimer', flixel.util.FlxTimer);
        set('FlxBackdrop', flixel.addons.display.FlxBackdrop);
        set('FlxText', flixel.text.FlxText);
        set('FlxTrail', flixel.addons.effects.FlxTrail);
        set('FlxSpriteGroup', flixel.group.FlxSpriteGroup);
        set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
        set('FlxShader', flixel.system.FlxAssets.FlxShader);
        set('ShaderFilter', openfl.filters.ShaderFilter);
        set('Json', haxe.Json);
        set('BGSprite', BGSprite);
        set('Character', Character);
        set('Conductor', Conductor);
        set('CoolUtil', CoolUtil);
        set('Note', Note);
        set('Paths', Paths);
        set('PlayState', PlayState);
        set('Util', utils.Util);
        set('CoreUtils', utils.CoreUtils);
        set('VideoSpriteUtils', utils.VideoSpriteUtils);

        set('curStep', 0);
        set('curBeat', 0);
        set('FlxAxes', {
            X: flixel.util.FlxAxes.X,
            Y: flixel.util.FlxAxes.Y,
            XY: flixel.util.FlxAxes.XY
        });
        set('add', (object:FlxBasic) -> FlxG.state.add(object));
        set('insert', (position:Int, object:FlxBasic) -> FlxG.state.insert(position, object));
        set('remove', (object:FlxBasic, waa:Bool = false) -> FlxG.state.remove(object, waa));
        set('indexOf', (obj:FlxBasic) -> FlxG.state.members.indexOf(obj));
        set('addBehind', (obj:FlxBasic, ?char:String) -> {
            switch(char) {
                case 'boyfriend', 'bf':
                    PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.bfGroup), obj);
                case 'dad', 'opponent':
                    PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.dadGroup), obj);
                default:
                    PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.gfGroup), obj);
            }
        });
        set('parseJson', (obj:Dynamic) -> return haxe.Json.parse(obj));
    }
}