10 REM ============================================================
20 REM ERR / ERL smoke test (inside ON ERROR GOTO handler)
30 REM ============================================================
40 CLS
50 PRINT "ERR / ERL TEST"
60 PRINT "=============="
70 PRINT ""
80 IF ERR = 0 AND ERL = 0 THEN PRINT "TEST: ERR_ERL_IDLE = PASS" ELSE PRINT "TEST: ERR_ERL_IDLE = FAIL"
90 ON ERROR GOTO 2000
100 X = 1 \ 0
110 PRINT "TEST: TRAP = FAIL"
120 END
2000 IF ERL = 100 THEN PRINT "TEST: ERL_TRAP = PASS" ELSE PRINT "TEST: ERL_TRAP = FAIL ("; ERL; ")"
2010 IF ERR = 11 THEN PRINT "TEST: ERR_DIV = PASS" ELSE PRINT "TEST: ERR_DIV = FAIL ("; ERR; ")"
2020 END