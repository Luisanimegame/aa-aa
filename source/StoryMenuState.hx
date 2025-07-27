package;

#if discord_rpc
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import jsonstuff.Week;

using StringTools;

class StoryMenuState extends MusicBeatState {
    var scoreText:FlxText;
    var loadedWeeks:Array<WeekJson> = [];
    public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

    static var curDifficulty:Int = 1;
    static var curWeek:Int = 0;

    var txtWeekTitle:FlxText;
    var txtTracklist:FlxText;

    var grpWeekText:FlxTypedGroup<MenuItem>;
    var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
    var grpLocks:FlxTypedGroup<FlxSprite>;

    var difficultySelectors:FlxGroup;
    var sprDifficulty:FlxSprite;
    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;

    override function create() {
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        Week.loadWeeks();
        loadedWeeks = [];

        if (FlxG.sound.music != null && !FlxG.sound.music.playing)
            FlxG.sound.playMusic(Paths.music('freakyMenu'));

        persistentUpdate = persistentDraw = true;

        scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
        scoreText.setFormat("VCR OSD Mono", 32);

        txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
        txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
        txtWeekTitle.alpha = 0.7;

        var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
        var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

        grpWeekText = new FlxTypedGroup<MenuItem>();
        add(grpWeekText);

        add(new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK));

        grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();
        grpLocks = new FlxTypedGroup<FlxSprite>();
        add(grpLocks);

        #if discord_rpc
        // Updating Discord Rich Presence
        DiscordClient.changePresence("In the Menus", null);
        #end

        for (i in 0...Week.weekList.length) {
            var isLocked:Bool = weekIsLocked(Week.weekList[i]);
            if (!isLocked) {
                loadedWeeks.push(Week.curloadedWeeks.get(Week.weekList[i]));
                var weekItem:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, Week.weekList[i]);
                weekItem.y += ((weekItem.height + 20) * i);
                weekItem.targetY = i;
                grpWeekText.add(weekItem);

                weekItem.screenCenter(X);
                weekItem.antialiasing = true;

                if (isLocked) {
                    var lock:FlxSprite = new FlxSprite(weekItem.width + 10 + weekItem.x);
                    lock.frames = ui_tex;
                    lock.animation.addByPrefix('lock', 'lock');
                    lock.animation.play('lock');
                    lock.ID = i;
                    lock.antialiasing = true;
                    grpLocks.add(lock);
                }
            }
        }

        for (char in 0...3) {
            var weekCharacter:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, loadedWeeks[0].characters[char]);
            weekCharacter.y += 70;
            weekCharacter.antialiasing = true;
            grpWeekCharacters.add(weekCharacter);
        }

        difficultySelectors = new FlxGroup();
        add(difficultySelectors);

        leftArrow = createArrow(ui_tex, "arrow left", "arrow push left", grpWeekText.members[0].x + grpWeekText.members[0].width + 10);
        difficultySelectors.add(leftArrow);

        sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
        changeDifficulty();
        difficultySelectors.add(sprDifficulty);

        rightArrow = createArrow(ui_tex, 'arrow right', 'arrow push right', sprDifficulty.x + 250);
        difficultySelectors.add(rightArrow);

        add(yellowBG);
        add(grpWeekCharacters);

        txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
        txtTracklist.alignment = CENTER;
        txtTracklist.font = Paths.font("vcr.ttf");
        txtTracklist.color = 0xFFe55777;
        add(txtTracklist);
        add(scoreText);
        add(txtWeekTitle);

        updateText();

        #if mobile addVPad(FULL, A_B); #end

        super.create();
    }

    override function update(elapsed:Float) {
        lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.5);
        scoreText.text = "WEEK SCORE: " + Math.round(lerpScore);
        txtWeekTitle.text = loadedWeeks[curWeek].storyName.toUpperCase();
        txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
        difficultySelectors.visible = !weekIsLocked(Week.weekList[curWeek]);

        grpLocks.forEach((lock:FlxSprite) -> lock.y = grpWeekText.members[lock.ID].y);

        if (!movedBack) {
            if (!selectedWeek) {
                if (controls.UP_P || controls.DOWN_P) changeWeek((controls.UP_P) ? -1 : 1);
                rightArrow.animation.play((controls.RIGHT) ? 'press' : 'idle');
                leftArrow.animation.play((controls.LEFT) ? 'press' : 'idle');
                if (controls.RIGHT_P || controls.LEFT_P) changeDifficulty((controls.RIGHT_P) ? 1 : -1);
            }

            if (controls.ACCEPT) selectWeek();
        }

        if (controls.BACK && !movedBack && !selectedWeek) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            movedBack = true;
            FlxG.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }

    override function closeSubState() {
        persistentUpdate = true;
        changeWeek();
        super.closeSubState();
    }

    var movedBack:Bool = false;
    var selectedWeek:Bool = false;
    var stopspamming:Bool = false;

    function selectWeek() {
        if (!weekIsLocked(Week.weekList[curWeek])) {
            if (!stopspamming) {
                FlxG.sound.play(Paths.sound('confirmMenu'));
                if (FlxG.save.data.flashing) grpWeekText.members[curWeek].startFlashing();
                for (i in 0...grpWeekCharacters.length)
                    if (grpWeekCharacters.members[i].animation.getByName('confirm') != null && grpWeekCharacters.members[i].animation.curAnim.name != '')
                        grpWeekCharacters.members[i].animation.play('confirm');
                stopspamming = true;
            }

            PlayState.storyPlaylist = loadedWeeks[curWeek].songs;
            PlayState.isStoryMode = true;
            selectedWeek = true;
            PlayState.storyDifficulty = CoolUtil.defaultDiff.toUpperCase();

            var difficultySuffix = CoolUtil.defaultDiff != 'normal' ? '-' + CoolUtil.defaultDiff.toLowerCase() : "";
            PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficultySuffix, PlayState.storyPlaylist[0]);
            PlayState.storyWeek = curWeek;
            PlayState.campaignScore = 0;
            new FlxTimer().start(1, (tmr:FlxTimer) -> LoadingState.loadAndSwitchState(new PlayState(), true));
        }
    }

    function changeDifficulty(change:Int = 0):Void {
        curDifficulty += change;

        if (curDifficulty < 0) curDifficulty = CoolUtil.difficultyArray.length - 1;
        if (curDifficulty >= CoolUtil.difficultyArray.length) curDifficulty = 0;

        CoolUtil.defaultDiff = CoolUtil.difficultyArray[curDifficulty];
        
        var diffImage:flixel.graphics.FlxGraphic = Paths.image('difficulties/' + Paths.spaceToDash(CoolUtil.difficultyArray[curDifficulty]));
        if (sprDifficulty.graphic != diffImage)
        {
            sprDifficulty.loadGraphic(diffImage);
            sprDifficulty.x = leftArrow.x + 130;
            sprDifficulty.y = leftArrow.y - 15;
            sprDifficulty.alpha = 0;
            FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
        }

        switch (curDifficulty) {
            case 0: sprDifficulty.animation.play('easy'); sprDifficulty.offset.x = 20;
            case 1: sprDifficulty.animation.play('normal'); sprDifficulty.offset.x = 70;
            case 2: sprDifficulty.animation.play('hard'); sprDifficulty.offset.x = 20;
        }

        intendedScore = Highscore.getWeekScore(Week.weekList[curWeek], CoolUtil.defaultDiff);
    }

    var lerpScore:Float = 0;
    var intendedScore:Int = 0;

    function changeWeek(change:Int = 0):Void {
        curWeek += change;

        if (curWeek >= loadedWeeks.length) curWeek = 0;
        if (curWeek < 0) curWeek = loadedWeeks.length - 1;

        var bullShit:Int = 0;

        for (item in grpWeekText.members) {
            item.targetY = bullShit - curWeek;
            item.alpha = (item.targetY == 0 && !weekIsLocked(Week.weekList[curWeek])) ? 1 : 0.6;
            bullShit++;
        }

        CoolUtil.difficultyArray = (loadedWeeks[curWeek].difficulties != null && loadedWeeks[curWeek].difficulties != []) ? loadedWeeks[curWeek].difficulties : ['Easy', 'Normal', 'Hard'];

        changeDifficulty();

        FlxG.sound.play(Paths.sound('scrollMenu'));
        updateText();
    }

    function weekIsLocked(name:String):Bool {
        var week:WeekJson = Week.curloadedWeeks.get(name);
        return (week.locked && week.unlockAfter.length > 0 && (!weekCompleted.exists(week.unlockAfter)));
    }

    function updateText() {
        var week:WeekJson = loadedWeeks[curWeek];
        for (i in 0...grpWeekCharacters.length) {
            if (grpWeekCharacters.members[i].character != week.characters[i]) {
                grpWeekCharacters.members[i].changeCharacter(week.characters[i]);
            }
        }

        txtTracklist.text = "Tracks\n";
        var stringThing = loadedWeeks[curWeek].songs;

        for (i in stringThing)
            txtTracklist.text += '\n' + i;

        txtTracklist.text = txtTracklist.text.toUpperCase();
        txtTracklist.screenCenter(X);
        txtTracklist.x -= FlxG.width * 0.35;
        txtTracklist.text += "\n";

        intendedScore = Highscore.getWeekScore(Week.weekList[curWeek], CoolUtil.defaultDiff);
    }

    private function createArrow(ui_tex:Dynamic, idlePrefix:String, pressPrefix:String, xPos:Float):FlxSprite {
        var arrow:FlxSprite = new FlxSprite(xPos, grpWeekText.members[0].y + 10);
        arrow.frames = ui_tex;
        arrow.animation.addByPrefix('idle', idlePrefix);
        arrow.animation.addByPrefix('press', pressPrefix);
        arrow.animation.play('idle');
        return arrow;
    }
}