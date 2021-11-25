
start /B OurManager14.bat
@timeout 5
start /B OurLauncher14.bat
@cd ../render/w32
@timeout 5
@run_jgomasrender