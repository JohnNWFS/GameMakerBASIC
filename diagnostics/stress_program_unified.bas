10 REM ============================================================
20 REM NW-BASIC UNIFIED PROGRAM TEST — Phase 10b
30 REM Editor and runtime share program_map + line_list.
40 REM RUN this after loading; also verify manually in editor:
50 REM   NEW, type lines, LIST, RUN, Ctrl+Z, SAVE, LOAD
60 REM Output:  TEST: name = PASS  or  TEST: name = FAIL
70 REM ============================================================
80 CLS
90 PRINT "NW-BASIC UNIFIED PROGRAM TEST (Phase 10b)"
100 PRINT "=========================================="
110 PRINT ""
120 REM
200 REM --- Reuse runtime navigation checks from Phase 10a ---
210 GOTO 700
220 PRINT "TEST: GOTO_SKIP = FAIL"
700 PRINT "TEST: GOTO_700 = PASS"
710 GOSUB 8000
720 IF SUBOK = 1 THEN PRINT "TEST: GOSUB_RET = PASS" ELSE PRINT "TEST: GOSUB_RET = FAIL"
730 REM
9500 MARKER = 1
115 LOW = 1
125 IF LOW = 1 AND MARKER = 0 THEN PRINT "TEST: SORT_ORDER = PASS" ELSE PRINT "TEST: SORT_ORDER = FAIL"
140 PRINT ""
150 PRINT "Manual editor checks (same storage as RUN):"
160 PRINT "  NEW clears program"
170 PRINT "  LIST shows typed lines in order"
180 PRINT "  Ctrl+Z restores after edit"
190 PRINT "  RUN twice — all TEST lines stay PASS"
200 END
8000 SUBOK = 1
8010 RETURN