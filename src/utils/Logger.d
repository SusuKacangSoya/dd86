module Logger;

import core.stdc.stdio;
import std.string : format;

//TODO: Consider "coredump" of somekind for critical messages (and exit(0))

/// Log levels, see documentation for more details.
enum Log {
	Debug,       /// Debugging information
	Information, /// Informational
	Warning,     /// Warnings
	Error,       /// Errors
	Critical     /// Critical messages (could not continue)
}

//TODO: Better logging module
/+
extern (C)
void _log()

extern (C)
void log_TEST(
	string f, int t = null, int level = Log.Information, char* src = cast(char*)__MODULE__) {
	/*import core.stdc.stdarg;
	va_list args;
	va_start(args, level);
	size_t i;
	if (_arguments[i] == typeid(double)) {

	}*/
	//vsprintf(

	debug printf("%s::", src);
	/*char[256] b;
	vsprintf(cast(char*)b, f, args);*/

	//va_end(args);
}+/

/// Log a simple message
void log(string msg, int level = Log.Information, char* src = cast(char*)__MODULE__)
{
	debug printf("%s:", src);

	final switch (level) {
	case Log.Debug:
		printf("[ ~~ ] %s\n", cast(char*)msg);
		break;
	case Log.Information:
		printf("[INFO] %s\n", cast(char*)msg);
		break;
	case Log.Warning:
		printf("[WARN] %s\n", cast(char*)msg);
		break;
	case Log.Error:
		printf("[ERR ] %s\n", cast(char*)msg);
		break;
	case Log.Critical:
		printf("[ !! ] %s\n", cast(char*)msg);
		break;
	}

	//TODO: Log in file when enabled
}

/// Log string
void logs(string msg, string v, int level = Log.Information, char* src = cast(char*)__MODULE__)
{
	// As much as I would of liked avoiding using the GC..
	log(format("%s%s", msg, v), level, src);
}

/// Log hex byte
void loghb(string msg, ubyte op, int level = Log.Information, char* src = cast(char*)__MODULE__)
{
	log(format("%s%02X\0", msg, op), level, src);
}

/// Log decimal
void logd(string msg, long op, int level = Log.Information, char* src = cast(char*)__MODULE__)
{
	log(format("%s%d\0", msg, op), level, src);
}

void logexec(string msg, uint addr, ubyte op, char* src = cast(char*)__MODULE__)
{
	log(format("%s%8X  %02Xh\0", msg, addr, op), Log.Debug, src);
}