
start /B OurManager14.bat
@timeout 5
start /B OurLauncherDefault.bat
@cd ../render/w32
@timeout 5
@run_jgomasrender