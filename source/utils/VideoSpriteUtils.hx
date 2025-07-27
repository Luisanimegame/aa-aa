package utils;

import flixel.FlxG;
#if hxCodec
import hxcodec.flixel.FlxVideoSprite;
#end

class VideoSpriteUtils #if hxCodec extends FlxVideoSprite #end {
    public var mute:Bool;
    public var loop:Bool;
    public var volume:Int = 1;
    public var forceDestroy:Bool;

    public function new() {
        #if hxCodec
        super();
        bitmap.onTextureSetup.add(() -> {
            setGraphicSize(Std.int(FlxG.width * 1.25)); // Assuming that you'll probably use it in mid-song
            updateHitbox();
            scrollFactor.set();
            screenCenter();
        });
        bitmap.onEndReached.add(() -> destroy());
        bitmap.mute = mute;
        bitmap.volume = volume;
        #end
    }

    #if hxCodec override #end public function destroy() {
        #if hxCodec
        if (loop && !forceDestroy)
            return;
        super.destroy();
        #end
    }
}