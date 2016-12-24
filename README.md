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
The Windows and Linux versions offer the options to hide or show your input and the output. The Windows one can output the password directly to the clipboard, so you can paste it in the password field. 
To do the same in Linux use the pal.sh script and follow the instructions there.

After login don't forget to run pal again with empty input so to erase your password from the clipboard.
