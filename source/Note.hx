package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;

	public var noAnim:Bool = false;
	public var altNote:Bool = false;

	public var rating:String = 'shit';
	public var noteType(default, set):String;
	public var texture(default, set):String = '';
	public var noteArray:Array<String> = ['purple', 'blue', 'green', 'red'];

	function set_noteType(type:String) {
	    if (noteType != type) {
	        switch(type.toLowerCase()) {
	            case 'noanim', 'no anim', 'noanimation', 'no animation':
	                noAnim = true;
	            case 'altnote', 'alt note', 'altanim', 'alt anim', 'alt animation': // sei la porra kkjkjk
	                altNote = true;
	        }
	        noteType = type;
	    }
	    return type;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		if (this.strumTime < 0)
			this.strumTime = 0;

		this.noteData = noteData;

		if (texture == '') {
		    if (PlayState.instance.pixelStage)
		        texture = isSustainNote ? 'arrowEnds' : 'arrows-pixels';
		    else texture = 'NOTE_assets';
		}

		if (PlayState.instance.pixelStage)
		    PlayState.SONG.noteStyle = 'pixel';

		switch (PlayState.SONG.noteStyle)
		{
			case 'pixel':
				loadGraphic(Paths.image('weeb/pixelUI/$texture','week6'), true, 17, 17);

				animation.add(noteArray[noteData] + 'Scroll', [noteData + 4]);

				if (isSustainNote)
				{
				    loadGraphic(Paths.image('weeb/pixelUI/$texture','week6'), true, 7, 6);

				    animation.add(noteArray[noteData] + 'holdend', [noteData + 4]);
				    animation.add(noteArray[noteData] + 'hold', [noteData]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
			default:
				frames = Paths.getSparrowAtlas(texture);

				animation.addByPrefix(noteArray[noteData] + 'Scroll', noteArray[noteData] + '0');

				if (isSustainNote) {
				    animation.addByPrefix('purpleholdend', 'pruple end hold');
				    animation.addByPrefix(noteArray[noteData] + 'holdend', noteArray[noteData] + ' hold end');
				    animation.addByPrefix(noteArray[noteData] + 'hold', noteArray[noteData] + ' hold piece');
				}

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		x += swagWidth * noteData;
	  animation.play(noteArray[noteData] + 'Scroll');

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			x += width / 2;

			animation.play(noteArray[noteData] + 'holdend');

			updateHitbox();

			x -= width / 2;

			if (PlayState.instance.pixelStage)
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(noteArray[prevNote.noteData] + 'hold');

				if(FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ass
			// WHERE?!
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	function set_texture(val:String):String
	{
	    if (texture != val)
	    {
	        texture = val;
	        //loadNote();
	    }

	    return val;
	}
}