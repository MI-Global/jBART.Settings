@echo off
set HomeDir=%~dp0..
set Stock=%HomeDir%\_stock

if "%1"=="" goto usage

mkdir %Stock%

echo.
echo Extracting build.prop from stock ROM...
echo.

%HomeDir%\7z e -y -o%Stock% %1 system\build.prop

call:getprop %Stock%\build.prop "ro.product.model" "" model
call:getprop %Stock%\build.prop "ro.product.brand" "" brand
call:getprop %Stock%\build.prop "ro.product.name" "" name

echo Found parameters:
echo.
echo ro.product.model = %model% 
echo ro.product.brand = %brand% 
echo ro.product.name  = %name% 
echo.
echo Writing to the file "%HomeDir%\data\patches\buildprop_patches.conf"
echo.

%HomeDir%\fnr --cl --dir "%HomeDir%\data\patches" --fileMask "buildprop_patches.conf" --useRegEx --find "{[\w\s \n\":.,-]*product[[\w\s \n\":.,-]*}[\s]*,[\s]*" --replace "" >nul
%HomeDir%\fnr --cl --dir "%HomeDir%\data\patches" --fileMask "buildprop_patches.conf" --useRegEx --find "\"miui_v4\"[\s:]+\[" --replace "\"miui_v4\":[\n{\n \"Key\":\"ro.product.model\", \n \"Value\":\"%model%\", \n \"Description\":\"\", \n \"Enabled\":true \n},\n{\n \"Key\":\"ro.product.brand\", \n \"Value\":\"%brand%\", \n \"Description\":\"\", \n \"Enabled\":true \n},\n{\n \"Key\":\"ro.product.name\", \n \"Value\":\"%name%\", \n \"Description\":\"\", \n \"Enabled\":true \n}," >nul

del /F /Q %Stock%\build.prop

echo.
echo buildprop_patches done!
echo.
echo.
pause
goto end 

:usage
echo.
echo            How to use this file:
echo.
echo.
echo.
echo    Type "%~dp0BuildProp_parse.bat Full_Path\Your_Stock_ROM.zip"
echo.
echo.   e.g. %~dp0BuildProp_parse.bat %~dp0update.zip
echo.
echo.
echo.
pause
goto end

:getprop
FOR /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') DO set %~4=%%~j

:end