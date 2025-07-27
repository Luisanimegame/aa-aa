package;

import flixel.FlxG;
import flixel.FlxSprite;

class NoteSplash extends FlxSprite {
    static var colors:Array<String> = ['purple', 'blue', 'green', 'red'];

    public function new(x:Float, y:Float, noteData:Int = 0):Void {
        super(x, y);
        frames = Paths.getSparrowAtlas('noteSplashes');

        for (color in colors) {
            for (impact in 0...2) {
                animation.addByPrefix('note' + (colors.indexOf(color)) + '-' + impact, 'note splash ' + (impact + 1) + ' ' + color, 24, false);
            }
        }

        setupNoteSplash(x, y, noteData);
    }

    public function setupNoteSplash(x:Float, y:Float, noteData:Int):Void {
        setPosition(x, y);
        alpha = 0.6;

        var randomImpact = FlxG.random.int(0, 1);
        animation.play('note' + noteData + '-' + randomImpact, true);
        animation.curAnim.frameRate += FlxG.random.int(-2, 2);
        updateHitbox();

        offset.set(width * 0.3, height * 0.3);
    }

    override function update(elapsed:Float):Void {
        if (animation.curAnim.finished)
            kill();

        super.update(elapsed);
    }
}