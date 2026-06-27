/// @script build_if_block_map
/// @description Scan program_map for IF…ELSEIF…ELSE…ENDIF block structure,
///              but skip inline IFs so they don’t trigger mismatches.

function build_if_block_map() {
    // 1) Destroy any old map
    if (variable_global_exists("if_block_map") && ds_exists(global.if_block_map, ds_type_map)) {
        ds_map_destroy(global.if_block_map);
    }
    global.if_block_map = ds_map_create();

    // 2) Temp stack for nested block IFs
    var openStack = ds_stack_create();
    var total     = ds_list_size(global.line_list);

    // 3) Walk every line
    for (var idx = 0; idx < total; idx++) {
        var lineNum = global.line_list[| idx];
        var rawText = string_trim(global.program_map[? lineNum]);
        var text    = string_upper(rawText);
        var sp      = string_pos(" ", text);
        var kw      = (sp > 0) ? string_copy(text, 1, sp - 1) : text;

        switch (kw) {
            case "IF":
                // detect inline IF: IF … THEN <command> on same line
                var thenPos = string_pos("THEN", text);
                var after   = (thenPos > 0)
                              ? string_trim(string_copy(rawText, thenPos + 4, string_length(rawText)))
                              : "";
                if (thenPos > 0 && string_length(after) > 0) {
                    // Inline IF → skip block indexing entirely
                    dbg_log(DBG_FLOW, "INLINE IF skip at line " + string(lineNum));
                    break;
                }
                // Block IF → record it
                var info = ds_map_create();
                ds_map_add(info, "startIndex",       idx);
                ds_map_add(info, "elseifIndices",    ds_list_create());
                ds_map_add(info, "elseIndex",        -1);
                ds_map_add(info, "endifIndex",       -1);
                ds_map_add(info, "firstBranchIndex", idx + 1);
                ds_stack_push(openStack, info);
                break;

            case "ELSEIF":
                if (!ds_stack_empty(openStack)) {
                    var top = ds_stack_top(openStack);
                    ds_list_add(top[? "elseifIndices"], idx);
                } else {
                    dbg_log(DBG_FLOW, "?MISMATCH ERROR: ELSEIF at line " + string(lineNum) + " without IF");
                }
                break;

            case "ELSE":
                if (!ds_stack_empty(openStack)) {
                    var top = ds_stack_top(openStack);
                    ds_map_replace(top, "elseIndex", idx);
                } else {
                    dbg_log(DBG_FLOW, "?MISMATCH ERROR: ELSE at line " + string(lineNum) + " without IF");
                }
                break;

            case "ENDIF":
                if (!ds_stack_empty(openStack)) {
                    var top = ds_stack_pop(openStack);
                    ds_map_replace(top, "endifIndex", idx);

                    // recompute firstBranchIndex
                    var eList = top[? "elseifIndices"];
                    var fb = (ds_list_size(eList) > 0)
                             ? eList[| 0]
                             : ((top[? "elseIndex"] >= 0) ? top[? "elseIndex"] : idx);
                    ds_map_replace(top, "firstBranchIndex", fb);

                    ds_map_add(global.if_block_map, top[? "startIndex"], top);
                } else {
                    dbg_log(DBG_FLOW, "?MISMATCH ERROR: ENDIF at line " + string(lineNum) + " without IF");
                }
                break;
        }
    }

    // 4) Any unclosed IFs left on the stack?
    while (!ds_stack_empty(openStack)) {
        var orphan = ds_stack_pop(openStack);
        var startIdx  = orphan[? "startIndex"];
        var startLine = global.line_list[| startIdx];
        dbg_log(DBG_FLOW, "?MISMATCH ERROR: IF at line " + string(startLine) + " missing ENDIF");
        ds_map_destroy(orphan);
    }
    ds_stack_destroy(openStack);

    dbg_log(DBG_FLOW, "Built IF block map with " + string(ds_map_size(global.if_block_map)) + " entries.");
}
