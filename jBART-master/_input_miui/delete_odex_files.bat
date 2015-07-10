@echo off
if "%1"=="" goto usage
7za d %1 *.odex -r -y 
goto end

:usage
echo.
echo            How to use this file:
echo.
echo.
echo Type delete_odex_files.bat [path][input_miui_ROM].zip
echo.
echo.
echo.
:end
pause
