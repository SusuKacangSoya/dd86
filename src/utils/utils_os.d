/*
 * utils_os.d : Basic OS utilities
 *
 * Includes OS utilities, such as changing/getting the current working
 * directory, setting/getting file attributes, directory walkers, etc.
 */

module utils_os;

//TODO: File/directory walker

version (Windows) {
	private import core.sys.windows.windows;
} else {
// Temporary -betterC fix, confirmed on DMD 2.079.0+ (linux)
// stat is extern (D) for some stupid reason
import core.sys.posix.sys.stat : stat, stat_t;
extern (C) int stat(char*, stat_t*);
}

struct OSTime {
	ubyte hour, minute, second, millisecond;
}
struct OSDate {
	ushort year;
	ubyte month, day, weekday;
}

/**
 * Get OS current time
 * Params: ost = OSTime structure pointer
 * Returns: 0 on success
 */
extern (C)
int os_time(OSTime* ost) {
	version (Windows) {
		import core.sys.windows.windows : SYSTEMTIME, GetLocalTime;
		SYSTEMTIME s;
		GetLocalTime(&s);

		ost.hour = cast(ubyte)s.wHour;
		ost.minute = cast(ubyte)s.wMinute;
		ost.second = cast(ubyte)s.wSecond;
		ost.millisecond = cast(ubyte)s.wMilliseconds;
	} else version (Posix) {
		import core.sys.posix.time : tm, localtime;
		import core.sys.posix.sys.time : timeval, gettimeofday;
		//TODO: Consider moving gettimeofday(2) to clock_gettime(2)
		//      https://linux.die.net/man/2/gettimeofday
		//      gettimeofday is deprecated since POSIX.2008
		tm* s; timeval tv;
		gettimeofday(&tv, null);
		s = localtime(&tv.tv_sec);

		ost.hour = cast(ubyte)s.tm_hour;
		ost.minute = cast(ubyte)s.tm_min;
		ost.second = cast(ubyte)s.tm_sec;
		ost.millisecond = cast(ubyte)tv.tv_usec;
	} else {
		static assert(0, "Implement os_time");
	}
	return 0;
}

/**
 * Get OS current date
 * Params: osd = OSDate structure pointer
 * Returns: 0 on success
 */
extern (C)
int os_date(OSDate* osd) {
	version (Windows) {
		import core.sys.windows.winbase : SYSTEMTIME, GetLocalTime;
		SYSTEMTIME s;
		GetLocalTime(&s);

		osd.year = s.wYear;
		osd.month = cast(ubyte)s.wMonth;
		osd.day = cast(ubyte)s.wDay;
		osd.weekday = cast(ubyte)s.wDayOfWeek;
	} else version (Posix) {
		import core.sys.posix.time : time_t, time, localtime, tm;
		time_t r; time(&r);
		const tm* s = localtime(&r);

		osd.year = 1900 + s.tm_year;
		osd.month = cast(ubyte)(++s.tm_mon);
		osd.day = cast(ubyte)s.tm_mday;
		osd.weekday = cast(ubyte)s.tm_wday;
	} else {
		static assert(0, "Implement os_date");
	}
	return 0;
}

/**
 * Set the process' current working directory.
 * Params: p = Path
 * Returns: 0 on success
 */
extern (C)
int scwd(char* p) {
	version (Windows) {
		return SetCurrentDirectoryA(p) != 0;
	}
	version (Posix) {
		import core.sys.posix.unistd : chdir;
		return chdir(p) == 0;
	}
}

/**
 * Get the process' current working directory.
 * Params: po
 * Returns: non-zero on success
 */
extern (C)
int gcwd(char* p) {
	version (Windows) {
		return GetCurrentDirectoryA(255, p);
	}
	version (Posix) {
		import core.sys.posix.unistd : getcwd;
		p = getcwd(p, 255);
		return 1;
	}
}

/**
 * Verifies if the file or directory exists from path
 * Params: p = Path
 * Returns: 1 on found
 */
extern (C)
int pexist(char* p) {
	version (Windows) {
		return GetFileAttributesA(p) != 0xFFFF_FFFF;
	}
	version (Posix) {
		import core.sys.posix.sys.stat;
		debug import core.stdc.stdio;
		__gshared stat_t s;
		return stat(p, &s) == 0;
		//debug printf("mode: %X \n", s.st_mode);
		//return s.st_mode != 0;
	}
}

/**
 * Verifies if given path is a directory
 * Returns: not-zero on success
 */
extern (C)
int pisdir(char* p) {
	version (Windows) {
		return GetFileAttributesA(p) == 0x10; // FILE_ATTRIBUTE_DIRECTORY
	}
	version (Posix) {
		import core.sys.posix.sys.stat;
		debug import core.stdc.stdio;
		__gshared stat_t s;
		stat(p, &s);
		return S_ISDIR(s.st_mode);
	}
}