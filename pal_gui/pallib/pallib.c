#include <string.h>
#include "pallib.h"

#define PWD_LEN 	20
#define MIN_PWD_LEN	5
#define MAX_PWD_LEN	100
#define MAX_INPUT	128

static const char TBL[] =	"0123456789qwertyuiopasdfghjklzxcvbnm0123456789QWERTYUIOPASDFGHJKLZXCVBNM0123456789"
							"qwertyuiopasdfghjklzxcvbnm0123456789QWERTYUIOPASDFGHJKLZXCVBNM01234567890123456789"
							"0123456789QWERTYUIOPASDFGHJKLZXCVBNM01234567890123456789qwertyuiopasdfghjklzxcvbnm"
							"QWERTYUIOPASDFGHJKLZXCVBNM01234567890123456789qwertyuiopasdfghjklzxcvbnm0123456789"
							"01234567890123456789qwertyuiopasdfghjklzxcvbnm0123456789QWERTYUIOPASDFGHJKLZXCVBNM";

static void cipher(byte * s1, byte * s2, int * out, int len);
static void put_salt(byte * str, int slt_ln, byte fill_start);					

static void cipher(byte * s1, byte * s2, int * out, int len)
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

static void put_salt(byte * str, int slt_ln, byte fill_start)
{
	/* makes str slt_ln bytes long */
	byte ch = fill_start;
	int len = strlen((char *)str);
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
	return;
}

const char * PALLIB_CALL make_pass(char * master_in, char * target_in, int len_in)
{
	/* call this to get a password */
	static byte master[MAX_INPUT];
	static byte target[MAX_INPUT];
	static char passwd[MAX_INPUT];
	
	int len = len_in;
	
	if (len < MIN_PWD_LEN || len > MAX_PWD_LEN)
		len = PWD_LEN;
	
	int i;
	byte * m = master;
	byte * t = target;
	byte * min = (byte *)master_in;
	byte * tin = (byte *)target_in;
	
	// copy to internal buffers
	for (i = 0; i < (MAX_INPUT - 1); ++i)
	{
		if(*min)
			*m = *min, ++m, ++min;
		if (*tin)
			*t = *tin, ++t, ++tin;
	}
	*m = '\0', *t = '\0';
	
	int pass_len = len - 3;
	
	int ciph_out[pass_len];

	put_salt(master, pass_len, target[0]);
	put_salt(target, pass_len, master[0]);
	cipher(master, target, ciph_out, pass_len);
	
	int tbllen = strlen(TBL);
	// pull characters from the table
	for (i = 0; i < pass_len; ++i)
		passwd[i] = TBL[ciph_out[i] % tbllen];
	passwd[i] = '\0';
	
	strcat(passwd, "xZ8");
	return passwd;
}

const char * PALLIB_CALL lib_ver(void)
{
	const static char libv[] = "pallib v1.0";
	return libv;
}
