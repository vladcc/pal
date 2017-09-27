#pragma compile(FileDescription, Password Algorithm)
#pragma compile(ProductName, Pal)
#pragma compile(ProductVersion, 1.0.0.0)
#pragma compile(FileVersion, 1.0.0.0)
#pragma compile(LegalCopyright, Vladimir Dinev)

#NoTrayIcon
#include "pal_includes.au3"

Opt("GUICloseOnESC", 1)
Opt("MustDeclareVars", 1)
_Singleton(@ScriptName)

Global Const $LIBNAME = "pallib.dll", $TITLE = "Pal", $VERSION = "v1.0"
Global Const $MIN_LEN = 5, $MAX_LEN = 100, $DEF_LEN = 20
Global Const $FOCUS_SLEEP = 100, $PASS_SLEEP = 15000 ; 15 secs
Global $ghMainGUI, $gguiMsg, $gtxtMaster, $gtxtTarget, $gLen = $DEF_LEN, $gbBlankOut = False
Global $gstrLastPass = "" ; checked in BlankOut()

Main()

Func Main()
   ; set working directory to script dir
   FileChangeDir(@ScriptDir)

   ; check for dll
   If FileExists($LIBNAME) = 0 Then
	  MsgBox($MB_ICONERROR, $TITLE,"Err: " & $LIBNAME & " not found")
	  Exit($EXIT_FAILURE)
   EndIf

   Local $hMainGUI, $txtMaster, $txtTarget, $btnLen, $btnShow, $btnInfo, $tmrPassTime

   $hMainGUI = GUICreate($TITLE, 200, 150)
   $ghMainGUI = $hMainGUI

   GUICtrlCreateLabel("Master:", 20, 20)
   $txtMaster = GUICtrlCreateInput("", 20, 35, 200-40, Default, BitOr($ES_PASSWORD, $ES_AUTOHSCROLL))
   $gtxtMaster = $txtMaster

   GUICtrlCreateLabel("Target:", 20, 60)
   $txtTarget = GUICtrlCreateInput("", 20, 75, 200-40, Default, BitOr($ES_PASSWORD, $ES_AUTOHSCROLL))
   $gtxtTarget = $txtTarget

   $btnLen = GUICtrlCreateButton("&Length", 20, 100, 70, Default)
   $btnShow = GUICtrlCreateButton("&Show", 90, 100, 70, Default)
   $btnInfo = GUICtrlCreateButton("&?", 160, 100)

   GUISetState(@SW_SHOW, $hMainGUI)

   Sleep($FOCUS_SLEEP) ; focus sleeps prevent unwanted enter action
   While 1
	  $gguiMsg = GUIGetMsg()
	  Select
		 Case $gguiMsg = $GUI_EVENT_CLOSE
			OkQuit()
		 Case $gguiMsg = $btnLen
			SetLen()
			Sleep($FOCUS_SLEEP)
			GUICtrlSetState($txtMaster, $GUI_FOCUS)
		 Case $gguiMsg = $btnShow
			ShowStars()
			Sleep($FOCUS_SLEEP)
			GUICtrlSetState($txtMaster, $GUI_FOCUS)
		 Case $gguiMsg = $btnInfo
			ShowInfo()
			GUICtrlSetState($txtMaster, $GUI_FOCUS)
			Sleep($FOCUS_SLEEP)
		 Case _IsPressed($ENTER_KEY)
			If ControlGetFocus($TITLE) = "Edit1" Then ; if master box is on focus
			   GUICtrlSetState($txtTarget, $GUI_FOCUS)
			   Sleep($FOCUS_SLEEP*3)
			ElseIf ControlGetFocus($TITLE) = "Edit2" Then ; if target box is on focus
			   ; make new password and remember it
			   $gstrLastPass = MakePass()
			   ; get a new timer so we can count down $PASS_SLEEP/1000 seconds
			   $tmrPassTime = TimerInit()
			   GUICtrlSetState($txtMaster, $GUI_FOCUS)
			   Sleep($FOCUS_SLEEP*3)
			EndIf
		 EndSelect
	  ; check if the clipboard is to be blanked
	  If $gbBlankOut = True Then
		 ; see if $PASS_SLEEP/1000 seconds have passed
		 If TimerDiff($tmrPassTime) >= $PASS_SLEEP Then
			BlankOut()
			Sleep($FOCUS_SLEEP)
		 EndIf
	  EndIf
   WEnd
EndFunc

Func SetLen()
   BlankOut()
   ; make an input box
   GUISetState($GUI_DISABLE, $ghMainGUI)

   Sleep($FOCUS_SLEEP)
   Local $hInput
   $hInput = GUICreate($TITLE, 120, 100)
   GUISwitch($hInput)

   Local $lMsg = "Length is: " & $gLen & @CRLF & @CRLF & "Set new length:"
   GUICtrlCreateLabel($lMsg, 20, 10)

   Local $txtLen = GUICtrlCreateInput("", 20, 55, 80, 21, $ES_NUMBER)

   GUISetState(@SW_SHOW, $hInput)

   Local $guiMsg

   While 1
	  $guiMsg = GUIGetMsg()
	  Select
		 Case $guiMsg = $GUI_EVENT_CLOSE
			ExitLoop
		 Case _IsPressed($ENTER_KEY)
			If ControlGetFocus($TITLE) = "Edit1" Then ; if length box is on focus
			   Local $len = GUICtrlRead($txtLen)
			   ; set password length
			   If $len < $MIN_LEN Or $len > $MAX_LEN Then
				  $len = $DEF_LEN
			   EndIf
			   $gLen = $len
			EndIf
			ExitLoop
	  EndSelect
   WEnd
   GUIDelete($hInput)
   ; switch back to parent window
   GUISetState($GUI_ENABLE, $ghMainGUI)
   GUISwitch($ghMainGUI)
EndFunc

Func ShowStars()
   BlankOut()
   ; show master and target in a message box
   If $IDOK = MsgBox(BitOr($MB_ICONQUESTION, $MB_OKCANCEL, $MB_DEFBUTTON2), $TITLE, _
			   "Are you sure?") Then
	  MsgBox($MB_OK, $TITLE, _
	  "Master: " & GUICtrlRead($gtxtMaster) & @CRLF & "Target: " & GUICtrlRead($gtxtTarget))
   EndIf
EndFunc

Func ShowInfo()
   BlankOut()
   Static Local $fLibVer = "lib_ver"
   Static Local $strLibVer = DllCall($LIBNAME, "str:cdecl", $fLibVer)
   Static Local $lbInfo, $lMAX_IN = 127
   Static Local $passEnd = "xZ8"
   If @error <> 0 Then
	  ErrQuit("Error while calling function " & $fLibVer & " from library " & $LIBNAME)
	  $lbInfo = "N/A"
   Else
	  $lbInfo = $strLibVer[0]
   EndIf

   Static Local $strInfo = "Use:" & @CRLF & _
   "1. Type a master string and press Enter." & @CRLF & _
   "2. Type a target string and press Enter." & @CRLF & @CRLF & _
   "This will generate a password unique for the master/target pair " & _
   "and place it in the clipboard for you to paste. The password will contain " & _
   "uppercase letters, lower case letters, and numbers. All passwords end with '" & _
   $passEnd & "' to make sure this is always true." & @CRLF & @CRLF & _
   "The length of the password is " & $DEF_LEN & " by default, but can be set anywhere between " & _
   $MIN_LEN & " and " & $MAX_LEN & " characters including. " & _
   "To change it click on the 'Length' button, enter the " & _
   "new length, and press Enter. If the new length is not in the allowed range " & _
   "then the default length is used. The master and the target strings are limited to " & _
   $lMAX_IN & " characters each." & @CRLF & @CRLF & _
   "You can see the content of the master/target fields " & _
   "by clicking on the 'Show' button." & @CRLF & @CRLF & _
   "Pressing Esc closes the currently active Pal window." & @CRLF & @CRLF & _
   "If the clipboard still contains your password when you exit the program, " & _
   "click any of the buttons, or when " & $PASS_SLEEP/1000 & " seconds have " & _
   "passed since your last password generation, the clipboard will be cleared." & @CRLF & @CRLF & _
   $TITLE & " version: " & $VERSION & @CRLF & _
   "Library version: " & $lbInfo

   MsgBox($MB_ICONINFORMATION, $TITLE, $strInfo)
EndFunc

Func MakePass()
   ; generate password by calling into the dll
   Local $master = GUICtrlRead($gtxtMaster)
   GUICtrlSetData($gtxtMaster, "")
   Local $target = GUICtrlRead($gtxtTarget)
   GUICtrlSetData($gtxtTarget, "")

   If $gLen < $MIN_LEN Or $gLen > $MAX_LEN Then $gLen = $DEF_LEN
   If $master = "" Then $master = " "
   If $target = "" Then $target = " "

   Static Local $fMakePass = "make_pass"
   Local $dllRet = DllCall($LIBNAME, "str:cdecl", $fMakePass, "str", $master, "str", $target, "int", $gLen)
   If @error <> 0 Then
	  ErrQuit("Error while calling function " & $fMakePass & " from library " & $LIBNAME)
   EndIf

   ClipPut($dllRet[0])  ; put password in the clipboard
   $gbBlankOut = True

   Return $dllRet[0] ; return password
EndFunc

Func BlankOut()
   ; blank out the clipboard if the password is still there
   If ClipGet() = $gstrLastPass Then
	  ClipPut("")
   EndIf
   $gbBlankOut = False
EndFunc

Func OkQuit()
   ; go home
   BlankOut()
   Exit($EXIT_SUCCESS)
EndFunc

Func ErrQuit($strMsg)
   ; show error and quit
   MsgBox($MB_ICONERROR, $TITLE, $strMsg)
   Exit($EXIT_FAILURE)
EndFunc