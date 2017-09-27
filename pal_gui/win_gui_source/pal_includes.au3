Const $GUI_FOCUS = 256, $GUI_EVENT_CLOSE = -3, $GUI_DISABLE = 128, $GUI_ENABLE = 64
Const $MB_OK = 0, $MB_OKCANCEL = 1, $IDYES = 6, $IDOK = 1, $MB_ICONERROR = 16, $MB_ICONQUESTION = 32, $MB_DEFBUTTON2 = 256
Const $MB_ICONINFORMATION = 64
Const $EXIT_SUCCESS = 0, $EXIT_FAILURE = 1
Const $ES_PASSWORD = 0x0020, $ES_NUMBER = 0x2000, $ES_AUTOHSCROLL = 0x0080
Const $ENTER_KEY = "0D"

Func _Singleton($sOccurrenceName, $iFlag = 0)
	Local Const $ERROR_ALREADY_EXISTS = 183
	Local Const $SECURITY_DESCRIPTOR_REVISION = 1
	Local $tSecurityAttributes = 0

	If BitAND($iFlag, 2) Then
		; The size of SECURITY_DESCRIPTOR is 20 bytes.  We just
		; need a block of memory the right size, we aren't going to
		; access any members directly so it's not important what
		; the members are, just that the total size is correct.
		Local $tSecurityDescriptor = DllStructCreate("byte;byte;word;ptr[4]")
		; Initialize the security descriptor.
		Local $aRet = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", _
				"struct*", $tSecurityDescriptor, "dword", $SECURITY_DESCRIPTOR_REVISION)
		If @error Then Return SetError(@error, @extended, 0)
		If $aRet[0] Then
			; Add the NULL DACL specifying access to everybody.
			$aRet = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", _
					"struct*", $tSecurityDescriptor, "bool", 1, "ptr", 0, "bool", 0)
			If @error Then Return SetError(@error, @extended, 0)
			If $aRet[0] Then
				; Create a SECURITY_ATTRIBUTES structure.
				$tSecurityAttributes = DllStructCreate($tagSECURITY_ATTRIBUTES)
				; Assign the members.
				DllStructSetData($tSecurityAttributes, 1, DllStructGetSize($tSecurityAttributes))
				DllStructSetData($tSecurityAttributes, 2, DllStructGetPtr($tSecurityDescriptor))
				DllStructSetData($tSecurityAttributes, 3, 0)
			EndIf
		EndIf
	EndIf

	Local $aHandle = DllCall("kernel32.dll", "handle", "CreateMutexW", "struct*", $tSecurityAttributes, "bool", 1, "wstr", $sOccurrenceName)
	If @error Then Return SetError(@error, @extended, 0)
	Local $aLastError = DllCall("kernel32.dll", "dword", "GetLastError")
	If @error Then Return SetError(@error, @extended, 0)
	If $aLastError[0] = $ERROR_ALREADY_EXISTS Then
		If BitAND($iFlag, 1) Then
			DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $aHandle[0])
			If @error Then Return SetError(@error, @extended, 0)
			Return SetError($aLastError[0], $aLastError[0], 0)
		Else
			Exit -1
		EndIf
	EndIf
	Return $aHandle[0]
 EndFunc   ;==>_Singleton

Func _IsPressed($sHexKey, $vDLL = 'user32.dll')
	; $hexKey must be the value of one of the keys.
	; _Is_Key_Pressed will return 0 if the key is not pressed, 1 if it is.
	Local $a_R = DllCall($vDLL, "short", "GetAsyncKeyState", "int", '0x' & $sHexKey)
	If @error Then Return SetError(@error, @extended, False)
	Return BitAND($a_R[0], 0x8000) <> 0
EndFunc   ;==>_IsPressed