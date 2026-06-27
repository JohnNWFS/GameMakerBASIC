5 REM ============================================================
10 REM MODE 2 TILE EDITOR — manual + programmatic checklist
20 REM
30 REM MANUAL (run TILEEDIT or TE from editor first):
40 REM   1) Paint pixels on code 200, preview updates live
50 REM   2) Press S, save as "editor_test"
60 REM   3) Press X to clear, then L to reload editor_test
70 REM   4) ESC exit — tiles stay in memory for RUN below
80 REM ============================================================
90 MODE 2,16
100 CLSCHAR 32, WHITE, BLACK
110 PRINTAT 0,0,"TILE EDITOR CHECKLIST", YELLOW, BLACK
120 PRINTAT 0,2,"If you used TILEEDIT: code 200 should match.", WHITE, BLACK
130 TILEDEF 201,16,16
140 TILEPX 201,8,8,1
150 IF TILEBIT(201,8,8)=1 THEN PRINT "TEST: TILEPX_BASELINE = PASS" ELSE PRINT "TEST: TILEPX_BASELINE = FAIL"
160 TILESAVE "editor_test"
170 TILECLEAR 201
180 IF TILEBIT(201,8,8)=0 THEN PRINT "TEST: CLEAR_BASELINE = PASS" ELSE PRINT "TEST: CLEAR_BASELINE = FAIL"
190 TILELOAD "editor_test"
200 IF TILEBIT(201,8,8)=1 THEN PRINT "TEST: LOAD_BASELINE = PASS" ELSE PRINT "TEST: LOAD_BASELINE = FAIL"
210 TILE 4,6,201,CYAN,BLACK
220 PRINTAT 0,8,"See cyan tile at col 4 row 6.", WHITE, BLACK
230 PRINT ""
240 PRINT "TILE EDITOR CHECKLIST COMPLETE"
250 END