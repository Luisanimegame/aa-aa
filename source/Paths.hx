package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.media.Sound;
import flixel.graphics.FlxGraphic;
import lime.utils.Assets;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;
	
	public static var trackedAssets:Map<String, FlxGraphic> = [];
	public static var trackedSounds:Map<String, Sound> = [];

	public static var localTrackedAssets:Array<String> = [];

	public static function clearUnusedMemory() {
		for (key in trackedAssets.keys()) {
			if (key != null && !localTrackedAssets.contains(key)) {
				FlxG.bitmap.removeByKey(key);
				Assets.cache.clear(key);
				trackedAssets.get(key).destroy();
				trackedAssets.remove(key);
			}
		}
		for (key in trackedSounds.keys()) {
			if (key != null && !localTrackedAssets.contains(key)) {
				Assets.cache.clear(key);
				trackedSounds.remove(key);
			}
		}
		openfl.system.System.gc();
	}
	
	public static function clearStoredMemory() {
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
			if (!trackedAssets.exists(key))
			    FlxG.bitmap.removeByKey(key);
		localTrackedAssets = [];
	}

	static public function setCurrentLevel(name:String)
		currentLevel = name.toLowerCase();

	static public function getPath(file:String, ?type:AssetType, ?library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
		return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library);

	inline static function getLibraryPathForce(file:String, library:String)
		return '$library:assets/$library/$file';

	inline static function getPreloadPath(file:String)
		return 'assets/$file';

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
		return getPath(file, type, library);

	inline static public function lua(key:String,?library:String)
		return getPath('data/$key.lua', TEXT, library);

	inline static public function luaImage(key:String, ?library:String)
		return getPath('data/$key.png', IMAGE, library);

	inline static public function txt(key:String, ?library:String)
		return getPath('data/$key.txt', TEXT, library);

	inline static public function xml(key:String, ?library:String)
		return getPath('data/$key.xml', TEXT, library);

	inline static public function json(key:String, ?library:String)
		return getPath('data/$key.json', TEXT, library);

	static public function sound(key:String, ?library:String):Sound
		return returnSongFile('sounds', key, library);

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
		return sound(key + FlxG.random.int(min, max), library);

	inline static public function music(key:String, ?library:String)
		return returnSongFile('music', key, library);

	inline static public function getSongFile(song:String, type:String, ?character:String, ?diff:String = ''):Any {
        var diffLower = diff.toLowerCase();
        var charLower = character.toLowerCase();

        var songPath = 'assets/songs/' + spaceToDash(song) + '/' + type;

        var ext = '';
        if (Assets.exists(songPath + '-${diffLower}.$SOUND_EXT'))
            ext = '-${diffLower}';
        if (Assets.exists(songPath + '-${charLower}-${diffLower}.$SOUND_EXT'))
            ext = '-${charLower}-${diffLower}';

            if (diffLower == 'nightmare') {
                var nightmareExists = Assets.exists(songPath + '-nightmare.$SOUND_EXT');
                var erectExists = Assets.exists(songPath + '-erect.$SOUND_EXT');

                if (!nightmareExists && erectExists)
                    ext = '-erect';
            }

            return returnSongFile('songs', spaceToDash(song) + '/' + type + ext);
    }

    inline static public function voices(song:String, ?char:String, ?diff:String = ''):Any
        return getSongFile(song, 'Voices', char, diff);

    inline static public function inst(song:String, ?diff:String = ''):Any
        return getSongFile(song, 'Inst', '', diff);

	inline static public function video(key:String)
	    return Asset2File.getPath('assets/videos/$key.mp4');

	inline static public function spaceToDash(str:String)
	  return str.replace(' ', '-').toLowerCase();

	inline static public function image(key:String, ?library:String):FlxGraphic
		return returnGraphic(key, library);

	inline static public function font(key:String)
		return 'assets/fonts/$key';

	inline static public function getSparrowAtlas(key:String, ?library:String)
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));

	inline static public function getPackerAtlas(key:String, ?library:String)
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));

		public static function returnGraphic(key:String, ?library:String)
	{
	  var path = getPath('images/$key.png', IMAGE, library);
	  if (OpenFlAssets.exists(path, IMAGE))
	  {
	          if (!trackedAssets.exists(path)) {
	                var leGraphic:FlxGraphic = FlxGraphic.fromBitmapData(OpenFlAssets.getBitmapData(path), false, path);
	                leGraphic.persist = true;
	                trackedAssets.set(path, leGraphic);
	          }
	          localTrackedAssets.push(path);
	          return trackedAssets.get(path);
	  }
	  return null;
	}
	  
	public static function returnSongFile(path:String, key:String, ?library:String)
	{
		var daPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		if (OpenFlAssets.exists(daPath, SOUND))
		{
			if (!trackedSounds.exists(daPath))
				trackedSounds.set(daPath, OpenFlAssets.getSound(daPath));
		    
			localTrackedAssets.push(daPath);
			return trackedSounds.get(daPath);
		}
		return null;
	}
}