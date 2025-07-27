package stages;
import flixel.FlxSprite;

class RockyStage extends Stages {
public function new() {
super();
curStage = 'rockynew';
}

override public function create() {
super.create();
var skyyyy = new FlxSprite(0, 0).loadGraphic(Paths.image('newrock/sky','weekrocky'));
skyyyy.setGraphicSize(Std.int(skyyyy.width * 1.7));
skyyyy.scrollFactor.set(0.1, 0.1);
addBehind(skyyyy);

var nuv = new FlxSprite(-350, -370).loadGraphic(Paths.image('newrock/clouds','weekrocky'));
nuv.setGraphicSize(Std.int(nuv.width * 1.475));
nuv.scrollFactor.set(0.2, 0.2);
addBehind(nuv);

var mon1tanha = new FlxSprite(-350, -370).loadGraphic(Paths.image('newrock/mountain1','weekrocky'));
mon1tanha.setGraphicSize(Std.int(mon1tanha.width * 1.475));
mon1tanha.scrollFactor.set(0.35, 0.35);
addBehind(mon1tanha);

var mon2tanha = new FlxSprite(-350, -370).loadGraphic(Paths.image('newrock/mountain2','weekrocky'));
mon2tanha.setGraphicSize(Std.int(mon2tanha.width * 1.475));
mon2tanha.scrollFactor.set(0.67, 0.67);
addBehind(mon2tanha);

var mon3tanha = new FlxSprite(-350, -370).loadGraphic(Paths.image('newrock/mountain3','weekrocky'));
mon3tanha.setGraphicSize(Std.int(mon3tanha.width * 1.475));
mon3tanha.scrollFactor.set(0.9, 0.9);
addBehind(mon3tanha);

var busto = new FlxSprite(-350, -370).loadGraphic(Paths.image('newrock/shrubs','weekrocky'));
busto.setGraphicSize(Std.int(busto.width * 1.475));
busto.scrollFactor.set(0.95, 0.95);
add(busto);
}
}