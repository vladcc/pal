#ifdef _WIN32
	#ifdef PALLIB_EXPORTS
		#define PALLIB_API __declspec(dllexport)
	#else
		#define PALLIB_API __declspec(dllimport)
	#endif
	// calling convention
	#define PALLIB_CALL __cdecl
#else
	#define PALLIB_API
	#define PALLIB_CALL
#endif

typedef unsigned char byte;
// C linkage for C++ compilers
#ifdef __cplusplus
extern "C"
{
#endif
PALLIB_API const char * PALLIB_CALL make_pass(char * master_in, char * target_in, int len_in);
/*
Takes: Master string, target string, length of the desired password.
Returns: Pointer to a static buffer containing the generated password.
Description: Generates the password and lets you have it.
*/

PALLIB_API const char * PALLIB_CALL lib_ver(void);
/*
Takes: Nothing.
Returns: Constant char pointer to a string with version info.
Description: Informs you about the pallib version.
*/
#ifdef __cplusplus
}
#endif