package;
#if sys
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
import haxe.CallStack;

using StringTools;

class CrashHandler {
    public static function initialize():Void {
        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleCrash);
    }

    private static function handleCrash(event:UncaughtErrorEvent):Void {
        var errorMessage:String = createErrorMessage(event.error);
        var crashReportPath:String = generateCrashReportPath();

        #if !mobile
        if (!FileSystem.exists("crash/")) {
            FileSystem.createDirectory("crash/");
        }

        File.saveContent(crashReportPath, errorMessage);
        #end

        Sys.println(errorMessage);
        Sys.println("Crash report saved at: " + crashReportPath);

        Application.current.window.alert(createErrorMessage(event.error), "Error!");

        Sys.exit(1);
    }

    private static function createErrorMessage(error:Dynamic):String {
        var message:String = "An unexpected error has occurred:\n";
        message += "Error: " + error + "\n";

        var callStack:Array<StackItem> = CallStack.exceptionStack(true);
        message += "Call Stack:\n";

        for (stackItem in callStack) {
            switch (stackItem) {
                case FilePos(s, file, line, column):
                    message += "  at " + file + " (line " + line + ")\n";
                default:
                    Sys.println("Unexpected stack item: " + stackItem);
            }
        }

        message += "If you are using an unmodified version, please report this error to the dev(s).";
        return message;
    }

    private static function generateCrashReportPath():String {
        var timestamp:String = Date.now().toString().replace(" ", "_").replace(":", "'");
        return "crash/Crash_" + timestamp + ".txt";
    }
}
#end