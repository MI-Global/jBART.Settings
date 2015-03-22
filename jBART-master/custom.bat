@echo off
rem __________________________________________________________________________________________
rem THIS FILE IS LAUNCHING BY jBART BEFORE PACKING ROM ZIP. IT CAN BE EMPTY.
rem YOU CAN USE THIS BAT TO REPLACE, COPYING, REMOVING ANY FILES IN BASEROM FOLDER.
rem YOU CAN SEARCH AND REPLACE ANY STRINGS IN BUILD.PROP OR OTHER CONFIG FILES USING fnr.exe.
rem __________________________________________________________________________________________

set HomeDir=%CD%\_temp
for /f "delims=" %%x in ('dir /od /b miui_HMNoteW_*.bzprj') do set ROM=%%x

echo Patching ROM - %ROM%

set ROM=%HomeDir%\%ROM%\baseROM

set OLDVER1="5.2.13"
set OLDVER2="150213"

set INIFILE=%ROM%\system\build.prop

rem Getting new version from build.prop file
call:getversion %ROM%\system\build.prop "ro.build.version.incremental" "" NEWVER1
goto:getverison2

:getversion
FOR /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') DO set %~4=%%~j

:getversion2
for /f "tokens=1,2,3 delims=. " %%a in ("%NEWVER1%") do set year=%%a&set month=%%b&set day=%%c

if %month:~-1% == %month:~0,1% (set month=0%month%)
if %day:~-1% == %day:~0,1% (set day=0%day%)

rem %NEWVER1% variable is new MIUI version looks like 5.3.20
set NEWVER1="%NEWVER1%"

rem %NEWVER2% variable is new MIUI UTC time looks like 150320
set NEWVER2="1%year%%month%%day%"

echo Replacing old version - %OLDVER1%
echo With new version - %NEWVER1%

echo ---===**** ::::    Replacing version in ROM.OTA.PROP file...    ::::****===--- 
fnr.exe --cl --dir "%ROM%" --fileMask "*.prop" --includeSubDirectories --find %OLDVER1% --replace %NEWVER1% 
fnr.exe --cl --dir "%ROM%" --fileMask "*.prop" --includeSubDirectories --find %OLDVER2% --replace %NEWVER2% 
