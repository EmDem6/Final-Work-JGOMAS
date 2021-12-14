start /B default_manager.bat
@timeout 5
start /B L_Medics_vsBait.bat
@cd ../render/w32
@timeout 5
@run_jgomasrender