/*
Ngrok menu:
*/
;//////////////[Start settings]///////////////
SendMode Input
SetWorkingDir %A_ScriptDir%
;###
#NoEnv
#SingleInstance Force
;____________________________________________________________
;//////////////[vars]///////////////
version = 0.941
if FileExist("Ngrok_config.ini")
{
    IniRead, Ngrok_port, %A_WorkingDir%\Ngrok_config.ini, Port_Region_Protc,port,25565
    IniRead, ngrok_region, %A_WorkingDir%\Ngrok_config.ini, Port_Region_Protc,reg,-region eu
    IniRead, Ngrok_protc, %A_WorkingDir%\Ngrok_config.ini, Port_Region_Protc,protocol,tcp
    IniRead, Ngrok_custom, %A_WorkingDir%\Ngrok_config.ini, custom,custom,ngrok tcp -region eu 25565
    IniRead, ngrok_location, %A_WorkingDir%\Ngrok_config.ini, location,location,null
}
Else
{
    ngrok_location := "null"
    ngrok_region := "-region eu"
    Ngrok_protc := "tcp"
    Ngrok_port := "25565"
    Ngrok_custom := "ngrok tcp -region eu 25565"
}
;remove old file if found
if FileExist("Old_Ngrok.ahk")
{
    FileDelete, %A_ScriptDir%\Old_Ngrok.ahk
}
;____________________________________________________________
;//////////////[Gui]///////////////
;ngrok
Gui Add, Tab3, x0 y0 w321 h153, Ngrok|Settings
Gui Tab, 1
Gui Add, Edit, x56 y32 w60 h21 gSubmit vNgrok_port, %Ngrok_port%
Gui Font, s13
Gui Add, Text, x8 y32 w40 h23, Port:
Gui Font
Gui Add, Edit, x120 y32 w120 h21 gSubmit vNgrok_protc, %Ngrok_protc%
Gui Font, s11
Gui Add, Button, x240 y32 w67 h22 gNgrok_start, Start
Gui Font
Gui Add, Edit, x8 y56 w202 h21 gSubmit vNgrok_region, %ngrok_region%
;custom
Gui Add, Text, x8 y80 w68 h17, Custom:
Gui Add, Edit, x1 y104 w317 h22 gSubmit vNgrok_custom, %Ngrok_custom%
Gui Add, Button, x224 y80 w91 h23 gNgrok_start_custom, Start (Custom)
;Settings tab
Gui Tab, 2
Gui Add, Button, x208 y24 w103 h23 gShortcut_to_desktop, Shortcut to desktop
Gui Add, Text, x8 y24 w97 h23 +0x200, Ngrok.exe location:
Gui Add, Link, x120 y32 w84 h20, <a href="https://ngrok.com/download">Download ngrok</a>
Gui Add, Edit, x8 y48 w304 h21 gSubmit vngrok_location, %ngrok_location%
Gui Font, s13
Gui Add, Button, x8 y72 w113 h27 gSave_location, Save location
Gui Font
Gui Add, Button, x120 y72 w120 h23 gPick_location, Pick location(Folder)
Gui Add, Button, x8 y104 w189 h23 gSave_protoc, Save current port, protocol and region
Gui Add, Button, x240 y72 w79 h23 gSave_Custom, Save Custom
Gui Add, CheckBox, x200 y104 w120 h23 vcheckup +Checked +Disabled, Check for updates   ;gAutoUpdates

Gui Show, w318 h134, Ngrok Menu
;____________________________________________________________
;//////////////[Check for updates]///////////////
IfExist, %A_ScriptDir%\%appfoldername%\Settings\Settings.ini
{
    IniRead, t_checkup, %A_ScriptDir%\%appfoldername%\Settings\Settings.ini, Settings, Updates
    if(t_checkup == 1)
    {
        goto checkForupdates
    }
}else
{
    goto checkForupdates
}
Return
;Gui menu return
Return
;____________________________________________________________
;//////////////[Submit]///////////////
Submit:
Gui, Submit, Nohide
return
;____________________________________________________________
;//////////////[Exit app]///////////////
GuiEscape:
GuiClose:
    ExitApp
;____________________________________________________________
;//////////////[Buttons]///////////////
;Ngrok
Ngrok_start:
testlocation = %ngrok_location%\ngrok.exe
if (ngrok_location == "null" or ngrok_location == "")                                 ;if ngrok location is not set give error
{
    MsgBox, 0, Error, Ngrok.exe location is not set. `n`nSet the location from settings
}
Else if (!FileExist(testlocation))
{
    MsgBox, 0, Error, Ngrok.exe not found in location. `n`nSet new location from settings
}
Else
{
    Run,%ComSpec%,%ngrok_location%                          ;Run ngrok
    WinWait, ahk_class ConsoleWindowClass                   ;wait for ngrok console
    ngrok_comm = %Ngrok_protc% %ngrok_region% %Ngrok_port%  ;Set port, protocol and region to variable
    send, ngrok %ngrok_comm%                                ;Write the command
    send, {Enter}                                           ;Send enter
}
return
;Ngrok custom:
Ngrok_start_custom:
testlocation = %ngrok_location%\ngrok.exe
if (ngrok_location == "null" or ngrok_location == "")                                 ;if ngrok location is not set give error
{
    MsgBox, 0, Error, Ngrok.exe location is not set. `n`nSet the location from settings
}
Else if (!FileExist(testlocation))
{
    MsgBox, 0, Error, Ngrok.exe not found in location. `n`nSet new location from settings
}
Else
{
    Run,%ComSpec%,%ngrok_location%
    WinWait, ahk_class ConsoleWindowClass
    ngrok_comm = %Ngrok_custom%
    send, %ngrok_comm%
    send, {Enter}
}
return
;Shortcut
Shortcut_to_desktop:
FileCreateShortcut,"%A_ScriptFullPath%", %A_Desktop%\Ngrok.lnk
return
;Save current port, protocol and region
Save_protoc:
IniWrite, %Ngrok_port%, %A_WorkingDir%\Ngrok_config.ini, Port_Region_Protc,port
IniWrite, %ngrok_region%, %A_WorkingDir%\Ngrok_config.ini, Port_Region_Protc,reg
IniWrite, %Ngrok_protc%, %A_WorkingDir%\Ngrok_config.ini, Port_Region_Protc,protocol
return
;Save Custom
Save_Custom:
IniWrite, %Ngrok_custom%, %A_WorkingDir%\Ngrok_config.ini, custom,custom
return
;Save location
Save_location:
IniWrite, %ngrok_location%, %A_WorkingDir%\Ngrok_config.ini, location,location
return
;Pick location
Pick_location:
FileSelectFolder, SelectedFile, 3, , Open a file, Ngrok exe (*.exe)
if (SelectedFile = "")
    MsgBox, The user didn't select anything.
else
{
    ngrok_location = %SelectedFile%
    GuiControl, 1:,ngrok_location,%ngrok_location%
}
return
;____________________________________________________________
;____________________________________________________________
;//////////////[checkForupdates]///////////////
checkForupdates:
whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", "https://raw.githubusercontent.com/veskeli/NgrokAhk/master/Version.txt", False)
whr.Send()
whr.WaitForResponse()
newversion := whr.ResponseText
if(newversion != "")
{
    if(newversion => version)
    {
        MsgBox, 1,Update,New version is  %newversion% `nOld is %version% `nUpdate now?
        IfMsgBox, Cancel
        {
            ;temp stuff
        }
        else
        {
            ;Download update
            FileMove, %A_ScriptFullPath%, %A_ScriptDir%\Old_%A_ScriptName%, 1
            sleep 1000
            UrlDownloadToFile, https://raw.githubusercontent.com/veskeli/NgrokAhk/master/Ngrok.ahk, %A_ScriptFullPath%
            Sleep 1000
            loop
            {
                IfExist %A_ScriptFullPath%
                {
                    Run, %A_ScriptFullPath%
                    ExitApp
                }
            }
        }
    }
}
return
