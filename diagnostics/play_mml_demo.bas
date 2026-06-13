10 PRINT "PLAY MML DEMO"
20 PRINT "PLAY uses classic Music Macro Language."
30 PRINT "This tests tempo, octave, default length, rests, and dotted notes."
40 PAUSE
50 PRINT "C major scale using T120 O4 L8."
60 PLAY "T120 O4 L8 CDEFGAB>C"
70 PRINT "A short rhythm with rests."
80 PLAY "T100 O4 L8 C R C G4"
90 PRINT "Sharps, flats, octave shifts, and dotted notes."
100 PLAY "T120 O4 L8 C C+ D D- C. <B >C2"
110 PRINT "DONE."
120 PAUSE
130 END
