package;

import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;

import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import jsonstuff.Events;
import jsonstuff.Stage;
import jsonstuff.Week;
import stages.*;
import stages.Stage as BaseStage;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if hxCodec
import hxcodec.flixel.*;
import utils.VideoSpriteUtils;
#end

#if windows
import Discord.DiscordClient;
#end
#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = 'stage';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:String = 'normal';
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;
	
	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var playerVocals:FlxSound;
	public var opponentVocals:FlxSound;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	
	public var strumLine:FlxSprite;

	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<StaticArrows> = null;
	public static var playerStrums:FlxTypedGroup<StaticArrows> = null;
	public static var cpuStrums:FlxTypedGroup<StaticArrows> = null;

	public var camZooming:Bool = true;
	private var curSong:String = "";

	public var health:Float = 1; //making public because sethealth doesnt work without it
	public var combo:Int = 0;
	public static var misses:Int = 0;
	public var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var songPositionBar:Float = 0;
	
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	
	private var drainHealth:Bool = false;

	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?
	public var camGame:FlxCamera;
	public var camGame2:FlxCamera;
	public var camHUD:FlxCamera;
	public var camHUD2:FlxCamera;
	public var hudGroup:FlxTypedGroup<FlxSprite>;
	public var notesGroup:FlxTypedGroup<FlxBasic>;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var songName:FlxText;

	var fc:Bool = true;

	var talking:Bool = true;
	var songScore:Int = 0;
	var songScoreDef:Int = 0;
	public var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;
	public var pixelStage:Bool = false;

	public static var theFunne:Bool = true;
	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	
	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;
	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Float> = [];

	private var executeModchart = false;

	// Custom stuff 'cuz it's cool
	public var stagesArray:Array<Stages> = [];
	public var events:Array<EventVars> = [];
	public var HScriptArray:Array<HScript> = [];
	public var ignoreCountdown:Bool = false;
	public var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public var stageJson:StageData;
	var noteTypeMap:Map<String, Bool> = [];
	public var zoomPerBeat:Int = 4;

	public var bfMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();

	public var bfGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public var songSpeed:Float = 1;
	public var camCanMove:Bool = true;

	// API stuff
	public function addObject(object:FlxBasic) { add(object); }
	public function removeObject(object:FlxBasic) { remove(object); }

	override public function create()
	{
		instance = this;
		
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		#if sys
		executeModchart = Assets.exists(Paths.lua(SONG.song.toLowerCase()  + "/modchart"));
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		#if windows
		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
			detailsText = "Story Mode: Week " + storyWeek;
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camGame2 = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD2 = new FlxCamera();
		camGame2.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camHUD2.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camGame2, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camHUD2, false);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		//dialogue shit
		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dad battle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
			case 'rock':
				dialogue = CoolUtil.coolTextFile(Paths.txt('rock/rockDialogue'));
			case 'angru':
				dialogue = CoolUtil.coolTextFile(Paths.txt('angru/angruDialogue'));
			case 'smas':
				dialogue = CoolUtil.coolTextFile(Paths.txt('smas/smasDialogue'));
		}
		curStage = SONG.stage;
		if (curStage == null || curStage.length < 1) {
		    switch(Paths.spaceToDash(SONG.song))
		    {
		        default:
		            curStage = 'stage';
		    }
		}
		SONG.stage = curStage;
		stageJson = Stage.getStage(curStage);

		if (stageJson == null) {
		    stageJson = {
		        zoom: 0.9,
		        isPixel: false,
		        bf: [0, 0],
		        dad: [0, 0],
		        gf: [0, 0],
		        camBF: [0, 0],
		        camDad: [0, 0]
		    }
		}

		if (stageJson.bf == null)
		    stageJson.bf = [0, 0];
		if (stageJson.dad == null)
		    stageJson.dad = [0, 0];
		if (stageJson.gf == null)
		    stageJson.gf = [0, 0];
		if (stageJson.camBF == null)
		    stageJson.camBF = [0, 0];
		if (stageJson.camDad == null)
		    stageJson.camDad = [0, 0];

		defaultCamZoom = stageJson.zoom;
		pixelStage = stageJson.isPixel;

		bfGroup = new FlxSpriteGroup(stageJson.bf[0], stageJson.bf[1]);
		dadGroup = new FlxSpriteGroup(stageJson.dad[0], stageJson.dad[1]);
		gfGroup = new FlxSpriteGroup(stageJson.gf[0], stageJson.gf[1]);
		add(gfGroup);
		add(dadGroup);
		add(bfGroup);
		hudGroup = new FlxTypedGroup<FlxSprite>();
		add(hudGroup);
		notesGroup = new FlxTypedGroup<FlxBasic>();
		add(notesGroup);

		stagesArray = [];
		switch(curStage)
		{
		    case 'stage':
		        stagesArray.push(new BaseStage());
			case 'rockynew':
		        stagesArray.push(new RockyStage());
			case 'oldrock':
		        stagesArray.push(new OldRockyStage());
		}

		for (stage in stagesArray) {
		    stage.create();
		    //stage.curStage = curStage;
		}

		if (SONG.gfVersion == null || SONG.gfVersion.length < 1) {
		    switch (curStage)
		    {
		        default:
		            SONG.gfVersion = 'gf';
		    }
		}

		gf = new Character(0, 0, SONG.gfVersion);
		gf.x += gf.chars.pos[0];
		gf.y += gf.chars.pos[1];
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);

		dad = new Character(0, 0, SONG.player2);
		dad.x += dad.chars.pos[0];
		dad.y += dad.chars.pos[1];
		dadGroup.add(dad);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x + 100, dad.getGraphicMidpoint().y + 50);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		boyfriend.x += boyfriend.chars.pos[0];
		boyfriend.y += boyfriend.chars.pos[1];
		bfGroup.add(boyfriend);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'schoolEvil':
				if(FlxG.save.data.distractions){
				// trailArea.scrollFactor.set();
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				for (stage in stagesArray)
				    stage.addBehind(evilTrail, 'dad');
				// evilTrail.scrollFactor.set(1.1, 1.1);
				}
		}
		
		if (dad.curCharacter.startsWith('gf')) {
		    gf.visible = false;
		    dad.x = gf.x;
		    dad.y = gf.y;
		}

		var assetScript:String = 'assets/stages/${curStage}.hx';
		if (Assets.exists(assetScript)) HScriptArray.push(new HScript(assetScript));

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;
		
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<StaticArrows>();
		notesGroup.add(strumLineNotes);
		
		// eu odeio meus splashs

		playerStrums = new FlxTypedGroup<StaticArrows>();
		cpuStrums = new FlxTypedGroup<StaticArrows>();

		generateSong();
		generateEvents();
		
		for (file in Assets.list().filter(folder -> folder.indexOf('assets/scripts/') != -1))
		    if (file.endsWith('.hx')) HScriptArray.push(new HScript(file));

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		hudGroup.add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.fromRGB(dad.chars.healthColor[0], dad.chars.healthColor[1], dad.chars.healthColor[2]), FlxColor.fromRGB(boyfriend.chars.healthColor[0], boyfriend.chars.healthColor[1], boyfriend.chars.healthColor[2]));
		// healthBar
		hudGroup.add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50,0,SONG.song + " " + CoolUtil.defaultDiff.toUpperCase() + (Main.watermarks ? " - KE " + MainMenuState.kadeEngineVer : ""), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		hudGroup.add(kadeEngineWatermark);

		if (FlxG.save.data.downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		if (offsetTesting)
			scoreTxt.x += 300;
		if(FlxG.save.data.botplay) scoreTxt.x = FlxG.width / 2 - 20;
		hudGroup.add(scoreTxt);

		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		
		if(FlxG.save.data.botplay) hudGroup.add(botPlayState);

		iconP1 = new HealthIcon(boyfriend.chars.icon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		hudGroup.add(iconP1);

		iconP2 = new HealthIcon(dad.chars.icon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		hudGroup.add(iconP2);

		hudGroup.cameras = [camHUD];
		notesGroup.cameras = [camHUD];
		doof.cameras = [camHUD];

		#if mobile
		addMControls();
		setOnScripts('vPad', vPad);
		setOnScripts('mcontrols', mcontrols);
		#end
		setOnScripts('controls', controls);

		startingSong = true;

		for (notetype in noteTypeMap.keys())
		{
		    var assetScript:String = 'assets/noteTypes/' + notetype + '.hx';
		    if (Assets.exists(assetScript)) HScriptArray.push(new HScript(assetScript));
		}
		noteTypeMap = null;

		for (file in Assets.list().filter(folder -> folder.indexOf('assets/data/' + Paths.spaceToDash(SONG.song) + '/') != -1))
		    if (file.endsWith('.hx')) HScriptArray.push(new HScript(file));
		
		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, (tmr:FlxTimer) ->
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, (tmr:FlxTimer) ->
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: (twn:FlxTween) -> startCountdown()
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'rock':
					schoolIntro(doof);
				case 'angru':
					schoolIntro(doof);
				case 'smas':
					schoolIntro(doof);
				default:
					if (stopCountdown != null)
				      stopCountdown();
				  else
				      startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					if (stopCountdown != null)
				      stopCountdown();
				  else
				      startCountdown();
			}
		}
		callOnScripts('createPost', []);
		for (stage in stagesArray) stage.createPost();
		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
				add(red);
		}

		new FlxTimer().start(0.3, (tmr:FlxTimer) ->
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
				tmr.reset(0.3);
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, (swagTimer:FlxTimer) ->
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
								swagTimer.reset();
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, () ->
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, () ->
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, (deadTime:FlxTimer) -> FlxG.camera.fade(FlxColor.WHITE, 1.6, false));
							}
						});
					}
					else
						add(dialogueBox);
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	public function playVideo(name:String)
	{
		#if hxCodec
		inCutscene = true;
		camHUD.visible = false;

		var videoPath:String = Paths.video(name);
		if (!Assets.exists(videoPath) #if sys || !sys.FileSystem.exists(videoPath) #end)
		{
			if (endingSong)
			    if (stopEnd != null)
			        stopEnd();
			    else
			        endSong();
			else
				if (stopCountdown != null)
				      stopCountdown();
				  else
				      startCountdown();
		}

		var vid:VideoSpriteUtils = new VideoSpriteUtils();
		vid.load(videoPath);
		vid.play();
		vid.bitmap.onEndReached.add(() ->
		{
		  if (endingSong)
			    if (stopEnd != null)
			        stopEnd();
			    else
			        endSong();
			else
				if (stopCountdown != null)
				      stopCountdown();
				  else
				      startCountdown();
		});
		add(vid);
		#else
		if (endingSong)
		    if (stopEnd != null) stopEnd();
		    else
		    endSong();
		else
		    if (stopCountdown != null) stopCountdown();
		    else startCountdown();
		#end
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	var luaWiggles:Array<WiggleEffect> = [];

	#if sys
	public static var luaModchart:ModchartState = null;
	#end

	public var stopCountdown:Void->Void = null;
	public var stopEnd:Void->Void = null;
	function startCountdown():Void
	{
	    if (startedCountdown)
	    {
	        callOnScripts('startCountdown', []);
	        return;
	    }
	    var scriptCall:Dynamic = callOnScripts('startCountdown', []);
	  if (ignoreCountdown)
	  {
	      inCutscene = false;
	      generateStaticArrows(0);
	      generateStaticArrows(1);
	      Conductor.songPosition = 0;
	      //startSong();
	      camHUD.visible = true;
	      startedCountdown = true;
	      #if mobile
	      mcontrols.visible = true;
	      mcontrols.alpha = 0.001;
	      FlxTween.tween(mcontrols, {alpha: 1}, 1);
	      #end
	      return;
	  }
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		#if mobile FlxTween.tween(mcontrols, {visible: true}, 1); #end

		#if sys
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start',[SONG.song]);
		}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, (tmr:FlxTimer) ->
		{
		  var leChars:Array<Character> = [boyfriend, dad, gf];
		  for (char in leChars) {
		      if (char != null && (tmr.loopsLeft % char.dancePerBeat == 0 && 
		      (char.animation.curAnim != null && !char.animation.name.startsWith('sing'))))
		          char.dance();
		  }
		  
		  for (stage in stagesArray)
		      stage.startCountdown(tmr.loopsLeft);

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (pixelStage)
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (pixelStage)
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (pixelStage)
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(SONG.song, CoolUtil.defaultDiff.toLowerCase()), 1, false);

		FlxG.sound.music.onComplete = stopEnd != null ? stopEnd : endSong;
		if (SONG.needsVoices)
		{
		    playerVocals.play();
		    opponentVocals.play();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (FlxG.save.data.downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45; 
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			hudGroup.add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			hudGroup.add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			hudGroup.add(songName);
		}
		
		// Song check real quick
		switch(curSong)
		{
			case 'Bopeebo' | 'Philly' | 'Blammed' | 'Cocoa' | 'Eggnog': allowedToHeadbang = true;
			default: allowedToHeadbang = false;
		}
		
		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
		callOnScripts('startSong', []);
		for (stage in stagesArray) stage.startSong();
	}

	var debugNum:Int = 0;

	private function generateSong():Void
	{
	    songSpeed = SONG.speed;
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		playerVocals = new FlxSound();
	  opponentVocals = new FlxSound();
		if (SONG.needsVoices)
		{
		    playerVocals.loadEmbedded(Paths.voices(SONG.song, boyfriend.curCharacter.toLowerCase(), CoolUtil.defaultDiff.toLowerCase()));
		    opponentVocals.loadEmbedded(Paths.voices(SONG.song, dad.curCharacter.toLowerCase(), CoolUtil.defaultDiff.toLowerCase()));

		    FlxG.sound.list.add(playerVocals);
		    FlxG.sound.list.add(opponentVocals);
		}

		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(SONG.song, CoolUtil.defaultDiff.toLowerCase())));

		notes = new FlxTypedGroup<Note>();
		notesGroup.add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if windows
			var songPath = 'assets/data/' + SONG.song.toLowerCase() + '/';
			for(file in sys.FileSystem.readDirectory(songPath))
			{
				var path = haxe.io.Path.join([songPath, file]);
				if(!sys.FileSystem.isDirectory(path))
				{
					if(path.endsWith('.offset'))
					{
						songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
						break;
					}else
						sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		#end
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.noteType = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					sustainNote.noteType = swagNote.noteType;
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2; // general offset
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2; // general offset
			 if(!noteTypeMap.exists(swagNote.noteType)) noteTypeMap.set(swagNote.noteType, true);
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	public function generateEvents(){
	  var songPath:String = Paths.json(Paths.spaceToDash(SONG.song) + '/events');
	  if (Assets.exists(songPath)) {
	    var eventos:Array<Dynamic> = Json.parse(Assets.getText(songPath)).events;
	    
	    for (i in 0...eventos.length)
	      events.push({
	        time: eventos[i][0],
	        name: eventos[i][1],
	        val1: eventos[i][2],
	        val2: eventos[i][3]});
	  }

	  for (event in events)
	    if (event.name.toLowerCase() == 'change character')
	      addCharacterToList(event.val2, event.val1.toLowerCase());
	}

	function sortEvents(a:EventVars, b:EventVars):Int
	  return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
	
	function pushEvents(event:EventVars) {
	  //for (event in events) {
	    switch(event.name.toLowerCase()) {
	      case 'hey!':
	        switch(event.val1.toLowerCase()) {
	          case 'boyfriend', 'bf':
	            if (boyfriend.animOffsets.exists('hey')) {
	                boyfriend.playAnim('hey', true);
	                boyfriend.canDance = false;
	            }
	          case 'dad', 'opponent':
	            if (dad.animOffsets.exists('hey')) {
	                dad.playAnim('hey', true);
	                dad.canDance = false;
	            }
	          case 'girlfriend', 'gf':
	            if (gf.animOffsets.exists('hey')) {
	                gf.playAnim('hey', true);
	                gf.canDance = false;
	            } else if (gf.animOffsets.exists('cheer')) {
	                gf.playAnim('cheer', true);
	                gf.canDance = false;
	            }
	        }
	      case 'change character':
	        changeCharacter(event.val1.toLowerCase(), event.val2);
	      case 'add camera zoom':
	        if (FlxG.camera.zoom < 1.35)
	        {
	          var camZoom:Float = Std.parseFloat(event.val1);
	          var hudZoom:Float = Std.parseFloat(event.val2);

	          if (Math.isNaN(camZoom))
	            camZoom = 0.015;

	          if (Math.isNaN(hudZoom))
	            hudZoom = 0.03;
	          
	          FlxG.camera.zoom += camZoom;
	          camHUD.zoom += hudZoom;
	        }
	      case 'set gf speed':
	        if (Math.isNaN(Std.parseInt(event.val1)) || Std.parseInt(event.val1) < 1)
	          gf.dancePerBeat = 1;

	        gf.dancePerBeat = Std.parseInt(event.val1);
	      case 'play animation':
	        switch(event.val1.toLowerCase()) {
	          case 'boyfriend', 'bf':
	            boyfriend.playAnim(event.val2.toLowerCase(), true);
	            boyfriend.canDance = false;
	          case 'dad', 'opponent':
	            dad.playAnim(event.val2.toLowerCase(), true);
	            dad.canDance = false;
	          case 'girlfriend', 'gf':
	            gf.playAnim(event.val2.toLowerCase(), true);
	            gf.canDance = false;
	        }
	      case 'change scroll speed':
	        var speeeed:Float = SONG.speed * Std.parseFloat(event.val1);

	        if (Std.parseFloat(event.val2) < 0)
	          songSpeed = speeeed;
	        else
	          FlxTween.tween(this, {songSpeed: speeeed}, Std.parseFloat(event.val2));
	    }

	    if (executeModchart && luaModchart != null)
	        luaModchart.executeState('onEvent', [event.name.toLowerCase(), event.val1, event.val2]);
	    for (stage in stagesArray)
	        stage.onEvent(event);
	     callOnScripts('onEvent', [event.name, event.val1, event.val2]);
	  //}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:StaticArrows = new StaticArrows(FlxG.save.data.middlescroll ? -325 : 0, FlxG.save.data.downscroll ? strumLine.y : 50, i, player);

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0.001;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			switch(player)
			{
			    case 0:
			        cpuStrums.add(babyArrow);
			    case 1:
			        playerStrums.add(babyArrow);
			}

			babyArrow.loadThings();

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				if (SONG.needsVoices)
				{
				    playerVocals.pause();
				    opponentVocals.pause();
				}
			}

			FlxTween.globalManager.forEach((twn) -> twn.active = false);
			FlxTimer.globalManager.forEach((time) -> time.active = false);

			for (stage in stagesArray) stage.pause();

			#if windows
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end
			if (startTimer != null && (!startTimer.finished))
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			FlxTween.globalManager.forEach((twn) -> twn.active = true);
			FlxTimer.globalManager.forEach((time) -> time.active = true);

			for (stage in stagesArray) stage.resume();

			if (startTimer != null && (!startTimer.finished))
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
			callOnScripts('resume', []);
		}

		super.closeSubState();
	}
	

	function resyncVocals():Void
	{
		if (SONG.needsVoices)
	  {
	      playerVocals.pause();
	      opponentVocals.pause();
	  }

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (SONG.needsVoices)
		{
		    playerVocals.time = Conductor.songPosition;
		    opponentVocals.time = Conductor.songPosition;
		    playerVocals.play();
		    opponentVocals.play();
		}

		#if windows
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	override public function update(elapsed:Float)
	{
	  callOnScripts('update', [elapsed]);
		if (FlxG.save.data.botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;
		
		if (drainHealth) // yoisabo codes hehehe
		{
			health -= 0.00240;
		}

		#if sys
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos',Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom',FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			for (i in luaWiggles)
				i.update(elapsed);

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle','float');

			if (luaModchart.getVar("showOnlyStrums",'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible",'bool');
			var p2 = luaModchart.getVar("strumLine2Visible",'bool');

			for (i in 0...4)
			{
				cpuStrums.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length-1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		for (stage in stagesArray)
		    stage.update(elapsed);

		super.update(elapsed);

		scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy);
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.text = "Score: " + songScore;

		if (FlxG.keys.justPressed.ENTER #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
		{
		  callOnScripts('pause', []);
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			#if sys
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (iconP1.animation.curAnim != null) {
		    if (healthBar.percent < 20)
		        iconP1.animation.curAnim.curFrame = 1;
		    else
		        iconP1.animation.curAnim.curFrame = 0;
		}

		if (iconP2.animation.curAnim != null) {
		    if (healthBar.percent > 80)
		        iconP2.animation.curAnim.curFrame = 1;
		    else
		        iconP2.animation.curAnim.curFrame = 0;
		}

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
			#if sys
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			#if sys
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null && camCanMove)
		{
			#if sys
			if (luaModchart != null)
				luaModchart.setVar("mustHit",SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (camFollow.x != dad.getMidpoint().x + 150 && !SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if sys
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				//camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				FlxTween.cancelTweensOf(camFollow);
				var offX = dad.getMidpoint().x + 150 + offsetX + (dad.chars.camPos[0] + stageJson.camDad[0]);
				var offY = dad.getMidpoint().y - 100 + offsetY + (dad.chars.camPos[1] + stageJson.camDad[1]);
				//FlxTween.tween(camFollow, {x: dad.getMidpoint().x + 150 + offsetX, y: dad.getMidpoint().y - 100 + offsetY}, 0.5, {ease: FlxEase.circOut});
				FlxTween.tween(camFollow, {x: offX, y: offY}, 0.5, {ease: FlxEase.expoOut});
				/*camFollow.x += dad.chars.camPos[0] + stageJson.camDad[0];
				camFollow.y += dad.chars.camPos[1] + stageJson.camDad[1];*/
				#if sys
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
			}

			if (SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if sys
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				//camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
				FlxTween.cancelTweensOf(camFollow);
				var offX = boyfriend.getMidpoint().x - 100 + offsetX - (boyfriend.chars.camPos[0] - stageJson.camBF[0]);
				var offY = boyfriend.getMidpoint().y - 100 + offsetY + (boyfriend.chars.camPos[1] + stageJson.camBF[1]);
				//FlxTween.tween(camFollow, {x: boyfriend.getMidpoint().x - 100 + offsetX, y: boyfriend.getMidpoint().y - 100 + offsetY}, 0.5, {ease: FlxEase.circOut});
				FlxTween.tween(camFollow, {x: offX, y: offY}, 0.5, {ease: FlxEase.expoOut});
				/*camFollow.x -= boyfriend.chars.camPos[0] - stageJson.camBF[0];
				camFollow.y += boyfriend.chars.camPos[1] + stageJson.camBF[1];*/
				#if sys
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end
			}

			if (camCanMove && FlxG.save.data.camMovement) {
			    var chars:Character = SONG.notes[Std.int(curStep / 16)].mustHitSection ? boyfriend : dad;
			    var directions = {
		        'singLEFT': [-4, 0],
		        'singDOWN': [0, 6],
		        'singUP': [0, -4],
		        'singRIGHT': [6, 0]
			    };
			    for (anim in Reflect.fields(directions)) {
			        var realAnim = Reflect.field(directions, anim);
			        if (chars.animation.curAnim.name.contains(anim)){
			            camFollow.x += realAnim[0] - 1;
			            camFollow.y += realAnim[1] - 1;
			        }
			    }
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gf.dancePerBeat = 2;
				case 48:
					gf.dancePerBeat = 1;
				case 80:
					gf.dancePerBeat = 2;
				case 112:
					gf.dancePerBeat = 1;
			}
		}
		
		if (curSong == "Smas")
		{
		if (health <= 0.10)
		{
		drainHealth = false;
		}
		if (health >= 0.10)
		{
		drainHealth = true;
		}
		}

		if (health <= 0)
		{
		  callOnScripts('gameOver', []);
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			if (SONG.needsVoices)
			{
			    playerVocals.stop();
			    opponentVocals.stop();
			}
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			FlxTween.globalManager.forEach((twn) -> twn.active = true);
			FlxTimer.globalManager.forEach((time) -> time.active = true);

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
 		if (FlxG.save.data.resetButton)
		{
			if(FlxG.keys.justPressed.R)
				{
					boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;
		
					if (SONG.needsVoices)
					{
					  playerVocals.stop();
					  opponentVocals.stop();
					}
					FlxG.sound.music.stop();
		
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
					FlxTween.globalManager.forEach((twn) -> twn.active = true);
					FlxTimer.globalManager.forEach((time) -> time.active = true);
		
					#if windows
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
					#end
		
					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
					
					if (!daNote.modifiedByLua)
						{
							if (FlxG.save.data.downscroll)
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[daNote.noteData].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								else
									daNote.y = (cpuStrums.members[daNote.noteData].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								if(daNote.isSustainNote)
								{
									// Remember = minus makes notes go up, plus makes them go down
									if(daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
										daNote.y += daNote.prevNote.height;
									else
										daNote.y += daNote.height / 2;
	
									// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
									if(!FlxG.save.data.botplay)
									{
										if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
										{
											// Clip to strumline
											var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
											swagRect.height = (cpuStrums.members[daNote.noteData].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
											swagRect.y = daNote.frameHeight - swagRect.height;
	
											daNote.clipRect = swagRect;
										}
									}else {
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (cpuStrums.members[daNote.noteData].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;
	
										daNote.clipRect = swagRect;
									}
								}
							}else
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[daNote.noteData].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								else
									daNote.y = (cpuStrums.members[daNote.noteData].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
								if(daNote.isSustainNote)
								{
									daNote.y -= daNote.height / 2;
	
									if(!FlxG.save.data.botplay)
									{
										if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
										{
											// Clip to strumline
											var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
											swagRect.y = (cpuStrums.members[daNote.noteData].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
											swagRect.height -= swagRect.y;
	
											daNote.clipRect = swagRect;
										}
									}else {
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (cpuStrums.members[daNote.noteData].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;
	
										daNote.clipRect = swagRect;
									}
								}
							}
						}
	
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;

						var altAnim:String = "";
	
						if ((SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) || daNote.altNote)
								altAnim = '-alt';
	
						if (!daNote.noAnim) {
						    if (dad.animation.getByName(singAnimations[daNote.noteData] + altAnim) != null)
						        dad.playAnim(singAnimations[daNote.noteData] + altAnim, true);
						    else
						        dad.playAnim(singAnimations[daNote.noteData], true);
						}

						if (FlxG.save.data.cpuStrums)
						{
							cpuStrums.forEach((spr:StaticArrows) ->
							{
								if (daNote.noteData == spr.ID)
								  if (dad.curCharacter != 'roco')
									spr.playAnim('confirm', true);
							});
						}
	
						#if sys
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [daNote.noteData, Conductor.songPosition]);
						#end

						dad.holdTimer = 0;

						for (stage in stagesArray)
						    stage.opponentNoteHit(daNote);
						
						iconP2.scale.set(iconP2.scale.x + 0.05, iconP2.scale.y + 0.05);
						iconP2.updateHitbox();
	
						if (dad.curCharacter != 'roco') notes.remove(daNote, true);
						//daNote.destroy();
						callOnScripts('opponentNoteHit', [notes.members.indexOf(daNote), daNote.noteData, daNote.isSustainNote, daNote.noteType]);
					}

					if (daNote.mustPress && !daNote.modifiedByLua)
					{
						daNote.visible = playerStrums.members[daNote.noteData].visible;
						daNote.x = playerStrums.members[daNote.noteData].x;
						if (!daNote.isSustainNote)
							daNote.angle = playerStrums.members[daNote.noteData].angle;
						daNote.alpha = playerStrums.members[daNote.noteData].alpha;
					}
					else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
					{
						daNote.visible = cpuStrums.members[daNote.noteData].visible;
						daNote.x = cpuStrums.members[daNote.noteData].x;
						if (!daNote.isSustainNote)
							daNote.angle = cpuStrums.members[daNote.noteData].angle;
						daNote.alpha = cpuStrums.members[daNote.noteData].alpha;
					}

					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
	
					if ((daNote.mustPress && daNote.tooLate && !FlxG.save.data.downscroll || daNote.mustPress && daNote.tooLate && FlxG.save.data.downscroll) && daNote.mustPress)
					{
							if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								//daNote.kill();
								notes.remove(daNote, true);
							}
							else
							{
								health -= 0.075;
								playerVocals.volume = 0;
								if (theFunne)
									noteMiss(daNote.noteData, daNote);
							}
		
							daNote.visible = false;
							//daNote.kill();
							notes.remove(daNote, true);
						}
					
				});
			}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach((spr:StaticArrows) ->
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static');
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		for (event in events)
		  if (event.time <= Conductor.songPosition) {
		    pushEvents(event);
		    events.remove(event);
		  }
		  callOnScripts('updatePost', [elapsed]);
		  for (stage in stagesArray) stage.updatePost(elapsed);
	}

	function endSong():Void
	{
	  var scriptCall:Dynamic = callOnScripts('endSong', []);
	  for (stage in stagesArray) stage.endSong();
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if sys
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		if (SONG.needsVoices)
		{
		  playerVocals.volume = 0;
		  opponentVocals.volume = 0;
		}
		endingSong = true;
		#if mobile FlxTween.tween(mcontrols, {visible: false}, 0.7); #end
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					FlxG.switchState(new StoryMenuState());

					#if sys
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					StoryMenuState.weekCompleted.set(Week.weekList[storyWeek], true);

					var weekList:Array<String> = [];

					if (SONG.validScore)
						Highscore.saveWeekScore(Week.weekList[storyWeek], campaignScore, CoolUtil.defaultDiff.toLowerCase());

					FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
					FlxG.save.flush();
				}
				else
				{
					var difficulty:String = "";
				
					if (CoolUtil.defaultDiff.toLowerCase() != 'normal')
					    difficulty = '-' + CoolUtil.defaultDiff.toLowerCase();

					if (SONG.song.toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else {
			  FlxG.sound.music.stop();
			  FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.switchState(new FreeplayState());
			}
		}
	}

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			if (SONG.needsVoices) playerVocals.volume = 0.6;
	
			var rating:FlxSprite = new FlxSprite();
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			var daRating = daNote.rating;

			switch(daRating)
			{
				case 'shit':
					score = -300;
					combo = 0;
					misses++;
					health -= 0.2;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.25;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (health < 2)
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						health += 0.1;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
			}

			if (daRating != 'shit' || daRating != 'bad')
				{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
	
			var pixelShitPart1:String = pixelStage ? 'weeb/pixelUI/' : '';
			var pixelShitPart2:String = pixelStage ? '-pixel' : '';

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = FlxG.width * 0.55 - 125;
			
			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			
			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if(FlxG.save.data.botplay) msTiming = 0;							   

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length,2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if(!FlxG.save.data.botplay) add(currentTimingShown);
			
			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if(!FlxG.save.data.botplay) add(rating);
	
			if (!pixelStage)
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
	
			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				
				if (!pixelStage) {
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				} else
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				if (combo >= 10 || combo == 0)
					add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: (tween:FlxTween) ->
					{
					  remove(numScore, true);
						//numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
				daLoop++;
			}

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: (tween:FlxTween) ->
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: (tween:FlxTween) ->
				{
					//comboSpr.destroy();
					remove(comboSpr, true);
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					//rating.destroy();
					remove(rating, true);
				},
				startDelay: Conductor.crochet * 0.001
			});
				}
		}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	

		private function keyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				var pressArray:Array<Bool> = [
					controls.LEFT_P,
					controls.DOWN_P,
					controls.UP_P,
					controls.RIGHT_P
				];
				var releaseArray:Array<Bool> = [
					controls.LEFT_R,
					controls.DOWN_R,
					controls.UP_R,
					controls.RIGHT_R
				];
				#if sys
				if (luaModchart != null){
				if (controls.LEFT_P){luaModchart.executeState('keyPressed',["left"]);};
				if (controls.DOWN_P){luaModchart.executeState('keyPressed',["down"]);};
				if (controls.UP_P){luaModchart.executeState('keyPressed',["up"]);};
				if (controls.RIGHT_P){luaModchart.executeState('keyPressed',["right"]);};
				};
				#end
		 
				// Prevent player input if botplay is on
				if(FlxG.save.data.botplay)
				{
					holdArray = [false, false, false, false];
					pressArray = [false, false, false, false];
					releaseArray = [false, false, false, false];
				} 
				// HOLDS, check for sustain notes
				if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					notes.forEachAlive((daNote:Note) ->
					{
						if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
							goodNoteHit(daNote);
					});
				}
		 
				// PRESSES, check for note hits
				if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					boyfriend.holdTimer = 0;
		 
					var possibleNotes:Array<Note> = []; // notes that can be hit
					var directionList:Array<Int> = []; // directions that can be hit
					var dumbNotes:Array<Note> = []; // notes to kill later
		 
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						{
							if (directionList.contains(daNote.noteData))
							{
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
									{ // if it's the same note twice at < 10ms distance, just delete it
										// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
										dumbNotes.push(daNote);
										break;
									}
									else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
									{ // if daNote is earlier than existing note (coolNote), replace
										possibleNotes.remove(coolNote);
										possibleNotes.push(daNote);
										break;
									}
								}
							}
							else
							{
								possibleNotes.push(daNote);
								directionList.push(daNote.noteData);
							}
						}
					});
		 
					for (note in dumbNotes)
					{
						notes.remove(note, true);
					}
		 
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		 
					var dontCheck = false;

					for (i in 0...pressArray.length)
					{
						if (pressArray[i] && !directionList.contains(i))
							dontCheck = true;
					}

					if (perfectMode)
						goodNoteHit(possibleNotes[0]);
					else if (possibleNotes.length > 0 && !dontCheck)
					{
						if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								{ // if a direction is hit that shouldn't be
									if (pressArray[shit] && !directionList.contains(shit))
										noteMiss(shit, null);
								}
						}
						for (coolNote in possibleNotes)
						{
							if (pressArray[coolNote.noteData])
							{
								if (mashViolations != 0)
									mashViolations--;
								scoreTxt.color = FlxColor.WHITE;
								goodNoteHit(coolNote);
							}
						}
					}
					else if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								if (pressArray[shit])
									noteMiss(shit, null);
						}

					if(dontCheck && possibleNotes.length > 0 && FlxG.save.data.ghost && !FlxG.save.data.botplay)
					{
						if (mashViolations > 8)
						{
							scoreTxt.color = FlxColor.RED;
							noteMiss(0,null);
						}
						else
							mashViolations++;
					}
				}
				
				notes.forEachAlive(function(daNote:Note)
				{
					if(FlxG.save.data.downscroll && daNote.y > strumLine.y ||
					!FlxG.save.data.downscroll && daNote.y < strumLine.y)
					{
						// Force good note hit regardless if it's too late to hit it or not as a fail safe
						if(FlxG.save.data.botplay && daNote.canBeHit && daNote.mustPress ||
						FlxG.save.data.botplay && daNote.tooLate && daNote.mustPress)
						{
							goodNoteHit(daNote);
								boyfriend.holdTimer = daNote.sustainLength;
						}
					}
				});
				
				if (boyfriend.holdTimer >= Conductor.stepCrochet * boyfriend.chars.singTime * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botplay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.dance();
				}
		 
				playerStrums.forEach((spr:StaticArrows) ->
				{
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm') {
					    spr.playAnim('pressed');
					}
					if (!holdArray[spr.ID]) {
					    spr.playAnim('static');
					}
				});
			}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
				gf.playAnim('sad');

			combo = 0;
			misses++;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			if (boyfriend.animation.getByName(singAnimations[daNote.noteData] + 'miss') != null)
			    boyfriend.playAnim(singAnimations[daNote.noteData] + 'miss', true);
			else
			    boyfriend.playAnim(singAnimations[daNote.noteData], true);

			#if sys
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			for (stage in stagesArray) stage.noteMiss(direction);

			updateAccuracy();
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
	
			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	*/
	function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

			note.rating = Ratings.CalculateRating(noteDiff);
			
			if (controlArray[note.noteData])
				goodNoteHit(note, (mashing > getKeyPresses(note)));
		}

		function goodNoteHit(note:Note, resetMashViolation = true):Void
			{
				if (mashing != 0)
					mashing = 0;

				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);

				// add newest note to front of notesHitArray
				// the oldest notes are at the end and are removed first
				if (!note.isSustainNote)
					notesHitArray.unshift(Date.now());

				if (!resetMashViolation && mashViolations >= 1)
					mashViolations--;

				if (mashViolations < 0)
					mashViolations = 0;

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						popUpScore(note);
						combo += 1;
					}
					else
						totalNotesHit += 1;

					var altAnim:String = "";

					if ((SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) || note.altNote)
					    altAnim = '-alt';
	
					if (!note.noAnim) {
					    if (boyfriend.animation.getByName(singAnimations[note.noteData] + altAnim) != null)
					        boyfriend.playAnim(singAnimations[note.noteData] + altAnim, true);
					    else
					        boyfriend.playAnim(singAnimations[note.noteData], true);
					}
		
					#if sys
					if (luaModchart != null)
						luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
					#end

					if(note.mustPress)
						saveNotes.push(HelperFunctions.truncateFloat(note.strumTime, 2));
					
					var strum:StaticArrows = playerStrums.members[note.noteData];
					if (strum != null) strum.playAnim('confirm', true);
					
					note.wasGoodHit = true;
					if (SONG.needsVoices) playerVocals.volume = 0.6;
		
					//note.kill();
					notes.remove(note, true);
					//note.destroy();
					
					updateAccuracy();
					for (stage in stagesArray)
					    stage.goodNoteHit(note);
					
					iconP1.scale.set(iconP1.scale.x + 0.05, iconP1.scale.y + 0.05);
				    iconP1.updateHitbox();
					callOnScripts('goodNoteHit', [notes.members.indexOf(note), note.noteData, note.isSustainNote, note.noteType]);
				}
			}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();

		#if sys
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep',curStep);
			luaModchart.executeState('stepHit',[curStep]);
		}
		#end
		switch (curSong.toLowerCase()) {
			case 'rock':
				switch (curStep) {
					case 128: defaultCamZoom = 0.65;
					case 160: defaultCamZoom = 0.70;
					case 192: defaultCamZoom = 0.75;
					case 224: defaultCamZoom = 0.80;
					case 256:
						defaultCamZoom = 0.47;
						stageJson.camBF = [-320, -200];
						stageJson.camDad = [200, 0];
					case 320: defaultCamZoom = 0.62;
					case 370: defaultCamZoom = 0.68;
					case 384: defaultCamZoom = 0.47;
					case 448: defaultCamZoom = 0.62;
					case 480: defaultCamZoom = 0.68;
					case 512:
						defaultCamZoom = 0.60;
						stageJson.camBF = [-320, -70];
						stageJson.camDad = [100, 210];
					case 640: defaultCamZoom = 0.55;
					case 768: defaultCamZoom = 0.75;
					case 896: defaultCamZoom = 0.80;
					case 1024:
						defaultCamZoom = 0.47;
						stageJson.camBF = [-320, -200];
						stageJson.camDad = [200, 0];
					case 1048: defaultCamZoom = 0.62;
					case 1056: defaultCamZoom = 0.47;
					case 1136: defaultCamZoom = 0.62;
					case 1140: defaultCamZoom = 0.64;
					case 1144: defaultCamZoom = 0.66;
					case 1148: defaultCamZoom = 0.62;
					case 1152:
						defaultCamZoom = 0.85;
						stageJson.camBF = [-320, -70];
						stageJson.camDad = [100, 210];
					case 1176: defaultCamZoom = 0.60;
					case 1184: defaultCamZoom = 0.75;
					case 1208: defaultCamZoom = 0.60;
					case 1216: defaultCamZoom = 0.85;
					case 1240: defaultCamZoom = 0.60;
					case 1248: defaultCamZoom = 0.95;
					case 1264: defaultCamZoom = 0.75;
					case 1280: defaultCamZoom = 0.60;
					case 1408: defaultCamZoom = 0.65;
					case 1440: defaultCamZoom = 0.70;
					case 1472: defaultCamZoom = 0.75;
					case 1504: defaultCamZoom = 0.80;
					case 1536: defaultCamZoom = 0.60;
					default:
				}

			case 'angru':
				switch (curStep) {
					case 128: defaultCamZoom = 0.90;
					case 256: defaultCamZoom = 0.56;
					case 272: defaultCamZoom = 0.60;
					case 288: defaultCamZoom = 0.76;
					case 304: defaultCamZoom = 0.80;
					case 320: defaultCamZoom = 0.56;
					case 336: defaultCamZoom = 0.60;
					case 352: defaultCamZoom = 0.76;
					case 364: defaultCamZoom = 0.80;
					case 368: defaultCamZoom = 0.90;
					case 384: defaultCamZoom = 0.72;
					case 508: defaultCamZoom = 0.87;
					case 510: defaultCamZoom = 0.97;
					case 512: defaultCamZoom = 0.60;
					case 640: defaultCamZoom = 0.55;
					case 672: defaultCamZoom = 0.77;
					case 704: defaultCamZoom = 0.55;
					case 736: defaultCamZoom = 0.77;
					case 768: defaultCamZoom = 0.56;
					case 784: defaultCamZoom = 0.60;
					case 800: defaultCamZoom = 0.76;
					case 816: defaultCamZoom = 0.80;
					case 832: defaultCamZoom = 0.56;
					case 848: defaultCamZoom = 0.60;
					case 864: defaultCamZoom = 0.76;
					case 876: defaultCamZoom = 0.80;
					case 880: defaultCamZoom = 0.90;
					case 896: defaultCamZoom = 0.70;
					case 1024: defaultCamZoom = 0.55;
					default:
				}

			case 'smas':
				switch (curStep) {
					case 64: 
						defaultCamZoom = 0.55;
						drainHealth = true;
					case 320: defaultCamZoom = 0.65;
					case 440:
						// Jumpscare HERE
						// Boo
					case 576: defaultCamZoom = 0.85;
					case 832: defaultCamZoom = 0.95;
					case 1087: defaultCamZoom = 0.65;
					case 1208:
						// Jumpscare HERE
						// Nuh uh ~ Idklool
					case 1344: defaultCamZoom = 0.55;
					case 1376: defaultCamZoom = 0.65;
					case 1408: defaultCamZoom = 0.75;
					case 1440: defaultCamZoom = 0.85;
					case 1472: defaultCamZoom = 0.55;
					case 1504: defaultCamZoom = 0.65;
					case 1536: defaultCamZoom = 0.75;
					case 1568: defaultCamZoom = 0.85;
					case 1600: defaultCamZoom = 0.55;
					case 1856: defaultCamZoom = 0.60;
					default:
				}

			default:
		}
	

		for (stage in stagesArray)
		    stage.stepHit(curStep);
		callOnScripts('stepHit', []);
		setOnScripts('curStep', curStep+1);

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC,true,  songLength - Conductor.songPosition);
		#end
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
			notes.sort(FlxSort.byY, (FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
			
		if (SONG.notes[Std.int(curStep / 16)] != null)
		{
		    setOnScripts('mustHitSection', SONG.notes[Std.int(curStep / 16)].mustHitSection);
		    setOnScripts('cameraRightSide', SONG.notes[Std.int(curStep / 16)].mustHitSection);
		}
		setOnScripts('defaultCamZoom', defaultCamZoom);

		// Make sure Girlfriend cheers only for certain songs
			if(allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if(gf.animation.curAnim.name.startsWith('dance') || gf.animation.curAnim.name.startsWith('idle'))
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch(curSong)
					{
						case 'Philly':
						{
							// General duration of the song
							if(curBeat < 250)
							{
								// Beats to skip or to stop GF from cheering
								if(curBeat != 184 && curBeat != 216)
								{
									if(curBeat % 16 == 8)
									{
										// Just a garantee that it'll trigger just once
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Bopeebo':
						{
							// Where it starts || where it ends
							if(curBeat > 5 && curBeat < 130)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
						case 'Blammed':
						{
							if(curBeat > 30 && curBeat < 190)
							{
								if(curBeat < 90 || curBeat > 128)
								{
									if(curBeat % 4 == 2)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Cocoa':
						{
							if(curBeat < 170)
							{
								if(curBeat < 65 || curBeat > 130 && curBeat < 145)
								{
									if(curBeat % 16 == 15)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Eggnog':
						{
							if(curBeat > 10 && curBeat != 111 && curBeat < 220)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
					}
				}
			}

		for (stage in stagesArray)
		    stage.beatHit(curBeat);

		#if sys
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat',curBeat);
			luaModchart.executeState('beatHit',[curBeat]);
		}
		#end

		var leChars:Array<Character> = [boyfriend, dad, gf];

		for (char in leChars) {
		    if (char != null && (curBeat % char.dancePerBeat == 0 &&
		    (char.animation.curAnim != null && !char.animation.name.startsWith('sing'))))
		        char.dance();
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
		
		if (curSong.toLowerCase() == 'smas' && curBeat >= 16 && curBeat < 144 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
		
		if (curSong.toLowerCase() == 'smas' && curBeat >= 272 && curBeat < 400 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % zoomPerBeat == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		/*if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			boyfriend.playAnim('hey', true);*/

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				boyfriend.playAnim('hey', true);
				dad.playAnim('cheer', true);
			}

			callOnScripts('beatHit', []);
		  setOnScripts('curBeat', curBeat+1);
	}

		public function addCharacterToList(newCharacter:String, name:String) {
	    switch(name) {
	        case 'boyfriend' | 'bf':
	            if(!bfMap.exists(newCharacter)) {
	                var newBF:Boyfriend = new Boyfriend(0, 0, newCharacter);
	                bfMap.set(newCharacter, newBF);
	                newBF.x += newBF.chars.pos[0];
	                newBF.y += newBF.chars.pos[1];
	                newBF.alpha = 0.001;
	                bfGroup.add(newBF);
	            }

	        case 'dad' | 'opponent':
	            if(!dadMap.exists(newCharacter)) {
	                var newDad:Character = new Character(0, 0, newCharacter);
	                dadMap.set(newCharacter, newDad);
	                newDad.x += newDad.chars.pos[0];
	                newDad.y += newDad.chars.pos[1];
	                newDad.alpha = 0.001;
	                dadGroup.add(newDad);
	            }

	        case 'girlfriend' | 'gf':
	            if(gf != null && (!gfMap.exists(newCharacter))) {
	                var newGF:Character = new Character(0, 0, newCharacter);
	                gfMap.set(newCharacter, newGF);
	                newGF.scrollFactor.set(0.95, 0.95);
	                newGF.x += newGF.chars.pos[0];
	                newGF.y += newGF.chars.pos[1];
	                newGF.alpha = 0.001;
	                gfGroup.add(newGF);
	            }
	    }
	}
	public function changeCharacter(name:String, newChar:String) {
	    var daAlpha:Float;
	    switch (name.toLowerCase())
	    {
	        case 'boyfriend' | 'bf':
	            if (boyfriend.curCharacter != newChar)
	            {
	                  if (!bfMap.exists(newChar))
	                      addCharacterToList(newChar, name);
				                
	                  daAlpha = boyfriend.alpha;
	                  boyfriend.alpha = 0.001;
	                  boyfriend = bfMap.get(newChar);
	                  boyfriend.alpha = daAlpha;
	                  iconP1.changeIcon(boyfriend.chars.icon);
	            }
	        case 'dad' | 'opponent':
	            if (dad.curCharacter != newChar)
	            {
	                if (!dadMap.exists(newChar))
	                    addCharacterToList(newChar, name);
						
	                daAlpha = dad.alpha;
					        dad.alpha = 0.001;
					        dad = dadMap.get(newChar);
					        dad.alpha = daAlpha;
					        iconP2.changeIcon(dad.chars.icon);
	            }
	        case 'girlfriend' | 'gf':
	            if (gf != null) 
	            {
	                if (gf.curCharacter != newChar)
	                {
	                    if (!gfMap.exists(newChar)) 
	                        addCharacterToList(newChar, name);

	                    daAlpha = gf.alpha;
	                    gf.alpha = 0.001;
	                    gf = gfMap.get(newChar);
	                    gf.alpha = daAlpha;
	                }
	            }
		}
		healthBar.createFilledBar(FlxColor.fromRGB(dad.chars.healthColor[0], dad.chars.healthColor[1], dad.chars.healthColor[2]), FlxColor.fromRGB(boyfriend.chars.healthColor[0], boyfriend.chars.healthColor[1], boyfriend.chars.healthColor[2]));
		healthBar.updateFilledBar();
	}
	public function callOnScripts(name:String, ?args:Array<Dynamic>):Dynamic
  {
      var value:Dynamic = null;
      for (i in 0...HScriptArray.length)
      {
          var newValue:Dynamic = HScriptArray[i].call(name, args);
          if (newValue != null) value = newValue;
      }
      return value;
  }
	public function setOnScripts(variable:String, arg:Dynamic)
	{
	    for (i in 0...HScriptArray.length) HScriptArray[i].set(variable, arg);
	}
}
