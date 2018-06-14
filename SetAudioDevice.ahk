#SingleInstance Force
#UseHook On
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

#h:: selectAudioDevice(1, 1, true) ; headset
#s:: selectAudioDevice(2, 2) ; Speakers
;#b:: selectAudioDevice(-5, 2) ; aux out

; Usage: selectAudioDevice(Output, Input=0, Loud = false)
;  Output - is desired output device where the first listed = 1
;  Input  - is desired input device "                        "
;  Loud   - if true, will cause alert sounds if device is already active, but run faster
;			also disables pushing window to back, does not cooperate when closed too quickly
;           Note: does not casue any sounds if device was not already active
;
; negative numbers can be used to count up from the bottom where the last item = -1
; values may be set to 0 to skip setting that device.
; this may allow more reliability on systems where the available devices may change

SelectAudioDevice(devicenumber, inputdevice := 0, loud := false)
{
	WinGet, cur, ID, A ;save active window
	
	;close window if already open to start from known state
	WinClose, ahk_class #32770
	WinWaitClose, ahk_class #32770
	run, mmsys.cpl
	winwait, ahk_class #32770
	
	WinActivate, ahk_id %cur% ;reactivate active window to minimize side effects
	
	if(!loud)
		winset, bottom,, ahk_class #32770 ;Optional, still appears on open
		;this doesn't work well when closed too soon after called, so only quiet mode
		
	;sleep, 300 ;may improve reliability on slower systems, should not be needed
	
	if(devicenumber != 0) ;switch output if set
	{
		SetDevice(devicenumber, loud)
	}
	
	if(inputdevice != 0) ;switch input if set
	{ 
		KeyWait LWin ;windows key prevents changing tab for some reason, needs to be released
		BlockInput On ;prevent new inputs while sending, may be overkill, but seems to prevents some fringe cases
		controlsend,SysTabControl321, {ctrl down}{Tab}{ctrl up}, ahk_class #32770 ;next tab (inputs)
		BlockInput Off 
		
		sleep, 100 ;doesn't always accept input right away, wait a bit
		SetDevice(inputdevice, loud)
	}
	
	winclose, ahk_class #32770
}

SetDevice(num, loud)
{
	if(num >= 0) ;nth device counting down from top
	{
		loop, %num%
		{
			controlsend, syslistview321, {down}, ahk_class #32770
		}
	}
	else ;-nth device counting up from bottom
	{
		controlsend, syslistview321, {end}, ahk_class #32770
		num := (-num) - 1
		loop, %num%
		{
			controlsend, syslistview321, {up}, ahk_class #32770
		}
	}
	
	if(!loud)
	{
		sleep, 300 ;wait for button state to update
		ControlGet, shouldSet, Enabled,, Button2, ahk_class #32770
	}
	if(loud || shouldSet) ;prevents alerts if button disabled (already active device)
		controlsend, Button2, {alt down}s{alt up}, ahk_class #32770
	;sleep, 300 ;pause to see the selected output
}
