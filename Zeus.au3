#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         Karthik

 Script Function:
	Template AutoIt script.
#ce ----------------------------------------------------------------------------

#pragma compile(ProductVersion, 1.2)
#pragma compile(ProductName, Zeus)
#pragma compile(FileVersion, 1.1.0.33)

#include <Misc.au3>
#include<array.au3>
#include<MsgBoxConstants.au3>
#include "include\toast.au3"

global $Hotkeys[30][4]
$ind=0

;Make sure that only one instance is running.

$Configuration_File="Config.ini"

if _Singleton("Zeus",1)=0 Then
   msgbox(16,"Zeus Conflict Detected!!","Another Instance is Already Running!!  Please Close it from the Systemtray")
   exit
EndIf

changeDir()

addtoStartup()

loadConfig()

func changeDir()
   if $CmdLine[0]>0 Then
	  FileChangeDir($CmdLine[1])
   EndIf
   EndFunc
func exit_func()
   ExitZeus()
   exit
   endfunc

;Zeus Reserved Hotkeys . Even if you set it will be overrided .

func baseHotKeySetup()
HotKeySet("^{END}",exit_func)
HotKeySet("^{PGUP}",loadConfig)
HotKeySet("^{PGDN}",unload_hotkeys)
EndFunc

;Loop forever

while 1
   sleep(400)
WEnd

func loadConfig()

   if FileExists($Configuration_File)<>1 Then
	  msgbox(16,"Zeus Exiting!..","Config.ini File Not Found!!")
	  Exit
   EndIf
   local $IniSections=IniReadSectionNames($Configuration_File)
   if UBound($IniSections)<1 Then
	  msgbox(48,"Zeus Exiting..","Config File Empty!!.")
	  exit
   EndIf
_Toast_Set(5, 0x607D8B, 0xECEFF1, 0xF5F5F5, 0x2f96b4, 10, "Arial")
local $aRet = _Toast_Show(0, "Zeus V2","Loading Configurations from File "&@WorkingDir&"\Config.ini"&@crlf&@crlf&@crlf&@crlf,0)
local $status=GUICtrlCreateLabel("Loading Hotkeys and Executables Information..",10,100)
GUICtrlSetColor($status,0x2f96b4)
local $Progress = GUICtrlCreateProgress(10, 65, $aRet[0] - 20, 20)
GUICtrlSetColor($Progress, 32250)
local  $inccount=100/$IniSections[0]
local $percentage=0
   for $iter=1 to $IniSections[0]
	  local $exe=IniRead($Configuration_File,$IniSections[$iter],"Executable","")
	  local $param=IniRead($Configuration_File,$IniSections[$iter],"Parameters","")
	  local $workingDir=IniRead($Configuration_File,$IniSections[$iter],"Directory","")
	  if $exe=="" Then
		GUICtrlSetData($status,"No Exe found For Hotkey "&$IniSections[$iter])
		 GUICtrlSetColor($Progress, 0xFDD835)
		sleep(500)
	  Else
		$Hotkeys[$ind][0]=$IniSections[$iter]
		$Hotkeys[$ind][1]=$exe
		$Hotkeys[$ind][2]=$param
		$Hotkeys[$ind][3]=$workingDir
		if StringUpper($exe)=="ZEUSREAD" Then
		 $Hotkeys[$ind][3]=IniRead($Configuration_File,$IniSections[$iter],"Delay","")
		 EndIf
		HotKeySet($IniSections[$iter],"Execute_Exe")
		GUICtrlSetData($status,"Hotkey Set for "&$IniSections[$iter])
		$ind+=1

	 EndIf
	  $percentage+= $inccount
	  updateProgress($Progress,$percentage)
   Next
   baseHotKeySetup();overrided to prevent users from using the Zeus HotKeySet
   GUICtrlSetData($status,"Total Hotkeys Set = "& $ind)
   sleep(1000)
   GUICtrlSetData($status,"Press CTRL+END to Quit")
   sleep(1000)
 _Toast_Hide()
   EndFunc

func Execute_Exe()
    Local $HotKey = @HotKeyPressed
	for $iter=0 to  $ind
	   if $hotkeys[$iter][0]=$Hotkey then
		 if StringUpper($hotkeys[$iter][1])=="ZEUSREAD" Then
			readAndSendfile($hotkeys[$iter][2],$hotkeys[$iter][3])
			ExitLoop
		 EndIf
		  ShellExecute($hotkeys[$iter][1],$hotkeys[$iter][2],$hotkeys[$iter][3])
		  ExitLoop
	   EndIf
	Next
	EndFunc

func unload_hotkeys()
_Toast_Set(5, 0x607D8B, 0xECEFF1, 0xF5F5F5, 0x2f96b4, 10, "Arial")
local $aRet = _Toast_Show(0, "Zeus V2","Unloading Configurations and DeRegistering HotKeys"&@crlf&@crlf&@crlf&@crlf,0)
local $status=GUICtrlCreateLabel("Unloading Hotkeys and Executables Information..",10,100)
GUICtrlSetColor($status,0x2f96b4)
local $Progress = GUICtrlCreateProgress(10, 65, $aRet[0] - 20, 20)
GUICtrlSetColor($Progress, 0xFB8C00)
local  $inccount=100/$ind
local $percentage=0
   for $iter=0 to  $ind-1
		 HotKeySet($Hotkeys[$iter][0])
		 $percentage+= $inccount
		 updateProgress($Progress,$percentage)
		 GUICtrlSetData($status,"Unregistered "&$Hotkeys[$iter][0])
	  Next
	  _toast_hide()
	  $ind=0
	  baseHotKeySetup();overrided to prevent users from using the Zeus HotKeySet
   EndFunc

   func readAndSendfile($path,$sleep)
	  local $sleep_time=200
	  if Number($sleep)<>0 Then
		 $sleep_time=Number($sleep)
	  EndIf
	  if $path=="" Then
		 msgbox(16,"Zeus Error!..","No Input File Specified !..")
		 Return
	  EndIf
	  local $fp=FileOpen($path)
	  if $fp<0 then
	  msgbox(16,"can't Open file","Error in Opening File "&$path)
	  Return
   EndIf
   local $content=fileread($path)
   $lines=StringSplit($content,@lf)
   local $iterx=0
   for $iterx=1 to $lines[0]
	  send($lines[$iterx],1)
	  sleep($sleep_time)
   Next
   Return
   EndFunc

;Adds our exe to the windows startup

;You may wonder why i have added the current directory to the registry.

;The answer is ,we are installed at say XYZ dir and all our files are present under dir XYZ

; when the Windows boots up , it will execute the exe with the 'system32' as base dir.

;We don't know where our files are present , so we make ourself to get notified about our installed path by writing it to registry and passing it to ourself.


   func addtoStartup()
  local  $key=RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\run","Zeus")
   if not @error and $key <>"" Then
	  if StringCompare($key,'"'&@autoitExe&'" "'& @WorkingDir&'"',0)<>0 Then
		 msgbox(48,"Caution!!.","Zeus Configured With Invalid Startup Path ")
	  Else
		 return
		 EndIf
	  EndIf
	  local $option=msgbox(4,"Configure Zeus","Would you like to add Zeus to Startup")
	  if $option<>$IDYes Then
		 Return
		 EndIf
	  if RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\run","Zeus","REG_SZ",'"'&@AutoItExe&'" "'& @WorkingDir&'"')==0 Then
		 msgbox(16,"Error","Adding to Startup Failed !!")
	  Else
		 msgbox(64,"Success!!","Added To Startup Succesfully")
		 EndIf
	  EndFunc
;Exit Zeus
func ExitZeus()
_Toast_Set(5, 0x607D8B, 0xECEFF1, 0xF5F5F5, 0x2f96b4, 10, "Arial")
local $aRet = _Toast_Show(0, "Zeus V2","Unloading Configurations and DeRegistering HotKeys"&@crlf&@crlf&@crlf&@crlf,0)
local $status=GUICtrlCreateLabel("Exiting...",10,100)
GUICtrlSetColor($status,0x2f96b4)
local $Progress = GUICtrlCreateProgress(10, 65, $aRet[0] - 20, 20)
GUICtrlSetColor($Progress, 0xF44336)
for $iter=0 to 100
   GUICtrlSetData($progress,$iter)
   sleep(50)
   Next
EndFunc

func updateProgress($Control,$val)
   $current_Val=guictrlread($Control)
   for $iter=$current_Val to $val
	  GUICtrlSetData($Control,$iter)
	  sleep(50)
	  Next
EndFunc
