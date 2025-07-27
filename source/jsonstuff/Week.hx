package jsonstuff;

import openfl.utils.Assets;
import haxe.Json;

typedef WeekJson =
{
	var songs:Array<String>;
	var characters:Array<String>;
	var storyName:String;
	var ?locked:Bool;
	var ?unlockAfter:String;
	var ?hide:Bool; // Não pretendo usar no freeplay
	/*var colors:Array<Int>;
	var icon:String;*/
	var ?difficulties:Array<String>;
}

class Week
{
	public static var curloadedWeeks:Map<String, WeekJson> = [];
	public static var weekList:Array<String> = [];

	public static function loadWeeks()
	{
		curloadedWeeks.clear();
		weekList = [];

		var list:Array<String> = CoolUtil.coolTextFile('assets/weeks/weekList.txt');
		for (i in 0...list.length)
		{
			var folderToCheck:String = 'assets/weeks/' + list[i] + '.json';
			if (!curloadedWeeks.exists(list[i]))
			{
				var week:WeekJson = getWeek(folderToCheck);
				if (week != null && !week.hide)
				{
				    curloadedWeeks.set(list[i], week);
						weekList.push(list[i]);
				}
			}
		}
	}

	public static function getWeek(path:String):WeekJson
	{
		var rawJson:String = null;
		if (Util.exists(path))
			rawJson = Util.getContent(path);

		if (rawJson != null && rawJson.length > 0)
			return Json.parse(rawJson);

		return null;
	}
}