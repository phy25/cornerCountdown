/*
Coded by Phy25.com as cornerCountdown, based on Countdown 1.0 aka How long till I go home?
 - by Bekihito, WTFPL licence (http://en.wikipedia.org/wiki/WTFPL)
 - many thanks to the authors and contributors of http://www.autohotkey.com/forum/viewtopic.php?t=19740&highlight=countdown
 - for inspiration and help with this variant
*/

SetBatchLines, -1
#SingleInstance, Force
#NoEnv
SetWorkingDir , %A_ScriptDir%
XI = %A_ScreenWidth%
YI = %A_ScreenHeight%.
SplitPath, A_ScriptName, , , , ScriptFileWOExt

IfExist %ScriptFileWOExt%.ini
{
  IniRead , Time, %ScriptFileWOExt%.ini, User, Time
  IniRead , MouseMode, %ScriptFileWOExt%.ini, User, MouseMode
  IniRead , EndRing, %ScriptFileWOExt%.ini, User, EndRing
  IniRead , FinalRing, %ScriptFileWOExt%.ini, User, FinalRing
  IniRead , FinalTime, %ScriptFileWOExt%.ini, User, FinalTime
}Else{
  Time = 30
  MouseMode := 0 ; 0 = no operation; 2 = click to trigger "stop" and "reset"
}

if 1 > 0
  Time = %1%

If 2 > 0
{
  if 2 < Time
  {
    FinalTime = %2%
  }
}


XInput := XI-200
YInput := 0
TimeNow := Time
State := 1 ; 1 = counting; 0 = paused

;On-screen display (OSD)
Gui +LastFound +AlwaysOnTop +Caption +ToolWindow +Resize
Gui, Color, White
Gui, Font, s120
Gui, Add , Text, x0 y0 h150 vMyTime Center gStop, %Time%

Gui, Show, x%XInput% y%YInput% h150 w200 NoActivate, 倒计时 #暂停 ; NoActivate avoids deactivating the currently active window.

Menu, boxContextCounting, add, 暂停(&P), Stop
Menu, boxContextCounting, default, 暂停(&P)
Menu, boxContextCounting, add, 重置(&R), Reset
Menu, boxContextCounting, add, 即点即停模式(&M), MouseModeToggle
Menu, boxContextCounting, add, 退出(&E), GuiClose
Menu, boxContextPaused, add, 继续(&P), Stop
Menu, boxContextPaused, default, 继续(&P)
Menu, boxContextPaused, add, 重置(&R), Reset
Menu, boxContextPaused, add, 即点即停模式(&M), MouseModeToggle
Menu, boxContextPaused, add, 退出(&E), GuiClose

; Create a window just to display some text:
Progress, m2 b Y100 fs18 zh0, 按鼠标左键开始计时, , , 宋体
KeyWait, LButton, D
Progress, Off
Gosub, WinTitleSync

SetTimer, UpdateOSD, 1000 ; Causes a subroutine to be launched automatically and repeatedly at a specified time interval.
Goto, MouseModeRun
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
      Gosub, UpdateOSDdefault
      If MouseMode = 2
      {
        Gosub, Reset
        Gosub, Stop
      }
      Else
      {
        ExitApp
      }
  }
  If(TimeNow <= FinalTime){
    IfExist %FinalRing%
      SoundPlay %FinalRing%
    Gui, Color, Red
    Gui, Font, cGreen ; 给窗口指定一个新的默认字体
    GuiControl, Font, MyTime  ; 使默认字体对控件生效
    SetTimer, UpdateOSDdefault, -300 ; prevention from conflict
  }
Return

UpdateOSDdefault:
  Gui, Color, White
  Gui, Font, cBlack
  GuiControl, Font, MyTime
Return

Stop:
  If State = 1
  {
    SetTimer, UpdateOSD, Off
    State := 0
  }
  Else
  {
    SetTimer, UpdateOSD, 1000
    State := 1
  }
  Gosub, WinTitleSync
Return

Reset:
  TimeNow := Time
  GuiControl,, MyTime, %TimeNow%
  If State = 0
  {
    Gosub, Stop
  }
Return

GuiClose: ;writes the settings into a ini file to get the position and continue count from last point (for long periods, endtimes where you had to shutdown the comp)
  IniWrite , %Time%, %ScriptFileWOExt%.ini, User, Time
  IniWrite , %MouseMode%, %ScriptFileWOExt%.ini, User, MouseMode
  ;IniWrite , %FianlTime%, %ScriptFileWOExt%.ini, User, FinalTime
  ExitApp
Return

MouseModeToggle:
  If MouseMode = 2 ;Off
  {
    MouseMode = 0
  }
  Else ;On
  {
    MouseMode = 2
  }
  Goto, MouseModeRun
Return

MouseModeRun:
  Gosub, WinTitleSync
  If MouseMode = 2
  {
    Menu, boxContextCounting, Check, 即点即停模式(&M)
    Menu, boxContextPaused, Check, 即点即停模式(&M)
    Goto, MouseMode2
  }
  Else
  {
    Menu, boxContextCounting, UnCheck, 即点即停模式(&M)
    Menu, boxContextPaused, UnCheck, 即点即停模式(&M)
  }
Return

WinTitleSync:
  If State = 0
  {
    Gui, Show, NA, 倒计时 #暂停
  }
  Else
  {
    If MouseMode = 2
    {
      Gui, Show, NA, 倒计时 #即点即停
    }
    Else
    {
      Gui, Show, NA, 倒计时
    }
  }
Return

MouseMode2:
  ; TODO: 如果从 GUI 暂停，可能还会出问题；要同步好
  If State = 0 ; 同步
  {
    Gosub, Stop
  }
  Sleep, 500 ; protection
  Loop
  {
    KeyWait, LButton, D
    If MouseMode != 2
      Break
    Gosub, Stop
    If State = 1
      Continue ; when paused before, let it start

    Sleep, 500 ; protection
    KeyWait, LButton, D
    If MouseMode != 2
      Break
    Gosub, Reset
    Sleep, 500 ; protection
  }
Return

GuiContextMenu:
  If State = 1
  {
    Menu, boxContextCounting, Show
  }
  Else
  {
    Menu, boxContextPaused, Show
  }
Return