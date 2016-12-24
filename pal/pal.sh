#!/bin/bash

# To use:
# 0. Install xclip
# 1. Rename pal to palb
# 2. Rename this script file to pal
# 3. Make sure both palb and the script are executable
# 4. Place them in /bin
# 5. Run pal

# This script runs the pal binary, placing the password in the
# clipboard by using xclip.
# If you would like output to screen, run palb directly.

XCLP="xclip"
PAL="palb"
FILE="/tmp/.palbpasstmpf"

# see if palb exists

command -v $PAL > /dev/null 2>&1
if [ $? -eq 1 ]; then
	echo "Error: pal binary <$PAL> is missing."
	exit 1
fi

# see if xclip is installed

command -v $XCLP > /dev/null 2>&1
if [ $? -eq 1 ]; then
	echo "I require $XCLP. Please install it first."
else

# run pal with the script's arguments,
# remove new lines, 
# place password in the clipboard, 
# clean up	

	$PAL $@ > $FILE
	cat $FILE | tr -d '\n' < $FILE | xclip -selection clipboard
	rm $FILE
	echo "You can now paste"
fi
