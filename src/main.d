/*
 * main.d: CLI entry point
 */

//TODO: "Dynamic memory", allocate only what's necessary.
//TODO: -c "command" -- Executes a command on launch (ScriptHost.d)

module main;

import core.stdc.stdio;
import std.getopt;
import dd_dos : APP_VERSION, APP_NAME, BANNER, EnterVShell;
import Interpreter : Initiate, Verbose, Sleep, Run;
import Loader : LoadExec;
import Logger;
import ddcon : InitConsole;

debug {} else {
    extern (C) __gshared bool // Defaults to false anyway
        rt_envvars_enabled, rt_cmdline_enabled;
}

extern (C)
private void DisplayVersion()
{
    import core.stdc.stdlib : exit;
	printf("%s v%s  (%s)\n",
        cast(char*)APP_NAME, cast(char*)APP_VERSION, cast(char*)__TIMESTAMP__);
    puts("Copyright (c) 2017 dd86k, using MIT license");
	puts("Project page: <https://github.com/dd86k/dd-dos>");
    printf("Compiled %s using %s v%d\n",
        cast(char*)__FILE__, cast(char*)__VENDOR__, __VERSION__);
    exit(0); // getopt hack ;-)
}

extern (C)
private void DisplayHelp()
{
    puts("A mini DOS virtual machine.");
    puts("Usage:");
    puts("  dd-dos  [OPTIONS]");
}

/**
 * Main entry point.
 * Params: args = CLI Arguments
 * Returns: Errorcode
 */
int main(string[] args) {
	//TODO: Deprecate init_args?
    string init_file, init_args;
    bool smsg; // Startup message

    GetoptResult r;
	try {
		r = getopt(args,
            config.caseSensitive,
            "p|program", "Run a program directly", &init_file,
            config.caseSensitive,
            "a|args", "Add arguments to -p", &init_args,
            config.bundling, config.caseSensitive,
            "P|perf", "Do not sleep between cycles (!)", &Sleep,
            config.bundling, config.caseSensitive,
            "N|nobanner", "Removes starting message and banner", &smsg,
            config.bundling, config.caseSensitive,
			"V|verbose", "Set verbose mode", &Verbose,
            config.caseSensitive,
            "v|version", "Print version", &DisplayVersion);
	} catch (GetOptException ex) {
		//stderr.writeln("Error: ", ex.msg);
        printf("ERROR: %s\n", cast(char*)ex.msg);
        return 1;
	}

    if (r.helpWanted) {
        DisplayHelp;
        puts("\nOPTIONS (All defaults: Off)");
        foreach (it; r.options) {
            // "custom" and nicer defaultGetoptPrinter
            printf("%*s, %-*s %s\n",
                4,  cast(char*)it.optShort,
                12, cast(char*)it.optLong,
                cast(char*)it.help);
        }
        return 0;
	}

    // The "blame getopt for only doing off to on switches" section
    Sleep = !Sleep;
    debug Verbose = !Verbose;

    if (Verbose) {
        debug log("Debug mode is ON");
		else log("Verbose mode is ON");
		if (!Sleep)
			log("Maximum performance is ACTIVE");
	}

    if (!smsg)
		puts("DD-DOS is starting...");

    InitConsole; // Initiates console screen (ddcon)
    Initiate; // Initiates vcpu

    if (!smsg)
		puts(BANNER); // Defined in dd_dos.d

    if (init_file) {
        if (LoadExec(init_file, init_args)) Run; // vcpu already initiated
    } else {
        EnterVShell;
    }

    return 0;
}