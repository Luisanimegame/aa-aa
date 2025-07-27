package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class Freeplay2State extends MusicBeatState
{
	var songs:Array<Song2Metadata> = [];

	static var curSelected:Int = 0;
	static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
	    Paths.clearUnusedMemory();
	    Paths.clearStoredMemory();
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplayOLDSonglist'));

		for (i in 0...initSonglist.length)
		{
		    var data:Array<String> = initSonglist[i].split(':');
		    songs.push(new Song2Metadata(data[0], Std.parseInt(data[2]), data[1], (data[3] != null && data[3] != '') ? data[3].split(',') : ["Easy", "Normal", "Hard"]));
		}

			if (FlxG.sound.music != null)
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

		 #if windows
		 DiscordClient.changePresence("In the Freeplay Menu", null);
		 #end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();
		
		var txt:FlxText = new FlxText(0, 0, FlxG.width, "Press SPACE to open the New Songs Menu");
        txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
        txt.borderColor = FlxColor.BLACK;
        txt.borderSize = 6;
        txt.borderStyle = FlxTextBorderStyle.OUTLINE;
        txt.screenCenter();
		txt.y += 200;
        add(txt);

		#if mobile addVPad(FULL, A_B_C); #end

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
		songs.push(new Song2Metadata(songName, weekNum, songCharacter));

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());
			
		if (FlxG.keys.justPressed.SPACE #if mobile || vPad.buttonC.justPressed #end)
			FlxG.switchState(new FreeplayState());

		if (accepted)
		{
			var poop:String = Highscore.formatSong(StringTools.replace(songs[curSelected].songName," ", "-").toLowerCase(), CoolUtil.defaultDiff);

			PlayState.SONG = Song.loadFromJson(poop, StringTools.replace(songs[curSelected].songName," ", "-").toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = CoolUtil.defaultDiff.toUpperCase();
			PlayState.storyWeek = songs[curSelected].week;
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyArray.length-1;
		if (curDifficulty >= CoolUtil.difficultyArray.length)
			curDifficulty = 0;
			
		CoolUtil.defaultDiff = CoolUtil.difficultyArray[curDifficulty].toUpperCase();

		intendedScore = Highscore.getScore(songs[curSelected].songName, CoolUtil.defaultDiff);

		if (songs[curSelected].diff.length > 1)
		    diffText.text = "< " + CoolUtil.defaultDiff + " >";
		else
		    diffText.text = CoolUtil.defaultDiff;
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, CoolUtil.defaultDiff);

		CoolUtil.difficultyArray = songs[curSelected].diff;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}

class Song2Metadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var diff:Array<String> = CoolUtil.difficultyArray;

	public function new(song:String, week:Int, songCharacter:String, ?diff:Array<String>)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		if (diff != null)
		    this.diff = diff;
	}
}
