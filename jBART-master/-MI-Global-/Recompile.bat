@echo off
echo Creating temporary dir...
cd ..
set HomeDir=%CD%

rmdir /S /Q %HomeDir%\_temp

mkdir %HomeDir%\_temp
copy /Y data\settings\repo.miui.v6.*.conf %HomeDir%\_temp\
echo Copying temporary files...
 
fnr --cl --dir "%HomeDir%\data\settings" --fileMask "repo.*.conf" --useRegEx --find "folder::[\S]*_local_repo" --replace "folder:://%HomeDir%\_local_repo" >nul
fnr --cl --dir "%HomeDir%\_temp" --fileMask "repo.*.conf" --useRegEx --find "#[ \S]*[\n]*" --replace "" >nul
fnr --cl --dir "%HomeDir%\_temp" --fileMask "repo.*.conf" --useRegEx --find "=[ \S]*[\n]*" --replace " " >nul

set /p RepoMain=<%HomeDir%\_temp\repo.miui.v6.main.conf
set RepoMain=%RepoMain:~0,-1%
set /p RepoPatch=<%HomeDir%\_temp\repo.miui.v6.patch.conf
set RepoPatch=%RepoPatch:~0,-1%
set /p RepoExtra=<%HomeDir%\_temp\repo.miui.v6.extra.conf
set RepoExtra=%RepoExtra:~0,-1%

del /Q /F %HomeDir%\_temp\repo.*.conf

java -jar jbart2a.jar recompile -romsdir _input_miui -autodeodex -outputdir _output_miui -workingdir _temp -timezone Europe/Moscow -locale en_US -repomain "%RepoMain%" -repopatch "%RepoPatch%" -repoextra "%RepoExtra%" >>log.txt

pause

