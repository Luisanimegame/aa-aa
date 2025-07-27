package idk;
import hscript.Parser;
import hscript.Interp;
import openfl.utils.Assets;

class Script {
    public var parser:Parser;
    public var interp:Interp;
    
    public function new(script:String)
    {
        interp = new Interp();
        parser = new Parser();
        parser.allowJSON = parser.allowTypes = parser.allowMetadata = true;
        preset();
        interp.execute(parser.parseString(Assets.getText(script)));
    }

    public function preset()
    {
        set('Date', Date);
        set('DateTools', DateTools);
        set('Math', Math);
        set('Reflect', Reflect);
        set('Std', Std);
        set('StringTools', StringTools);
        set('Type', Type);
        set('Assets', Assets);
        set('FlxColor', idk.utils.ColorUtil);
    }

    public function call(func:String, ?args:Array<Dynamic>)
    {
        if (interp.variables.exists(func))
        {
            try
            {
                return args == null ? [] : Reflect.callMethod(null, get(func), args);
            }
            catch (e:Dynamic)
                openfl.Lib.application.window.alert(e, "HScript Error!");
        }
        return null;
    }
    
    function setClassVars(obj:Dynamic, ?functions:Bool)
    {
        if (interp.classObjects == null) interp.classObjects = []; // Melhor prevenir do que remediar
        interp.classObjects.push(obj);
    }
    public function get(id:String)
    {
        return interp.variables.get(id);
    }
    public function set(id:String, obj:Dynamic)
    {
        interp.variables.set(id, obj);
    }
    public function exists(id:String)
    {
        return interp.variables.exists(id);
    }
}