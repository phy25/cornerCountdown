/*
Countdown 1.0 aka How long till I go home?
by Bekihito, WTFPL licence (http://en.wikipedia.org/wiki/WTFPL)
many thanks to the authors  and contributors of http://www.autohotkey.com/forum/viewtopic.php?t=19740&highlight=countdown
for inspiration and help with this variant

Modified by Phy25.com
*/

SetBatchLines, -1
#SingleInstance, Force
#NoEnv
SetWorkingDir , %A_ScriptDir%
XI = %A_ScreenWidth%
YI = %A_ScreenHeight%

if (FileExist("CountSet.ini")){
    IniRead , Time, CountSet.ini, User, Time
    IniRead , EndRing, CountSet.ini, User, EndRing
    IniRead , FinalRing, CountSet.ini, User, FinalRing
    IniRead , FinalTime, CountSet.ini, User, FinalTime
    }Else{
        Time = 30
    }

if 1 > 0
  Time = %1%

if 2 < Time
{
If 2 > 0
{
  FinalTime = %2%
}
}


XInput := XI-200
YInput := 0
TimeNow := Time
Mode := 1
;On-screen display (OSD)
Gui +LastFound +AlwaysOnTop +Caption +ToolWindow +Resize
Gui, Color, White
Gui, Font, s120
Gui, Add , Text, x0 y0 h150 vMyTime Center gStop, %Time%

Gui, Show, x%XInput% y%YInput% h150 w200 NoActivate, 倒计时 ; NoActivate avoids deactivating the currently active window.

; Create a window just to display some 18-point Courier text:
Progress, m2 b fs18 zh0, 按鼠标左键开始计时, , , 宋体
KeyWait, LButton, D
Progress, Off

SetTimer, UpdateOSD, 1000 ; Causes a subroutine to be launched automatically and repeatedly at a specified time interval.

Return ; // End of Auto-Execute Section


UpdateOSD:
TimeNow := TimeNow - 1
GuiControl,, MyTime, %TimeNow%
If (TimeNow=0){
    Gui, Color, Red
    SetTimer, UpdateOSD, Off
    IfExist %EndRing%
      SoundPlay %EndRing%, WAIT
    Sleep, 1000
    ExitApp
}
If(TimeNow <= FinalTime){
  IfExist %FinalRing%
    SoundPlay %FinalRing%
  Gui, Color, Red
  Gui, Font, cGreen ; 如果需要，使用类似这样的排列方式给窗口指定一个新的默认字体。
  GuiControl, Font, MyTime  ; 使上面的字体对控件生效。
  Sleep, 500
  Gui, Color, White
  Gui, Font, cBlack ; 如果需要，使用类似这样的排列方式给窗口指定一个新的默认字体。
  GuiControl, Font, MyTime  ; 使上面的字体对控件生效。
}
Return

Stop:
If Mode = 1
{
  SetTimer, UpdateOSD, Off
  Mode := 0
}
Else
{
  SetTimer, UpdateOSD, 1000
  Mode := 1
}
Return

GuiClose: ;writes the settings into a ini file to get the position and continue count from last point (for long periods, endtimes where you had to shutdown the comp)
IniWrite , %Time%, %A_ScriptDir%\CountSet.ini, User, Time
;IniWrite , %FianlTime%, %A_ScriptDir%\CountSet.ini, User, FinalTime
ExitApp