
start /B OurManager.bat
@timeout 5
start /B OurLauncher.bat
@cd ../render/w32
@timeout 5
@run_jgomasrender