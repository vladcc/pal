#!/usr/bin/env python

import ctypes
try:
    # Python2
    import Tkinter as tk
    import tkMessageBox as MsgBox
except ImportError:
    # Python3
    import tkinter as tk
    from tkinter import messagebox as MsgBox

# ----- CONSTANTS -----
TITLE = "Pal"
VERSION = "v1.0"
FRAME_BORDER_W = 5
MIN_LEN = 5
MAX_LEN = 100
DEF_LEN = 20
LIB_NAME = "./libpallib.so"
BLANK_TIME = 15000 # ms = 15 sec
# -----/CONSTANTS -----

# ----- GLOBAL VARS -----
gcurr_len = DEF_LEN
gcurr_pass = ""

# set up the shared library
gplib = ctypes.CDLL(LIB_NAME)
gplib.lib_ver.restype = ctypes.c_char_p
gplib.make_pass.restype = ctypes.c_char_p
# -----/GLOBAL VARS  -----

# ----- SERVICE FUNCTIONS -----
def make_pass():
	"Get a password from the library and place it in the clipboard"
	global gcurr_pass
	master = txt_master.get()
	target = txt_target.get()
	
	# blank out the entries
	txt_master.delete(0, tk.END)
	txt_target.delete(0, tk.END)
	
	# spaces by default
	if "" == master:
		master = " "
	if "" == target:
		target = " "
	
	master = ctypes.c_char_p(master.encode("ascii"))
	target = ctypes.c_char_p(target.encode("ascii"))
	plen = ctypes.c_int(gcurr_len)

	gcurr_pass = gplib.make_pass(master, target, plen).decode("ascii")
	clip_clear()
	root.clipboard_append(gcurr_pass)
	root.after(BLANK_TIME, blank_out)
	return

def clip_clear():
	"Append + clear + append prevents errors"
	root.clipboard_append("")
	root.clipboard_clear()
	root.clipboard_append("")
	return

def blank_out():
	"Remove the last known password from the clipboard"
	if root.clipboard_get() == gcurr_pass:
		clip_clear()
	return
	
def set_len():
	"Set new password length"
	blank_out()
	root.withdraw() # minize root
	top = tk.Toplevel()
	top.title(TITLE)
	place_relative(root, top) # render at root's coordinates
	
	def restore_root_quit():
		root.deiconify()
		top.destroy()
		return
	top.protocol("WM_DELETE_WINDOW", restore_root_quit)
	
	def close_me(event):
		restore_root_quit()
		return
	top.bind("<Escape>", close_me)
	
	frm = tk.Frame(top, borderwidth=FRAME_BORDER_W*5)
	frm.pack()
	
	msg = "Length is: " + str(gcurr_len) + "\n\n" + "Set new length:\n"
	lbl_msg = tk.Label(frm, text=msg)
	lbl_msg.pack()
	
	def is_numeric(new_char):
		"Enforce numeric entry"
		if new_char in "0123456789":
			return True
		else:
			return False
		return
		
	txt_newlen = tk.Entry(frm)
	# register validation callback
	is_num_wrap = txt_newlen.register(is_numeric)
	# "%S" passes the last typed character 
	txt_newlen.config(validate="key", vcmd=(is_num_wrap, "%S"))
	txt_newlen.pack()
	txt_newlen.focus_set()
	
	def get_new_len(event):
		"Ensure the new length is legal"
		global gcurr_len
		new_len = 0
		try:
			new_len = int(txt_newlen.get())
		except ValueError:
			new_len = DEF_LEN
			
		if new_len < MIN_LEN or new_len > MAX_LEN:
			new_len = DEF_LEN
		gcurr_len = new_len
		restore_root_quit()
		return
		
	txt_newlen.bind("<Return>", get_new_len)
	txt_newlen.bind("<KP_Enter>", get_new_len) # key pad enter
	return
	
def show_master_target():
	"Show master/target in a message box"
	blank_out()
	if MsgBox.askyesno(TITLE, "Are you sure?", default=MsgBox.NO):
		strMsg = "Master: " + txt_master.get() + "\n" + "Target: " + txt_target.get()
		MsgBox.showinfo(TITLE, strMsg)
	return
		
def show_info():
	"Show help"
	blank_out()
	root.withdraw() # minize root
	top = tk.Toplevel()
	top.title(TITLE)
	place_relative(root, top) # render at root's coordinates
	
	def restore_root_quit():
		root.deiconify()
		top.destroy()
		return
	top.protocol("WM_DELETE_WINDOW", restore_root_quit)
	
	def close_me(event):
		restore_root_quit()
		return
	top.bind("<Escape>", close_me)
	
	lbl_msg = tk.Label(top, borderwidth=FRAME_BORDER_W*2, text=show_info.info,
	                   font=("monospace", 9), anchor="e", justify="left",
	                   wraplength=450)
	lbl_msg.pack()
	return
show_info.info = str(
"""Use:
1. Type a master string and press Enter.
2. Type a target string and press Enter.

This will generate a password unique for the master/target pair \
and place it in the clipboard for you to paste. The password will contain \
uppercase letters, lower case letters, and numbers. All passwords end with \
"{pass_end}" to make sure this is always true.

The length of the password is {def_len} be default, but can be set anywhere \
from {min_len} to {max_len} including. To change it click on the "Length" \
button, enter the new length, and press Enter. If the new length is not in the \
allowed range then the default length is used.

You can see the content of the master/target password fields
by clicking on the "Show" button.

If the clipboard still contains your password when you exit the program, \
click any of the buttons, or when {seconds} seconds have passed since your last \
password generation, the clipboard will be cleared.

Pressing Esc closes the currently active {name} window.

{name} version: {this_ver}
Library version: {lib_ver}""")
show_info.str_fmt = {"pass_end":"xZ8", "def_len":DEF_LEN, "min_len":MIN_LEN,
	                 "max_len":MAX_LEN, "seconds":BLANK_TIME/1000, "name":TITLE,
	                 "this_ver":VERSION, "lib_ver":gplib.lib_ver().decode("ascii")}
show_info.info = show_info.info.format(**show_info.str_fmt)
# -----/SERVICE FUNCTIONS -----

# ----- GUI -----
root = tk.Tk()
root.title(TITLE)
def ok_quit():
	blank_out()
	root.destroy()
	return
root.protocol("WM_DELETE_WINDOW", ok_quit)

def ok_quit_event(event):
	ok_quit()
	return
root.bind("<Escape>", ok_quit_event)

def alt_l(event):
	set_len()
	return
root.bind("<Alt_L><l>", alt_l)
root.bind("<Alt_L><L>", alt_l)

def alt_s(event):
	show_master_target()
	return
root.bind("<Alt_L><s>", alt_s)
root.bind("<Alt_L><S>", alt_s)

def alt_info(event):
	show_info()
	return
root.bind("<Alt_L><slash>", alt_info)
root.bind("<Alt_L><question>", alt_info)


input_frame = tk.Frame(root, borderwidth=FRAME_BORDER_W*4)
input_frame.pack(side="top")

lbl_master = tk.Label(input_frame, text="Master:")
lbl_master.pack()

txt_master = tk.Entry(input_frame, show="*")
def focus_target(event):
	txt_target.focus_set()
	return
txt_master.bind("<Return>", focus_target)
txt_master.bind("<KP_Enter>", focus_target) # key pad enter
txt_master.pack()

lbl_target = tk.Label(input_frame, text="Target:")
lbl_target.pack()

txt_target = tk.Entry(input_frame, show="*")
def event_make_pass(event):
	make_pass()
	txt_master.focus_set()
	return
txt_target.bind("<Return>", event_make_pass)
txt_target.bind("<KP_Enter>", event_make_pass) # key pad enter
txt_target.pack()


button_frame = tk.Frame(root, borderwidth=FRAME_BORDER_W)
button_frame.pack(side="top")

btn_Length = tk.Button(button_frame, text="Length", command=set_len, underline=0)
btn_Length.pack(side="left")

btn_Show = tk.Button(button_frame, text="Show", command=show_master_target, underline=0)
btn_Show.pack(side="left")

btn_Info = tk.Button(button_frame, text="?", command=show_info, underline=0)
btn_Info.pack(side="left")

def center_window(window):
	"Render at the center of the screen"
	window.geometry("+%d+%d" % (center_window.w, center_window.h))
	return
center_window.w = root.winfo_screenwidth() / 2
center_window.h = root.winfo_screenheight() / 2

def place_relative(root, window):
	"Render where root is"
	window.geometry("+%d+%d" % (root.winfo_x(), root.winfo_y()))
	return
# -----/GUI -----

txt_master.focus_set()
clip_clear()
center_window(root)
root.mainloop()
