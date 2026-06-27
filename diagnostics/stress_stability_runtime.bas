10 REM ============================================================
20 REM NW-BASIC STABILITY RUNTIME TEST — fully automated
30 REM INKEY$ nonblocking, TIMER, string/input helpers (no modal wait)
40 REM Output:  TEST: name = PASS  or  TEST: name = FAIL
50 REM ============================================================
60 CLS
70 PRINT "NW-BASIC STABILITY RUNTIME TEST"
80 PRINT "================================"
90 PRINT ""
100 REM --- INKEY$ nonblocking expression ---
110 K$ = INKEY$ + ""
120 IF LEN(K$) >= 0 THEN PRINT "TEST: INKEY_NONBLOCK = PASS" ELSE PRINT "TEST: INKEY_NONBLOCK = FAIL"
130 REM --- TIMER advances ---
140 T0 = TIMER
150 FOR I = 1 TO 1000
160 NEXT I
170 T1 = TIMER
180 IF T1 >= T0 THEN PRINT "TEST: TIMER_MONO = PASS" ELSE PRINT "TEST: TIMER_MONO = FAIL"
190 REM --- String assignment after RUN reset path ---
200 MSG$ = "STABLE"
210 IF MSG$ = "STABLE" THEN PRINT "TEST: STR_VAR = PASS" ELSE PRINT "TEST: STR_VAR = FAIL"
220 N = LEN("ABC")
230 IF N = 3 THEN PRINT "TEST: LEN_LITERAL = PASS" ELSE PRINT "TEST: LEN_LITERAL = FAIL"
240 REM --- VAL / STR$ roundtrip ---
250 X = VAL("42")
260 IF X = 42 THEN PRINT "TEST: VAL_NUM = PASS" ELSE PRINT "TEST: VAL_NUM = FAIL"
270 Y$ = STR$(99)
280 IF Y$ = "99" THEN PRINT "TEST: STR_NUM = PASS" ELSE PRINT "TEST: STR_NUM = FAIL"
290 PRINT ""
300 PRINT "STABILITY RUNTIME TEST COMPLETE"
310 END