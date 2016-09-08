/* puts text in the Windows clipboard */
void put_in_clipboard(const byte * text);

void put_in_clipboard(const byte * text)
{
	HANDLE hData;
	byte * memp;
	
	// get the clipboard
	if (!OpenClipboard(NULL))
	{
		fprintf(stderr, "Err: couldn't open clipboard.\n");
		exit(1);
	}	
	
	// empty it
	EmptyClipboard();
	
	// get handle to memory
	hData = GlobalAlloc(GPTR, strlen(text) + 1);
	
	if (!hData)
	{
		fprintf(stderr, "Err: couldn't allocate memory.\n");
		exit(1);
	}
	
	// get pointer to the memory and lock it
	memp = (char *)GlobalLock(hData);
	
	if (!memp)
	{
		fprintf(stderr, "Err: couldn't lock memory.\n");
		exit(1);
	}
	
	// actually copy the data
	strcpy(memp, text);
	
	// unlock
	GlobalUnlock(hData);
	
	// place in the clipboard
	if (!SetClipboardData(CF_TEXT, hData))
	{
		fprintf(stderr, "Err: couldn't put password in clipboard.\n");
		exit(1);
	}
	
	// close it
	CloseClipboard();
	// free the memory
	GlobalFree(hData);
}
