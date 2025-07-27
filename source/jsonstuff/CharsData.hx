package jsonstuff;

typedef CharData = {
  var frame:String;
  var anims:Array<AnimData>;
  var offsets:Map<String, Array<Float>>;
  var ?antialiasing:Bool;
  var ?flipX:Bool;
  var size:Float;
  var icon:String;
  var ?healthColor:Array<Int>;
  var ?pos:Array<Float>;
  var ?camPos:Array<Float>;
  var ?singTime:Float;
  var ?danceLeftandRight:Bool;
}

typedef AnimData = {
  var name:String;
  var prefix:String;
  var ?indices:Array<Int>;
  var fps:Int;
  var loop:Bool;
}