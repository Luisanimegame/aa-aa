package;

import flixel.FlxSprite;
import openfl.utils.Assets;
import haxe.Json;

typedef MenuChars = {
    var image:String;
    var scale:Float;
    var position:Array<Float>;
    var flipX:Bool;
    var idle:String;
    var confirm:String;
}

class MenuCharacter extends FlxSprite
{
    public var character:String;

    public function new(x:Float, character:String = 'bf')
    {
        super(x);
        changeCharacter(character);
    }

    public function changeCharacter(character:String)
    {
        this.character = character;
        
        antialiasing = true;
        scale.set(1, 1);
        updateHitbox();
        switch(character) {
            case '':
                visible = false;
            default:
                if (!visible)
                    visible = true;
                var charPath:String = 'assets/images/menuChars/$character.json';
                if (!Util.exists(charPath))
                    charPath = 'assets/images/menuChars/bf.json';
                var rawJson = Util.getContent(charPath);
                var char:MenuChars = Json.parse(rawJson);
                frames = Paths.getSparrowAtlas('menuChars/${char.image}');
                animation.addByPrefix('idle', char.idle, 24);
                animation.addByPrefix('confirm', char.confirm, 24, false);
                flipX = char.flipX;
                if (char.scale != 1) {
                    scale.set(char.scale, char.scale);
                    updateHitbox();
                }
                offset.set(char.position[0], char.position[1]);
                animation.play('idle');
        }
    }
}