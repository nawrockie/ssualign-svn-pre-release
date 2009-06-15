esl-ssudraw archaea.rf.stk archaea.ps archaea-ifo.ps
esl-ssudraw -q -d archaea.rf.stk archaea.ps archaea-del.ps
esl-ssudraw -q -i archaea.rf.stk archaea.ps archaea-ins.ps
ps2pdf archaea.ps 
ps2pdf archaea-ifo.ps
ps2pdf archaea-del.ps
ps2pdf archaea-ins.ps

esl-ssudraw bacteria.rf.stk bacteria.ps bacteria-ifo.ps
esl-ssudraw -q -d bacteria.rf.stk bacteria.ps bacteria-del.ps
esl-ssudraw -q -i bacteria.rf.stk bacteria.ps bacteria-ins.ps
ps2pdf bacteria.ps 
ps2pdf bacteria-ifo.ps
ps2pdf bacteria-del.ps
ps2pdf bacteria-ins.ps

esl-ssudraw chloroplast.rf.stk chloroplast.ps chloroplast-ifo.ps
esl-ssudraw -q -d chloroplast.rf.stk chloroplast.ps chloroplast-del.ps
esl-ssudraw -q -i chloroplast.rf.stk chloroplast.ps chloroplast-ins.ps
ps2pdf chloroplast.ps 
ps2pdf chloroplast-ifo.ps
ps2pdf chloroplast-del.ps
ps2pdf chloroplast-ins.ps

esl-ssudraw eukarya.rf.stk eukarya.ps eukarya-ifo.ps
esl-ssudraw -q -d eukarya.rf.stk eukarya.ps eukarya-del.ps
esl-ssudraw -q -i eukarya.rf.stk eukarya.ps eukarya-ins.ps
ps2pdf eukarya.ps 
ps2pdf eukarya-ifo.ps
ps2pdf eukarya-del.ps
ps2pdf eukarya-ins.ps

esl-ssudraw metamito.rf.stk metamito.ps metamito-ifo.ps
esl-ssudraw -q -d metamito.rf.stk metamito.ps metamito-del.ps
esl-ssudraw -q -i metamito.rf.stk metamito.ps metamito-ins.ps
ps2pdf metamito.ps 
ps2pdf metamito-ifo.ps
ps2pdf metamito-del.ps
ps2pdf metamito-ins.ps
