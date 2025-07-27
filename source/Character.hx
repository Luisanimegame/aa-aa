package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.utils.Assets;
import jsonstuff.CharsData;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;
	public var dancePerBeat:Int = 2;
	public var chars:CharData;
	public var canDance:Bool = true;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		switch(curCharacter) {
		    default:
		        loadData();
		}

		if (curCharacter == 'bf-pixel') {
		    width -= 100;
		    height -= 100;
		}

		dance();

		if (isPlayer)
			flipX = !flipX;
	}

	override function update(elapsed:Float)
	{
	    if(animation.curAnim != null) {
	        if (!canDance) {
	            if (animation.curAnim.finished) {
	                //new FlxTimer().start(0.5, (tmr) -> {
	                  canDance = true;
	                  dance();
	                //});
	            }
	        }
	        if (!isPlayer)
	        {
	          if (animation.curAnim.name.startsWith('sing'))
	              holdTimer += elapsed;
	          
	          var dadVar:Float = chars.singTime != null ? chars.singTime : 4;

	          if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
	          {
	            dance();
	            holdTimer = 0;
	          }
	      }

	      switch (curCharacter)
	      {
	          case 'gf':
	              if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
	                  playAnim('danceRight');
	      }
	  }
		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
	  if (!canDance)
	    return;
		if (!debugMode)
		{
			switch (curCharacter)
			{
				default:
				  if (chars.danceLeftandRight)
				  {
				      danced = !danced;

				      if (danced)
				          playAnim('danceRight');
				      else
				          playAnim('danceLeft');
				  } else
				      playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];

	public function loadData() {
	    var charPath:String = 'assets/characters/' + curCharacter + '.json';
	    if (!Assets.exists(charPath))
	        charPath = 'assets/characters/bf.json';

	    try {
	        chars = Json.parse(Assets.getText(charPath));

	        if (Assets.exists(Paths.getPath('images/' + chars.frame + '.txt', TEXT)))
	            frames = Paths.getPackerAtlas(chars.frame);

	        if (Assets.exists(Paths.getPath('images/' + chars.frame + '.xml', TEXT)))
	            frames = Paths.getSparrowAtlas(chars.frame);

	        dancePerBeat = (chars.danceLeftandRight != false) ? 1 : 2;

	        if (chars.size != 1) {
	            setGraphicSize(Std.int(width * chars.size));
	            updateHitbox();
	        }

	        antialiasing = chars.antialiasing;

	        flipX = chars.flipX;
	        
	        if (chars.healthColor == null && chars.healthColor.length <= 0) {
	            if (!isPlayer)
	                chars.healthColor = [255, 0, 0];
	            else
	                chars.healthColor = [0, 255, 0];
	        }

	        if (chars.anims != null && chars.anims.length > 0) {
	            for (anim in chars.anims) {
	                if (anim.indices != null && anim.indices.length > 0)
	                    animation.addByIndices(anim.name, anim.prefix, anim.indices, '', anim.fps, anim.loop);
	                else
	                    animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.loop);
	            }
	        }
	        /** Raiva
	         * Obrigado https://stackoverflow.com/a/51721512 *kiss*
	         */
	         for (name in Reflect.fields(chars.offsets)) {
	            var daOffset = Reflect.field(chars.offsets, name);
	            addOffset(name, daOffset[0], daOffset[1]);
	         }
	    } catch(e:Dynamic) {
	        // Ratomanocu
	    }
	}
}