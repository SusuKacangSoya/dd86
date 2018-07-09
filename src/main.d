/*
 * main.d: CLI entry point
 */

import core.stdc.stdio;
import core.stdc.string : strcmp;
import vdos, vdos_codes;
import vcpu;
import vdos_loader : ExecLoad;
import Logger;
import ddcon : InitConsole;
import utils_os : pexist;

extern (C)
private void _version() {
	printf(
		"Copyright (c) 2017-2018 dd86k, MIT license\n" ~
		"Project page: <https://github.com/dd86k/dd-dos>\n\n" ~
		"dd-dos " ~ APP_VERSION ~ "  (" ~ __TIMESTAMP__ ~ ")\n" ~
		"Compiler: " ~ __VENDOR__ ~ " v%d\n\n" ~
		`Credits
dd86k -- Original author and developer

`,
		__VERSION__
	);
}

// TODO:
// - a "no video" mode switch

extern (C)
private void help() {
	puts(
`A DOS virtual machine and emulation layer
USAGE
	dd-dos [-vPN] [FILE [FILEARGS]]
	dd-dos {-V|--version|-h|--help}

OPTIONS
	-P	Do not sleep between cycles
	-N	Remove starting messages and banner
	-v	Increase verbosity level
	-V, --version  Print version screen, then exit
	-h, --help     Print help screen, then exit
`
	);
}

extern (C)
private int main(int argc, char** argv) {
	byte args = 1;
	byte arg_banner = 1;
	char* prog; /// FILE, COM or EXE to start
//	char* args; /// FILEARGS, MUST not be over 127 characters
//	size_t arg_i; /// Argument length incrementor

	// Pre-boot / CLI

	while (--argc >= 1) {
		++argv;
		if (args) {
			if (*(*argv + 1) == '-') { // long arguments
				char* a = *(argv) + 2;
				if (strcmp(a, "help") == 0) {
					help;
					return 0;
				}
				if (strcmp(a, "version") == 0) {
					_version;
					return 0;
				}

				printf("Unknown parameter: --%s\n", a);
				return E_INVALID_FUNCTION;
			} else if (**argv == '-') { // short arguments
				char* a = *argv;
				while (*++a) {
					switch (*a) {
					case 'P': --opt_sleep; break;
					case 'N': --arg_banner; break;
					case 'v': ++Verbose; break;
					case '-': --args; break;
					case 'h': help; return 0;
					case 'V': _version; return 0;
					default:
						printf("Unknown parameter: -%c\n", *a);
						return E_INVALID_FUNCTION;
					}
				}
				continue;
			}
		}

		if (cast(int)prog == 0)
			prog = *argv;
		//TODO: Else, append program arguments (strcmp)
		//      Don't forget to null it after while loop, keep arg_i updated
	}

	switch (Verbose) {
	case LOG_SILENCE, LOG_CRIT, LOG_ERROR: break;
	case LOG_WARN: info("-- Log level: LOG_WARN"); break;
	case LOG_INFO: info("-- Log level: LOG_INFO"); break;
	case LOG_DEBUG: info("-- Log level: LOG_DEBUG"); break;
	default:
		printf("E: Unknown log level: %d\n", Verbose);
		return E_INVALID_FUNCTION;
	}

	if (opt_sleep == 0)
		info("-- SLEEP MODE OFF");

	if (arg_banner)
		puts("DD-DOS is starting...");

	// Initiation

	InitConsole; // ddcon
	vcpu_init; // vcpu
	//vdos_init; // vdos

	// DD-DOS

	if (arg_banner)
		puts(BANNER); // Defined in vdos.d

	if (cast(int)prog) {
		if (pexist(prog)) {
			CS = 0; IP = 0x100; // Temporary
			if (ExecLoad(prog)) {
				puts("E: Could not load executable");
				return PANIC_FILE_NOT_LOADED;
			}
			vcpu_run;
		} else {
			puts("E: File not found or loaded");
			return E_FILE_NOT_FOUND;
		}
	} else EnterShell;

	return 0;
}