;adapted code from tjmonk15 to use device names, mitigating changing audio device lists
;https://autohotkey.com/board/topic/2306-changing-default-audio-device/page-4

#SingleInstance Force
#UseHook On
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

#h:: selectAudioDevice("G933", "G933", true) ; headset
#s:: selectAudioDevice("Monitor", , true) ; Speakers
;#b:: selectAudioDevice("Speakers") ; aux out

; Usage: selectAudioDevice(Output [, Input, Loud])
;  Output - Name of the desired output device
;  Input  - Name of the desired input device
;  Loud   - if true, will play sound on new device to confirm it was set
;
; The name of sound devices can be customized in the sound panel by selecting properties for the device
; If a name appears more than once, the first will always be selected

SelectAudioDevice(output, input := "", loud := false)
{
	WinGet, cur, ID, A ;save active window
	
	;close window if already open to start from known state
	WinClose, ahk_class #32770
	WinWaitClose, ahk_class #32770
	run, mmsys.cpl
	winwait, ahk_class #32770
	
	WinActivate, ahk_id %cur% ;reactivate active window to minimize side effects
	winset, bottom,, ahk_class #32770 ;Optional, still appears on open
	
	if(output <> "") ;switch output if set
	{
		SetDevice(output)
		if(loud)
			SoundPlay *-1
	}
	
	if(input <> "") ;switch input if set
	{ 
		KeyWait LWin ;windows key prevents changing tab for some reason, needs to be released
		BlockInput On ;prevent new inputs while sending, may be overkill, but seems to prevents some fringe cases
		controlsend,SysTabControl321, {ctrl down}{Tab}{ctrl up}, ahk_class #32770 ;next tab (inputs)
		BlockInput Off 
		
		SetDevice(input)
	}
	
	winclose, ahk_class #32770
}

SetDevice(device)
{
	ControlGet, len, List, Count, SysListView321, ahk_class #32770
	Loop %len%
	{
		controlsend, syslistview321, {down}, ahk_class #32770
		
		ControlGet, devices, List, Selected, SysListView321, ahk_class #32770
		deviceInfo := strSplit(devices, A_Tab)
		if(deviceInfo[1] = device)
		{
			shouldSet := deviceInfo[3] <> "Default Device"
			if(shouldSet)
				controlsend, Button2, {alt down}s{alt up}, ahk_class #32770
			return
		}
	}
}