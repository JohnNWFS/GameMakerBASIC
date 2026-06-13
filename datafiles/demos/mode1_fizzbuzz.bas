10 REM FIZZBUZZ STATS - NW-BASIC MODE 1 DEMO
20 CLS
30 PRINT "==============================="
40 PRINT "   NW-BASIC FIZZBUZZ  1-30"
50 PRINT "==============================="
60 PRINT ""
70 LET F = 0
80 LET B = 0
90 LET FB = 0
100 FOR N = 1 TO 30
110 LET M3 = N MOD 3
120 LET M5 = N MOD 5
130 IF M3 = 0 AND M5 = 0 THEN PRINT N; " FIZZBUZZ"
135 IF M3 = 0 AND M5 = 0 THEN LET FB = FB + 1
140 IF M3 = 0 AND M5 <> 0 THEN PRINT N; " FIZZ"
145 IF M3 = 0 AND M5 <> 0 THEN LET F = F + 1
150 IF M3 <> 0 AND M5 = 0 THEN PRINT N; " BUZZ"
155 IF M3 <> 0 AND M5 = 0 THEN LET B = B + 1
160 IF M3 <> 0 AND M5 <> 0 THEN PRINT N
170 NEXT N
180 PRINT ""
190 PRINT "==============================="
200 PRINT "RESULTS:"
210 PRINT "  FIZZ:     "; F; " numbers"
220 PRINT "  BUZZ:     "; B; " numbers"
230 PRINT "  FIZZBUZZ: "; FB; " numbers"
240 LET P = 30 - F - B - FB
250 PRINT "  PLAIN:    "; P; " numbers"
260 PRINT "==============================="
