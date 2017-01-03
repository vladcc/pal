# pal
Deterministically calculate your passwords with this password algorithm

pal takes a pair of strings and outputs a strong password

Let's say for master you put in:

mymasterpass

And for target:

facebook

pal spits out:

P8Ug930Ek9F203fSQxZ8

Every time you enter mymasterpass and facebook, and not change the length, this will be the output.
You can now use it as a password you don't have to remember. You will need pal when you want to log in, though.

There are three versions - for Windows, for Linux, and a JavaScript implementation for browsers.
The Windows and Linux versions offer the options to hide or show your input and output. The Windows version outputs to the clipboard so you can directly paste in any password field. 
To do the same in Linux use pal.sh. On Windows it's also better to use pal.cmd rather than running pal directly, as the script runs
pal a second time for you in order to clean the clipboard.
