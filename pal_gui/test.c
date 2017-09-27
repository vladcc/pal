#include <stdio.h>
#include <stdlib.h>
#include "./pallib/pallib.h"

#ifdef LINUX
#include <dlfcn.h>
typedef const char * (*do_pass)();
typedef const char * (*ver_nfo)(void);
#endif

int main(int argc, char * argv[])
{
	if (argc < 3)
	{
		fprintf(stderr, "Use: test <str1> <str2> [<len>]");
		exit(EXIT_FAILURE);
	}
	
	int len = 20;
	
	if (argc >= 4)
		sscanf(argv[3], "%d", &len);
	
#ifdef LINUX
	void * so = dlopen("./libpallib.so", RTLD_NOW);
	do_pass make_pass = dlsym(so, "make_pass");
	ver_nfo lib_ver = dlsym(so, "lib_ver");
#endif
	
	const char * pass = make_pass(argv[1], argv[2], len);
	puts(pass);
	puts(lib_ver());
	
#ifdef LINUX
	dlclose(so);
#endif
	return 0;
}