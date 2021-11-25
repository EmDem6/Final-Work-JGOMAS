
start /B OurManager1.bat
@timeout 5
start /B OurLauncher1.bat
@cd ../render/w32
@timeout 5
@run_jgomasrender