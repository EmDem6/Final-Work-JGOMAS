
start /B OurManager8.bat
@timeout 5
start /B OurLauncher8.bat
@cd ../render/w32
@timeout 5
@run_jgomasrender