/// Build/refresh the in-memory help topics tree
function help_build_topics() {
    // Initialize help_state if it doesn't exist
    if (!variable_global_exists("help_state")) {
        global.help_state = { built: false };
    }
    
    // Initialize or recreate list
    if (!variable_global_exists("help_topics") || !ds_exists(global.help_topics, ds_type_list)) {
        global.help_topics = ds_list_create();
    } else {
        ds_list_clear(global.help_topics);
    }

    // ==== Topics ====
    
    // Topic 1: Editor Commands
    var t1 = { title: "Editor Commands", subs: [] };
    array_push(t1.subs, { 
        title: "RUN / NEW / CLEAR / LIST", 
        lines: [
            "RUN - Execute the current BASIC program.",
            "NEW or CLEAR - Remove all lines from memory.",
            "LIST [start-end] - Show program lines.",
            "F5 - Dump listing to console."
        ]
    });
    array_push(t1.subs, { 
        title: "FILES: SAVE / LOAD / DIR", 
        lines: [
            "SAVE \"name\" - Adds .BAS, writes to Documents/BasicInterpreter.",
            "LOAD \"name\" - Loads program.",
            "DIR - Interactive browser (arrows, Enter, D/X delete, ESC quit)."
        ]
    });
    ds_list_add(global.help_topics, t1);

    // Topic 2: Language Basics
    var t2 = { title: "Language Basics", subs: [] };
    array_push(t2.subs, { 
        title: "Lines, Variables, PRINT", 
        lines: [
            "Lines run in numeric order unless redirected.",
            "Numeric vars: A, X1; Strings: NAME$; Arrays: DIM A(10).",
            "PRINT text or values; ; keeps the cursor on the line."
        ]
    });
    array_push(t2.subs, { 
        title: "INPUT / INKEY$", 
        lines: [
            "INPUT prompts and waits; assigns to variable.",
            "INKEY$ returns last key (\"\" when none).",
            "Extended keys return 2-char sequences."
        ]
    });
    ds_list_add(global.help_topics, t2);

    // Topic 3: Control Flow
    var t3 = { title: "Control Flow", subs: [] };
    array_push(t3.subs, { 
        title: "IF / ELSE / ENDIF", 
        lines: [
            "Inline IF: IF X=1 THEN PRINT \"HI\"",
            "Block IF ... ELSE ... ENDIF is supported."
        ]
    });
    array_push(t3.subs, { 
        title: "FOR / NEXT, WHILE / WEND", 
        lines: [
            "FOR I=1 TO 10 [STEP S] ... NEXT",
            "WHILE condition ... WEND"
        ]
    });
    ds_list_add(global.help_topics, t3);

    // Topic 4: MODE 1 (Tile) Basics
    var t4 = { title: "MODE 1 (Tile) Basics", subs: [] };
    array_push(t4.subs, { 
        title: "PRINTAT / CHARAT / PSET", 
        lines: [
            "PRINTAT x,y,\"TEXT\"[,FG,BG]",
            "CHARAT x,y,code[,FG,BG] places a tile/char.",
            "PSET x,y,code[,FG,BG,BG] shorthand."
        ]
    });
    // Topic 5: Math & Random
    var t5 = { title: "Math & Random", subs: [] };
    array_push(t5.subs, { 
        title: "Math Functions", 
        lines: [
            "ABS, INT, SGN, EXP, LOG, LOG10",
            "SIN, COS, TAN (work in radians)",
            "^ for exponentiation",
            "Standard operator precedence"
        ]
    });
    array_push(t5.subs, { 
        title: "Random Numbers", 
        lines: [
            "RND(6) returns 1 to 6",
            "RND(1,10) returns range 1 to 10", 
            "RND or RND(1) returns 0 to 1"
        ]
    });
    ds_list_add(global.help_topics, t5);

    // Topic 6: Strings
    var t6 = { title: "Strings", subs: [] };
    array_push(t6.subs, { 
        title: "String Functions", 
        lines: [
            "LEFT$, RIGHT$, MID$ for substrings",
            "LEN for string length",
            "CHR$(65) converts to \"A\"",
            "ASC(\"A\") converts to 65"
        ]
    });
    ds_list_add(global.help_topics, t6);

    // Topic 7: Data & Arrays  
    var t7 = { title: "Data & Arrays", subs: [] };
    array_push(t7.subs, { 
        title: "DATA/READ/RESTORE", 
        lines: [
            "DATA statement stores values",
            "READ loads into variables", 
            "RESTORE resets to start",
            "Named streams: DATA @name: values"
        ]
    });
    array_push(t7.subs, { 
        title: "Arrays", 
        lines: [
            "DIM A(10) creates array 0 to 10",
            "Use in loops: FOR I=0 TO 10",
            "Multi-dimensional: DIM A(5,5)",
            "Dynamic sizing: DIM A(X+5)"
        ]
    });
    ds_list_add(global.help_topics, t7);

    // Topic 8: Input/Output
    var t8 = { title: "Input/Output", subs: [] };
    array_push(t8.subs, { 
        title: "PRINT Variations", 
        lines: [
            "PRINT X prints value and newline",
            "PRINT X; keeps cursor on line",
            "PRINT X,Y,Z uses tab columns",
            "PRINT without args = blank line"
        ]
    });
    array_push(t8.subs, { 
        title: "INPUT and Keys", 
        lines: [
            "INPUT \"Prompt: \",VAR waits for input",
            "INKEY$ returns last key pressed",
            "CLS clears screen",
            "COLOR FG,BG sets colors"
        ]
    });
    ds_list_add(global.help_topics, t8);

    // Topic 9: Editor & Files
    var t9 = { title: "Editor & Files", subs: [] };
    array_push(t9.subs, { 
        title: "File Operations", 
        lines: [
            "SAVE \"filename\" saves program",
            "LOAD \"filename\" loads program",
            "DIR opens file browser",
            "Drag & drop .BAS files to load"
        ]
    });
    array_push(t9.subs, { 
        title: "Editor Commands", 
        lines: [
            "LIST shows program lines",
            "RUN executes program",
            "NEW or CLEAR erases program",
            "F5 dumps to console"
        ]
    });
    ds_list_add(global.help_topics, t9);

    global.help_state.built = true;
}