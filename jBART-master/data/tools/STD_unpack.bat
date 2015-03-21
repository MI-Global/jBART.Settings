rem @echo off
cd %~dp0
chcp 1251
if (%1)==() (
	echo Need an img file to proceed...
		goto end
)
set OutDir=%2
if (%2)==() (
set OutDir=%~N1
)


setlocal enabledelayedexpansion
COLOR 0A
mode con:cols=128 lines=50



bin\sfk166.exe hexfind %1 -pat -bin /000000000000A0E10000A0E1/ -case >bin\offset.txt
bin\sfk166.exe hexfind %1 -pat -bin /000000001F8B08/ -case >>bin\offset.txt 
bin\sfk166.exe find bin\offset.txt -pat offset>bin\off2.txt
bin\sfk166.exe replace bin\off2.txt -binary /20/0A/ -yes

cls
echo Boot_Recovery_Repack by michfood Jan 2015
echo  STD_unpack.bat v4
echo.

if exist %OutDir% rd /s /q %OutDir% >nul

set /A N=0
:loop
FOR /F %%G IN (bin\off2.txt) DO (
	if !N!==1 (
		set /A ofs1=%%G
		set /A N+=1
	)
	if !N!==3 (
		set /A ofs2=%%G
		set /A N+=1
	)
	if !N!==5 (
		set /A ofs3=%%G+4
		set /A N+=1
	)	
	if `%%G` EQU `offset` (
		set /A N+=1
	)
)
FOR %%i IN (%1) DO ( set /A boot_size=%%~Zi )

set /A real_ofs=%ofs2%+4
md %OutDir%
echo.
set /A ps=%ofs1%+4
echo - pagesize        - %ps%
echo %ps%>%OutDir%\pagesize.txt
echo - size of image   - %boot_size% byte
echo - ram_disk offset - %real_ofs%
echo.
del bin\offset.txt
del bin\off2.txt

echo.
echo - split kernel...
bin\sfk166.exe partcopy %1 -fromto %ps% %real_ofs% %OutDir%\kernel -yes
echo.
echo - extract ram_disk.gz...
bin\sfk166.exe partcopy %1 -fromto %real_ofs% %boot_size% %OutDir%\ram_disk.gz -yes
echo.
echo - unpack ram_disk.gz...
bin\7z.exe -tgzip x -y %OutDir%\ram_disk.gz -o%OutDir% >nul
echo.
echo - unpack ram_disk.cpio...
md %OutDir%\rmdisk
cd %OutDir%
cd rmdisk
%~dp0bin\cpio.exe -i <../ram_disk
cd ..
cd ..
echo.
copy %1 %OutDir%  >nul 
echo.
echo - Done.
echo.
if exist "%OutDir%/kernel" (
	echo - %OutDir%/kernel exist.        Success.
) else (
	echo - %OutDir%/kernel do not exist. Fail.
)
if exist "%OutDir%/rmdisk" (
	echo - %OutDir%/rmdisk exist.        Success.
) else (
	echo - %OutDir%/rmdisk do not exist. Fail.
)
if exist "%OutDir%/rmdisk/*" (
	echo - %OutDir%/rmdisk is not empty. Success.
) else (
	echo - %OutDir%/rmdisk is empty.     Fail.
)
echo.
:end