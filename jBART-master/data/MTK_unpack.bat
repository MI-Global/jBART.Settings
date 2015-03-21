@echo off

cd %~dp0
chcp 1251
if (%1)==() (
	echo Select image
		goto end
)
set OutDir=%2
if (%2)==() (
set OutDir=%~N1
)


setlocal enabledelayedexpansion
COLOR 0A
mode con:cols=128 lines=50
rem находим смещение kernel 
bin\sfk166.exe hexfind %1 -pat -bin /88168858/ -case >bin\offset.txt
rem находим смещение ram_disk.gz
bin\sfk166.exe hexfind %1 -pat -bin /FFFFFFFF1F8B08/ -case >>bin\offset.txt 
rem очищаем результаты поиска
bin\sfk166.exe find bin\offset.txt -pat offset>bin\off2.txt
bin\sfk166.exe replace bin\off2.txt -binary /20/0A/ -yes
cls

echo Boot_Recovery_Repack by michfood Jan 2015
echo  MTK_unpack.bat v4
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
echo.
echo - size of %1 %boot_size% byte
echo - kernel offset     - %ofs1%
echo - ram_header offset - %ofs2%
echo - ram_disk offset   - %ofs3%
echo.

del bin\offset.txt
del bin\off2.txt
md %OutDir%
echo - extracting kernel_header...
bin\sfk166.exe partcopy %1 -fromto 0x0 %ofs1% %OutDir%\kernel_header -yes
echo.
echo - extracting kernel...
bin\sfk166.exe partcopy %1 -fromto %ofs1% %ofs2% %OutDir%\kernel -yes
echo.
echo - extracting ram_header...
bin\sfk166.exe partcopy %1 -fromto %ofs2% %ofs3% %OutDir%\ram_header -yes
echo.
echo - extracting ram_disk...
bin\sfk166.exe partcopy %1 -fromto %ofs3% %boot_size% %OutDir%\ram_disk.gz -yes
echo.
echo - unpack ram_disk.gz...
bin\7z.exe -tgzip x -y %OutDir%\ram_disk.gz -o%OutDir%\gz >nul
move %OutDir%\gz\* %OutDir%\ram_disk>>nul
rd %OutDir%\gz
echo.
echo - unpack ram_disk.cpio...
md %OutDir%\rmdisk
cd %OutDir%
cd rmdisk
%~dp0bin\cpio.exe -i <../ram_disk
cd ..
cd ..
copy %1 %OutDir%/%1>>nul
echo.
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