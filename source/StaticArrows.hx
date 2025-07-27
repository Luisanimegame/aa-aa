package; // the bluetooth device is ready to pair

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

// Simples porque sou preguicoso e burro :thumbsup:
class StaticArrows extends FlxSprite
{
    public var texture(default, set):String;
    var noteData:Int = 0;
    var player:Int = 0;

    function set_texture(val:String)
    {
        if (texture != val)
        {
            texture = val; loadNote();
        }
        return val;
    }

    public function new(x:Float, y:Float, noteData:Int, player:Int) {
        super(x, y);
        this.noteData = noteData;
        this.player = player;

        texture = PlayState.instance.pixelStage ? 'arrows-pixels' : 'NOTE_assets';
        scrollFactor.set();
    }

    function loadNote() {
        if (PlayState.instance.pixelStage) {
            loadGraphic(Paths.image('weeb/pixelUI/' + texture), true, 17, 17);
            animation.add('purplel', [4]);
            animation.add('blue', [5]);
            animation.add('green', [6]);
            animation.add('red', [7]);

            setGraphicSize(Std.int(width * PlayState.daPixelZoom));
            updateHitbox();
            antialiasing = false;

            switch (noteData)
            {
                case 0:
                    animation.add('static', [0]);
                    animation.add('pressed', [4, 8], 12, false);
                    animation.add('confirm', [12, 16], 24, false);
                case 1:
                    animation.add('static', [1]);
                    animation.add('pressed', [5, 9], 12, false);
                    animation.add('confirm', [13, 17], 24, false);
                case 2:
                    animation.add('static', [2]);
                    animation.add('pressed', [6, 10], 12, false);
                    animation.add('confirm', [14, 18], 12, false);
                case 3:
                    animation.add('static', [3]);
                    animation.add('pressed', [7, 11], 12, false);
                    animation.add('confirm', [15, 19], 24, false);
            }
        } else {
            frames = Paths.getSparrowAtlas(texture);
            animation.addByPrefix('green', 'arrowUP');
            animation.addByPrefix('blue', 'arrowDOWN');
            animation.addByPrefix('purple', 'arrowLEFT');
            animation.addByPrefix('red', 'arrowRIGHT');
            antialiasing = true;
            setGraphicSize(Std.int(width * 0.7));

            switch (noteData)
            {
                case 0:
                    animation.addByPrefix('static', 'arrowLEFT');
                    animation.addByPrefix('pressed', 'left press', 24, false);
                    animation.addByPrefix('confirm', 'left confirm', 24, false);
                case 1:
                    animation.addByPrefix('static', 'arrowDOWN');
                    animation.addByPrefix('pressed', 'down press', 24, false);
                    animation.addByPrefix('confirm', 'down confirm', 24, false);
                case 2:
                    animation.addByPrefix('static', 'arrowUP');
                    animation.addByPrefix('pressed', 'up press', 24, false);
                    animation.addByPrefix('confirm', 'up confirm', 24, false);
                case 3:
                    animation.addByPrefix('static', 'arrowRIGHT');
                    animation.addByPrefix('pressed', 'right press', 24, false);
                    animation.addByPrefix('confirm', 'right confirm', 24, false);
            }
        }

        updateHitbox();
        playAnim('static');
    }

    /*override function update(elapsed:Float) {
        if (animation.curAnim.name != 'static' && animation.curAnim.name != 'pressed' && animation.curAnim.finished) playAnim('static', true);

        super.update(elapsed);
    }*/

    public function playAnim(name:String, forced:Bool = false) {
        animation.play(name, forced);
        centerOffsets();
        centerOrigin();
        if (animation.curAnim != null && animation.curAnim.name == 'confirm' && !PlayState.instance.pixelStage) centerOrigin();
    }

    public function loadThings() // sei lá que nome dar para isso kkjkjk
    {
        ID = noteData;
        x += Note.swagWidth * noteData + 100 + ((FlxG.width / 2) * player);
        /*x += 100;
        x += ((FlxG.width / 2) * player);*/
        playAnim('static');
    }
}