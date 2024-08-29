A_HotkeyInterval := 100
; vi like key
; Ctrl key move Cursor Control Keys
^h::
{
	Send "{LEFT}"
}

^j::
{
	Send "{DOWN}"
}

^k::
{
	Send "{UP}"
}

^l::
{
	Send "{Right}"
}

; Ctrl plus shift key is select move Cursor
+^h::
{
	Send "+{LEFT}"
}

+^j::
{
	Send "+{DOWN}"
}

+^k::
{
	Send "+{UP}"
}

+^l::
{
	Send "+{Right}"
}
