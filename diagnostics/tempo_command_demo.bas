10 PRINT "TEMPO COMMAND DEMO"
20 PRINT "The same notes play slowly, then quickly."
30 PAUSE
40 TEMPO 80
50 PRINT "TEMPO 80: slow quarter notes."
60 BEEP O0 C1 D1 E1 F1 G2
70 TEMPO 150
80 PRINT "TEMPO 150: the same rhythm is faster."
90 BEEP O0 C1 D1 E1 F1 G2
100 TEMPO 120
110 PRINT "Tempo restored to 120."
120 PAUSE
130 END
