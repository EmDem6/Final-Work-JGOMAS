set rutaAxis="srcLucky"
set tipoAxis=%rutaAxis%"/jasonAgent_AXIS.asl"
set tipoAllied="jasonAgent_ALLIED.asl"
set tipoAllied2="jasonAgent_ALLIED_MEDIC.asl"
set tipoAllied3="jasonAgent_ALLIED_FIELDOPS.asl"
set log="logs/log_vsLucky.txt"
set Axis="Corralo:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Lechuga:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Adrian:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Edu:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Elastico:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);LaCosa:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%);Fuego:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAxis%)"
set EQUIPOAllied="A1:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);A2:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);A3:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);A4:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);A5:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);A6:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%);A7:es.upv.dsic.gti_ia.JasonJGomas.BasicTroopJasonArch(%tipoAllied2%)"
java -classpath "lib\jade.jar;lib\jadeTools.jar;lib\Base64.jar;lib\http.jar;lib\iiop.jar;lib\beangenerator.jar;lib\jgomas.jar;lib\jason.jar;lib\JasonJGomas.jar;classes;." jade.Boot -container -host localhost %Axis%;%EQUIPOAllied% > %log%