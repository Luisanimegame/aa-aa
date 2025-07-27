package stages;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.ui.FlxBar;

class Stages
{
    public var curStage(get, default):String = '';
    var playState(get, default):PlayState = PlayState.instance;
    public var boyfriend(get, default):Boyfriend;
    public var dad(get, default):Character;
    public var gf(get, default):Character;
    public var bfGroup(get, default):FlxSpriteGroup;
    public var dadGroup(get, default):FlxSpriteGroup;
    public var gfGroup(get, default):FlxSpriteGroup;
    public var defaultCamZoom(get, default):Float = 1.05;
    public var camHUD(get, default):FlxCamera;
    public var camHUD2(get, default):FlxCamera;
    public var camGame(get, default):FlxCamera;
    public var camGame2(get, default):FlxCamera;
    public var camFollow(get, default):FlxObject;
    public var camCanMove(get, default):Bool = true;

    public var healthBarBG(get, default):FlxSprite;
    public var healthBar(get, default):FlxBar;
    public var health(get, default):Float = 1;
    public var iconP1(get, default):HealthIcon;
    public var iconP2(get, default):HealthIcon;
    public var strumLineNotes(get, default):FlxTypedGroup<StaticArrows>;
    public var cpuStrums(get, default):FlxTypedGroup<StaticArrows>;
    public var playerStrums(get, default):FlxTypedGroup<StaticArrows>;
    public var scoreTxt(get, default):FlxText;
    public var hudGroup(get, default):FlxTypedGroup<FlxSprite>;
    public var notesGroup(get, default):FlxTypedGroup<flixel.FlxBasic>;

    public function new() {}

    public function create() {}
    public function createPost() {}
    public function startCountdown(loops:Int) {}
    public function startSong() {}
    public function endSong() {}
    public function update(elapsed:Float) {}
    public function updatePost(elapsed:Float) {}
    public function stepHit(curStep:Int) {}
    public function beatHit(curBeat:Int) {}
    public function goodNoteHit(daNote:Note) {}
    public function opponentNoteHit(daNote:Note) {}
    public function noteMiss(direction:Int) {}
    public function onEvent(event:jsonstuff.Events.EventVars) {}
    public function pause() {}
    public function resume() {}
    public function add(obj:Dynamic) {
        playState.add(obj);
    }
    public function remove(obj:Dynamic, ?idk:Bool) {
        playState.remove(obj, idk);
    }
    public function insert(idx:Int, obj:Dynamic) {
        playState.insert(idx, obj);
    }
    public function indexOf(obj:Dynamic):Int {
        return playState.members.indexOf(obj);
    }
    public function addBehind(obj:Dynamic, ?char:String = 'gf') {
        switch(char) {
            case 'bf', 'boyfriend':
                insert(indexOf(bfGroup), obj);
            case 'dad', 'opponent':
                insert(indexOf(dadGroup), obj);
            default:
                insert(indexOf(gfGroup), obj);
        }
    }
    public function get_curStage():String
        return PlayState.curStage;
    public function get_playState():PlayState
        return PlayState.instance;
    public function get_boyfriend():Boyfriend
        return PlayState.boyfriend;
    public function get_dad():Character
        return PlayState.dad;
    public function get_gf():Character
        return PlayState.gf;
    public function get_bfGroup():FlxSpriteGroup
        return playState.bfGroup;
    public function get_dadGroup():FlxSpriteGroup
        return playState.dadGroup;
    public function get_gfGroup():FlxSpriteGroup
        return playState.gfGroup;
    public function get_defaultCamZoom():Float
        return playState.defaultCamZoom;
    public function get_camHUD():FlxCamera
        return playState.camHUD;
    public function get_camHUD2():FlxCamera
        return playState.camHUD2;
    public function get_camGame():FlxCamera
        return playState.camGame;
    public function get_camGame2():FlxCamera
        return playState.camGame2;
    public function get_camFollow():FlxObject
        return playState.camFollow;
    public function get_camCanMove():Bool
        return playState.camCanMove;
    public function get_healthBarBG():FlxSprite
        return playState.healthBarBG;
    public function get_healthBar():FlxBar
        return playState.healthBar;
    public function get_health():Float
        return playState.health;
    public function get_iconP1():HealthIcon
        return playState.iconP1;
    public function get_iconP2():HealthIcon
        return playState.iconP2;
    public function get_strumLineNotes():FlxTypedGroup<StaticArrows>
        return PlayState.strumLineNotes;
    public function get_cpuStrums():FlxTypedGroup<StaticArrows>
        return PlayState.cpuStrums;
    public function get_playerStrums():FlxTypedGroup<StaticArrows>
        return PlayState.playerStrums;
    public function get_scoreTxt():FlxText
        return playState.scoreTxt;
    public function get_hudGroup():FlxTypedGroup<FlxSprite>
        return playState.hudGroup;
    public function get_notesGroup():FlxTypedGroup<flixel.FlxBasic>
        return playState.notesGroup;
}