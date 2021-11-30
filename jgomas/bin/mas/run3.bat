
start /B OurManager3.bat
@timeout 5
start /B OurLauncher3.bat
@cd ../render/w32
@timeout 5
@run_jgomasrender