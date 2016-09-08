# pal
Deterministically calculate your passwords with this password algorithm.

pal is wonderful small algorithm which takes a pair of strings as an input, and calculates an output string which is a strong password.

Let's say for a master you put in:

mymasterpass

And for a target:

facebook

pal spits out this:

P8Ug930Ek9F203fSQxZ8

Every time you enter mymasterpass and facebook and not change the length, this will be the output.
You can now use it as your facebook password and you don't have to remember. You will need pal around when you want to log in though.

There are three pal versions - for Windows, for Linux, and a JavaScript implementation which you can run in a browser.
The Windows and Linux versions offer the options to hide/show what you type in. The Windows one can put the output password directly in
the clipboard, so you'd just need to copy after generating it.
