// includes
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

#ifdef WINDOWS	// compile for Windows
	#include <conio.h>
	#include <windows.h>
	#include "win_clipbd.h"
#endif

#ifdef LINUX	// compile for Linux
	#include "lconio.h"
#endif

// constants
#define PWD_LEN 	20		// default password length
#define MIN_P_LEN	5		// min password length
#define MAX_P_LEN	100		// max password length
#define MAX_INPUT	128		// size of input buffer

// accepted arguments
const char V_IN[]	= "-vi";
const char V_OUT[]	= "-vo";
const char NO_C[]	= "-nc";
const char HLP[]	= "-h";
const char PL[]		= "-pl";

// lookup table
const char TBL[] =	"0123456789qwertyuiopasdfghjklzxcvbnm0123456789QWERTYUIOPASDFGHJKLZXCVBNM0123456789"
					"qwertyuiopasdfghjklzxcvbnm0123456789QWERTYUIOPASDFGHJKLZXCVBNM01234567890123456789"
					"0123456789QWERTYUIOPASDFGHJKLZXCVBNM01234567890123456789qwertyuiopasdfghjklzxcvbnm"
					"QWERTYUIOPASDFGHJKLZXCVBNM01234567890123456789qwertyuiopasdfghjklzxcvbnm0123456789"
					"01234567890123456789qwertyuiopasdfghjklzxcvbnm0123456789QWERTYUIOPASDFGHJKLZXCVBNM";

// typedefs
typedef unsigned char byte;

// globals
byte * exe_name;

// functions
void cipher(byte * s1, byte * s2, int * out, int len);
void read_input(byte * in, size_t len, bool echo);
void put_salt(byte * str, int slt_ln, byte fill_start);
void put_in_clipboard(const byte * text);
void print_help(void);
