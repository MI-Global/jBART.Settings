@echo off
set HomeDir=%CD%\..
set Stock=%CD%\..\_stock
set Miui=%CD%\..\_input_miui
set Tools=%CD%\..\data\tools

if "%1"=="" goto usage
for /f "delims=" %%x in ('dir /od /b %Miui%\*.zip') do set MIUIROM=%%x
if "%MIUIROM%"=="" goto usage

echo Deleting old folder "%Stock%"...
echo. 

set MIUIROM=%Miui%\%MIUIROM%

rmdir /S /Q %Stock% 
mkdir %Stock%

echo Extracting files from your stock rom to folder "%Stock%"...
echo. 

%HomeDir%\7z x -y -o%Stock% %1 @%2

echo Start repacking Boot.img...
echo. 

ren %Stock%\boot.img boot_stock.img
move /Y %Stock%\boot_stock.img %Tools%\boot_stock.img

cd %Tools%
call %Tools%\MTK_unpack.bat boot_stock.img

%HomeDir%\7z x -y -o%Miui% %MIUIROM% boot.img

ren %Miui%\boot.img boot_MIUI.img

move /Y %Miui%\boot_MIUI.img %Tools%\boot_MIUI.img

call %Tools%\MTK_unpack.bat boot_MIUI.img 

copy /Y %Tools%\boot_stock\kernel* %Tools%\boot_MIUI\

call %Tools%\MTK_pack.bat boot_MIUI
cd %~dp0
move /Y %Tools%\new_image.img %Stock%\boot.img
pause
del %Tools%\*.img
rmdir /S /Q %Tools%\boot_stock
rmdir /S /Q %Tools%\boot_MIUI

echo Repacking Boot.img finished... 
echo. 
echo Starting parsing build.prop...

call %~dp0BuildProp_parse.bat %~dpnx1

if "%~nx2"=="Port_mt6592.cfg" goto mt6592

goto end

:mt6592
echo.
echo Determine device platform as MT6592... 
echo. 
mkdir %HomeDir%\_local_repo\replace\device\lcsh92_wet_jb9
xcopy %Stock%\* %HomeDir%\_local_repo\replace\device\lcsh92_wet_jb9 /R /Y /E 
echo All nessesary files for porting were placed to folder: 
echo.
echo "%HomeDir%\_local_repo\replace\device\lcsh92_wet_jb9"
echo.
echo.
echo Now you can build MIUI by running file "Recompile.bat"
echo.
echo.
pause
goto end

:usage
echo.
echo            How to use this file:
echo.
echo.
echo 1. Place original MIUI ROM to _input_miui folder.
echo.
echo.
echo 2. Type "~dp0Port_Your_ROM.bat Full_Path\Your_Stock_ROM.zip Full_Path\Port_[platform].cfg"
echo.
echo.   e.g. %~dp0Port_Your_ROM.bat %~dp0update.zip %~dp0Port_mt6592.cfg
echo.
echo.
echo.
pause

:end
