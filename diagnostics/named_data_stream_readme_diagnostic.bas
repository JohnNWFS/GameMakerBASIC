10 PRINT "README NAMED DATA STREAM DIAGNOSTIC"
20 PRINT "This mirrors the README example exactly, then checks values."
30 PRINT "Line 40 defines @numbers with 1,2,3,4,5."
40 DATA @numbers: 1, 2, 3, 4, 5
50 PRINT "Line 60 defines @names with ALICE, BOB, CHARLIE."
60 DATA @names: "ALICE", "BOB", "CHARLIE"
70 PRINT "Reading first two values from @numbers into X and Y..."
80 READ @numbers, X, Y
90 PRINT "X="; X; " Y="; Y
100 IF X=1 AND Y=2 THEN PRINT "PASS: @numbers first READ" ELSE PRINT "FAIL: @numbers first READ"
110 PRINT "Reading first string from @names into N$..."
120 READ @names, N$
130 PRINT "N$=["; N$; "]"
140 IF N$="ALICE" THEN PRINT "PASS: @names string READ" ELSE PRINT "FAIL: @names string READ"
150 PRINT "Restoring only @numbers..."
160 RESTORE @numbers
170 PRINT "Reading @numbers again after RESTORE @numbers..."
180 READ @numbers, A
190 PRINT "A="; A
200 IF A=1 THEN PRINT "PASS: RESTORE @numbers reset pointer" ELSE PRINT "FAIL: RESTORE @numbers"
210 PRINT "Now @names should NOT have been restored."
220 READ @names, B$
230 PRINT "B$=["; B$; "]"
240 IF B$="BOB" THEN PRINT "PASS: @names pointer stayed independent" ELSE PRINT "FAIL: @names pointer was wrong"
250 IF X=1 AND Y=2 AND N$="ALICE" AND A=1 AND B$="BOB" THEN PRINT "PASS: README NAMED DATA STREAMS" ELSE PRINT "FAIL: README NAMED DATA STREAMS"
260 PAUSE
270 END
