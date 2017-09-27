Done in Python, uses tkinter.
Works with Python 2.x and Python 3.x

The install script copies "pal.py" and "libpallib.so" to "~/bin/.pal_gui", then
creates a script named "pal" in "~/bin". The script starts pal in the background
and immediately disowns it.

You may need to add your "$HOME/bin" to $PATH if you haven't. This can be achieved
by placing the following in your .bashrc:

# add ~/bin to PATH
export PATH=$HOME/bin:$PATH