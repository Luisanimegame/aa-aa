package stages;
import flixel.FlxSprite;

class OldRockyStage extends Stages {
public function new() {
super();
curStage = 'oldrock';
}

override public function create() {
super.create();
var rockybg = new FlxSprite(-600, -200).loadGraphic(Paths.image('oldrockstage','weekrocky'));
rockybg.scrollFactor.set(0.9, 0.9);
addBehind(rockybg);

bfGroup.scrollFactor.set(0.9, 0.9);
gfGroup.scrollFactor.set(0.9, 0.9);
dadGroup.scrollFactor.set(0.9, 0.9);
}
}