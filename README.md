# pal
Deterministically calculate your passwords with this password algorithm

pal takes a pair of strings and outputs a strong password

Let's say you enter:

mymasterpass

facebook

pal spits out:

P8Ug930Ek9F203fSQxZ8

Every time you enter mymasterpass and facebook, and do not change the length,
this will be the output. You can now use it as a password you don't have to 
remember. You can save it in your browser or generate it with pal every time.
I started doing the latter, so at one point it turned out I had to make pal run
on all platforms I use.

pal can generate passwords between 5 and 100 characters including, with input
strings limited to 127 characters. All passwords end in "xZ8" to make sure they 
contain a lower case, an upper case, and a number.

In /pal/ there is the old command line version. It gets input from the keyboard
without echoing it on the screen. The generated password is placed in the clipboard
of the system. On Windows this is done using the Win API, on Linux it is done using
xclip from the pal.sh script. It's recommended to run pal from the .cmd and .sh
scripts as described in them. In order to clear the clipboard after you've pasted
your password you have to run pal again with empty input, though, which makes this
version awkward to use.

In /pal_gui/ you'd find the pal algorithm implemented as a shared library plus
GUIs for Windows and Linux. The Windows GUI is done in AutoIt, the Linux GUI
is done in Python with python-tk. You enter the input in two password boxes and
press Enter. The password again goes to the clipboard, but it is cleared automatically
after 15 seconds, when you click a button in the GUI, or when you exit the program.

The pal.html file in the root directory of the project is a browser implementation.
It's kind of a last resort. There is no clipboard support, the password just appears
in the password box. You have to cut/copy it manually. The font in the password box
is set to be really, really small so it is unreadable at a glance. 
