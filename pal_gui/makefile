CC=gcc
CFLAGS=-s -Wall

SRC=c
HDR=h
OBJ=o
PLL=pallib
PLLDIR=./pallib
WIN_RES_FILE=pallib_dll
WIN_RES_EXT=rc
PLIB_WIN_RES=$(PLLDIR)/$(WIN_RES_FILE).$(WIN_RES_EXT)

$(PLL).$(OBJ): $(PLLDIR)/$(PLL).$(SRC) $(PLLDIR)/$(PLL).$(HDR)
	$(CC) -c $(PLLDIR)/$(PLL).$(SRC) -o $(PLL).$(OBJ) -fPIC $(CFLAGS) -D PALLIB_EXPORTS

$(WIN_RES_FILE).$(OBJ): $(PLLDIR)/$(WIN_RES_FILE).$(WIN_RES_EXT)
	windres -i $< -o $@
	
testw: dll
	$(CC) test.c -o test.exe -L. -l$(PLL) $(CFLAGS)

testl: so
	$(CC) test.c -o test.bin -L. -ldl $(CFLAGS) -D LINUX
	
dll: $(PLL).$(OBJ) $(WIN_RES_FILE).$(OBJ)
	$(CC) $? -o $(PLL).dll -shared -Wl,--subsystem,windows $(CFLAGS)
	
so: $(PLL).$(OBJ)
	$(CC) $(PLL).$(OBJ) -o lib$(PLL).so -shared $(CFLAGS)
	
cleano:
	rm $(PLL).$(OBJ)
	
cleanw: cleano
	rm $(PLL).dll
	rm $(WIN_RES_FILE).$(OBJ)
	rm test.exe
	
cleanl: cleano
	rm lib$(PLL).so
	rm test.bin