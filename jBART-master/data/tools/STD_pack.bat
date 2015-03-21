@echo off
cd %~dp0
chcp 1251
if (%1)==() (
	echo Select folder.
	goto end
)
setlocal enabledelayedexpansion
COLOR 0A
mode con:cols=128 lines=50

echo Boot_Recovery_Repack by michfood Jan 2015
echo  MTK_pack.bat v4
echo.

set pt=%~N1%~X1
echo Input folder - %1
echo.
cd %pt%
%~dp0bin\chmod og=xr rmdisk
cd rmdisk
echo.
echo - pack rmdisk to cpio...
%~dp0bin\find . | %~dp0bin\cpio.exe -o -H newc -F ../new_ram_disk >nul
move ..\ram_disk ..\ram_disk_old >nul
move ..\new_ram_disk ..\ram_disk>nul
echo.
echo - pack rmdisk.cpio to gzip...
%~dp0bin\gzip -n -f ../ram_disk

rem set BASE="0x$(od -A n -h -j 34 -N 2 ./boot.img|sed 's/ //g')0000"
rem set CMDLINE="$(od -A n --strings -j 64 -N 512 ./boot.img)"
echo.
echo - make image file...
FOR /F  %%i IN (../pagesize.txt) DO (set ps=%%i)
rem echo.
rem echo - pagesize %ps%
rem echo.
%~dp0bin\mkbootimg.exe --pagesize %ps% --kernel ../kernel --ramdisk ../ram_disk.gz -o ../new_image.img 
copy ..\new_image.img %~dp0\new_image.img  >nul 
move ..\ram_disk_old ..\ram_disk >nul
cd ..
cd ..
echo.
echo - Done.
echo.
if exist "new_image.img" (
	echo - New image saved as new_image.img. Success.
) else (
	echo - New image did not created.     Fail.
)
echo.
:end

