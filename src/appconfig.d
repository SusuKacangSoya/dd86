/**
 * appconfig: DD-DOS compilation configuration settings and messages
 *
 * Pragmas of type msg are only allowed here.
 */
module appconfig;

import os.sleep : SLEEP_TIME;
import vdos.os : BANNER, DOS_MAJOR_VERSION, DOS_MINOR_VERSION;
import vdos.structs;

pragma(msg, BANNER);

debug {
	pragma(msg, "[DEBUG]\tON");
	enum BUILD_TYPE = "DEBUG";	/// For printing purposes
} else {
	pragma(msg, "[DEBUG]\tOFF");
	enum BUILD_TYPE = "RELEASE";	/// For printing purposes
}

pragma(msg, "[DOS]\tDD-DOS version: ", APP_VERSION);
pragma(msg, "[DOS]\tMS-DOS version: ", DOS_MAJOR_VERSION, ".", DOS_MINOR_VERSION);

version (BigEndian) pragma(msg,
`WARNING: DD-DOS has not been tested on big-endian platforms!
You might want to run 'dub test' beforehand to check if everything is OK.
`);

version (CRuntime_Bionic) {
	pragma(msg, "[RUNTIME]\tBionic");
	enum C_RUNTIME = "Bionic";
} else version (CRuntime_DigitalMars) {
	pragma(msg, "[RUNTIME]\tDigitalMars");
	enum C_RUNTIME = "DigitalMars";
} else version (CRuntime_Glibc) {
	pragma(msg, "[RUNTIME]\tGlibc");
	enum C_RUNTIME = "Glibc";
} else version (CRuntime_Microsoft) {
	pragma(msg, "[RUNTIME]\tMicrosoft");
	enum C_RUNTIME = "Microsoft";
} else version(CRuntime_Musl) {
	pragma(msg, "[RUNTIME]\tmusl");
	enum C_RUNTIME = "musl";
} else version (CRuntime_UClibc) {
	pragma(msg, "[RUNTIME]\tuClibc");
	enum C_RUNTIME = "uClibc";
} else {
	pragma(msg, "[RUNTIME]\tUNKNOWN");
	enum C_RUNTIME = "UNKNOWN";
}

version (X86) {
	enum PLATFORM = "x86";
} else version (X86_64) {
	enum PLATFORM = "amd64";
} else version (ARM) {
	version (LittleEndian) enum PLATFORM = "aarch32le";
	version (BigEndian) enum PLATFORM = "aarch32be";
	static assert(0,
		"ARM is currently not supported");
} else version (AArch64) {
	version (LittleEndian) enum PLATFORM = "aarch64le";
	version (BigEndian) enum PLATFORM = "aarch64be";
	static assert(0,
		"AArch64 is currently not supported");
} else {
	static assert(0,
		"This platform is not supported");

}

enum APP_VERSION = "0.0.0"; /// DD-DOS version

//
// CPU
//

// It is planned to redo this section, part of Issue #20

// in MHz
private enum i8086_FREQ = 5; // to 10
private enum i486_FREQ = 16; // to 100

/// Number of instructions to execute before sleeping for SLEEP_TIME
enum uint TSC_SLEEP = cast(uint)(
	(SLEEP_TIME * 1_000_000) / ((cast(float)1 / i8086_FREQ) * 1000)
);
//pragma(msg, "[CONFIG]\tIntel 8086 = ", i8086_FREQ, " MHz");
//pragma(msg, "[CONFIG]\tIntel i486 = ", i486_FREQ, " MHz");
//pragma(msg, "[CONFIG]\tvcpu sleeps every ", TSC_SLEEP, " instructions");

//
// Memory
//

/// Default initial amount of memory
enum INIT_MEM = 0x10_0000;
// 0x4_0000    256K MS-DOS minimum
// 0xA_0000    640K
// 0x10_0000  1024K Recommended
// 0x20_0000  2048K
// 0x40_0000  4096K

enum __MM_COM_ROM = 0x400;	/// ROM Communication Area, 400h
enum __MM_COM_DOS = 0x500;	/// DOS Communication Area, 500h
// Includes I/O drivers from IO.SYS and IBMBIO.COM
enum __MM_SYS_DEV = 0x700;	/// System Device Drivers location, 700h
enum __MM_SYS_DOS = 0x1160;	/// MS-DOS data location, 1160h