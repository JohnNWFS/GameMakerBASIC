10 REM ============================================================
20 REM ON ERROR GOTO — RESUME and RESUME NEXT smoke test
30 REM ============================================================
40 CLS
50 PRINT "ON ERROR RESUME TEST"
60 PRINT "===================="
70 PRINT ""
80 REM --- RESUME: handler fixes state, re-executes faulting stmt ---
90 ON ERROR GOTO 2000
100 Y = 0
110 X = 1 \ Y
120 IF X = 1 THEN PRINT "TEST: RESUME_FIX = PASS" ELSE PRINT "TEST: RESUME_FIX = FAIL"
130 REM --- RESUME NEXT: skip faulting stmt on same line ---
140 ON ERROR GOTO 4000
150 PRINT "MARK"
160 X = 1 \ 0
170 PRINT "TEST: RESUME_NEXT = PASS"
180 REM --- RESUME NEXT: advance to next program line ---
190 ON ERROR GOTO 6000
200 X = 1 \ 0
220 PRINT "TEST: RESUME_NEXT_LINE = PASS"
230 GOTO 8000
2000 Y = 1
2010 RESUME
4000 RESUME NEXT
6000 RESUME NEXT
8000 PRINT ""
810 PRINT "ON ERROR RESUME TEST COMPLETE"
820 END