@echo off
if "%1"=="" goto usage
..\7z d %1 *.odex -r -y 
goto end

:usage
echo.
echo            How to use this file:
echo.
echo.
echo Type deodex.bat [path][input_miui_ROM].zip
echo.
echo.
echo.
:end
pause
