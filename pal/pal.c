//#define WINDOWS/LINUX here

// includes
#include "pal.h"

// code
int main(int argc, char * argv[])
{
	/* gets the input and calculates the password */
	byte masterpwd[MAX_INPUT];
	byte target[MAX_INPUT];
	byte fill_target;
	int i, tbllen;
	int pass_len;
	bool show_input, show_output, no_clipboard;
	
	for (i = 0; i < MAX_INPUT; ++i) // zero out
	{
		masterpwd[i] = 0;
		target[i] = 0;
	}
	
	exe_name = argv[0]; // get executable name
	
	no_clipboard = false; // put in clipboard by default (Windows only)
	
	// set deafult password length
	pass_len = PWD_LEN - 3; // space for xZ8
	
	// -vi -vo options
	show_input = false;
#ifdef WINDOWS
	show_output = false;
#else
	// -vo by default in Linux
	show_output = true;
#endif
	
	// check arguments
	if (argc > 1)
	{
		for (i = 1; i < argc; ++i)
		{
			// set show input flag
			if (0 == strcmp(argv[i], V_IN))
				show_input = true;
			
			// set show output flag
			if (0 == strcmp(argv[i], V_OUT))
				show_output = true;
			
			// set put in clipboard flag
			if (0 == strcmp(argv[i], NO_C))
				no_clipboard = true;
		
			// see if password length is valid
			if (0 == strcmp(argv[i], PL))
			{
				int p_l;
				if (argv[i + 1])
				{
					p_l = atoi(argv[i + 1]);
					if (p_l >= MIN_P_LEN && p_l <= MAX_P_LEN)
						pass_len = p_l - 3; // space for xZ8
						
				}
			}
		
			if (0 == strcmp(argv[i], HLP))
			{	
				print_help();
				return 0;
			}	
		}
	}
	
	// get table length
	tbllen = strlen(TBL);
	
	// allocate result arrays
	int out[pass_len];
	byte password[pass_len + 4];
	
	/* get input 
	 * fprint to stderr so we can redirect the final password output
     * without redirecting the instructions */

	fprintf(stderr, "Enter master:\n");
	read_input(masterpwd, 100, show_input);
	if ('\0' == masterpwd[0])
		masterpwd[0] = ' ';

	fprintf(stderr, "Enter target:\n");
	read_input(target, 100, show_input);
	if ('\0' == target[0])
		target[0] = ' ';
	
	// make master and target at least pass_len long
	put_salt(masterpwd, pass_len, target[0]);
	put_salt(target, pass_len, masterpwd[0]);
	
	// do the cipher
	cipher(masterpwd, target, out, pass_len);
	
	// fetch chars from the table
	for (i = 0; i < pass_len; ++i)
		password[i] = TBL[out[i] % tbllen];
	
	// terminate string
	password[i] = '\0';
	
	// make sure we have at least one lower case, one upper case, and one digit
	strcat(password, "xZ8");

#ifdef WINDOWS
	// Windows output display and clipboard code
	if (show_output)
		fprintf(stdout, "\n%s\n", password);
	
	if (!no_clipboard) // put in clipboard?
	{
		put_in_clipboard(password);
		fprintf(stdout, "You can now paste.\n");
	}
#else
	/* under Linux we stream the password to stdout anyway 
	 * redirection should be used for silent output */
	fprintf(stdout, "\n%s\n", password);
#endif

	return 0;
}

void cipher(byte * s1, byte * s2, int * out, int len)
{
	/* simple coding based on the Vigenere cipher */
	int i, j;
	// shift s1 by s2
	for (i = 0; i < len; ++i)
		out[i] = s1[i] + s2[i];
	
	// multiply backwards
	for (--i, j = 0; j < len; ++j, --i)
		out[j] *= s2[i];
}

void put_salt(byte * str, int slt_ln, byte fill_start)
{
	/* makes str slt_ln bytes long */
	byte ch = fill_start;
	int len = strlen(str);
	int i, ittr;
	
	// see if str is longer than the password length
	if ((ittr = slt_ln - len) < 0)
	{
		// feed back to the front by xoring
		int i, j, k;
		for (i = 0, j = len, k = slt_ln - 1; j > slt_ln; ++i, --j)
		{
			str[i] ^= str[j - 1];
			
			if (i == k) // reset i
				i = 0;
		}
	}
	else if (0 == ittr) // if it's exact length don't touch it
		return;
	
	// add i to every consecutive byte if shorter
	for (i = 0; i < ittr; ++i, ch += i) 
		str[len + i] = ch;
		
	// terminate string
	str[len + i] = '\0';
}

void read_input(byte * in, size_t len, bool echo)
{
	/* reads len number of echoed/unechoed byteacters from 
	 * the Windows cmd or the Linux terminal */
	byte ch;
	byte end_line;
	int i = 0;
	
#ifdef WINDOWS
	// getch() in Windows reads a \r after pressing enter
	end_line = '\r';
#else
	end_line = '\n';
#endif

	if (echo)
	{
		// read until len is reached or enter is pressed
		while (i < len && '\n' != (ch = getchar()) )
		{
			// handle backspaces
			if ('\b' == ch)
			{
				// by decrementing i, but keeping it at least zero
				if (i > 0)
					--i;
					
				continue;
			}
			// actually read byteacter
			in[i] = ch;
			++i;
		}
	}
	else
	{
#ifdef LINUX
		disable_echo();
#endif
		// read until len is reached or enter is pressed
		while (i < len && end_line != (ch = getch()) )
		{
			// handle backsapces as above
			if ('\b' == ch)
			{
				if (i > 0)
					--i;
					
				continue;
			}
			// read byteacter
			in[i] = ch;
			++i;
		}
#ifdef LINUX
		enable_echo();
#endif
	}
	// terminate string
	in[i] = '\0';
}

void print_help(void)
{
	/* prints help */
	printf("\n%s -- the password algorithm\n", exe_name);
	printf("Calculates a strong password from a master-target string combination.\n\n");
	printf("All output strings are 20 characters long by default.\n");
	printf("All output strings have the same last three characters in order to make sure\n");
	printf("that the password has at least one upper case, one lower case, and one number.\n");
	printf("The master, the target, and the output are all limited to the length of 100.\n\n");	
	printf("%s %s\t- echo input\n", exe_name, V_IN);
	printf("%s %s\t- custom output length. Min length is %d, max length is %d.\n", exe_name, PL, MIN_P_LEN, MAX_P_LEN);
#ifdef WINDOWS
	printf("%s %s\t- echo output\n", exe_name, V_OUT);
	printf("%s %s\t- don't place output in clipboard\n", exe_name, NO_C);
#endif
	printf("%s %s\t- this message\n", exe_name, HLP);
#ifdef LINUX
	printf("\nInput prompts are echoed to stderr and the result to stdout.\n");
	printf("Redirection of stdout will result in silent output.\n");
#endif	
}
