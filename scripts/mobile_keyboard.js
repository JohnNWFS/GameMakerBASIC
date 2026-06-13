/**
 * mobile_keyboard.js  —  NW-BASIC on-screen keyboard for iOS / iPhone
 *
 * Injected into index.html at deploy time. Activates only on iOS (iPhone/iPad).
 * Shrinks the game canvas to the upper portion of the screen and draws a
 * custom keyboard in the space below it, feeding input to GML via
 * window.nwbasic_key() (defined in browser_file_tools.js).
 *
 * Layout (6 rows):
 *   [ESC][F1][F2][F3][F4][F5][◄][►][⌫]
 *   [1][2][3][4][5][6][7][8][9][0]["][:]
 *   [Q][W][E][R][T][Y][U][I][O][P][(][)]
 *   [A][S][D][F][G][H][J][K][L][;][ENTER]
 *   [⇧][Z][X][C][V][B][N][M][,][.][/][+]
 *   [CAPS][ SPACE ][-][=][*][<][>][CLR]
 *
 * SHIFT = momentary — next character lowercased, then auto-releases
 * CAPS  = toggle — locks lowercase
 * Default = UPPERCASE (most BASIC commands are all-caps)
 */
(function () {
    // ── Platform detection ────────────────────────────────────────────────────
    var isMobile = /iPad|iPhone|iPod|Android/i.test(navigator.userAgent) ||
                   ('ontouchstart' in window) ||
                   (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
    // On desktop the keyboard starts hidden; on mobile it starts visible.
    var startVisible = isMobile;

    // ── State ────────────────────────────────────────────────────────────────
    var capsLock  = false;   // true = force lowercase
    var shiftDown = false;   // momentary shift (one char then release)

    // ── Key definitions ──────────────────────────────────────────────────────
    // Each key: [label, gmlKey, widthUnits]  (widthUnits: 1 = normal, 2 = wide)
    var ROWS = [
        // Row 0 — function / navigation
        [['ESC','ESC',1.5],['F1','F1',1],['F2','F2',1],['F3','F3',1],['F4','F4',1],['F5','F5',1],
         ['◄','LEFT',1],['►','RIGHT',1],['⌫','BACKSPACE',1.5]],
        // Row 1 — numbers + common symbols
        [['1','1',1],['2','2',1],['3','3',1],['4','4',1],['5','5',1],
         ['6','6',1],['7','7',1],['8','8',1],['9','9',1],['0','0',1],['"','"',1],[':',':',1]],
        // Row 2 — QWERTY top
        [['Q','Q',1],['W','W',1],['E','E',1],['R','R',1],['T','T',1],
         ['Y','Y',1],['U','U',1],['I','I',1],['O','O',1],['P','P',1],['(','(',1],[')',')' ,1]],
        // Row 3 — ASDF
        [['A','A',1],['S','S',1],['D','D',1],['F','F',1],['G','G',1],
         ['H','H',1],['J','J',1],['K','K',1],['L','L',1],[';',';',1],['↵','ENTER',2]],
        // Row 4 — ZXCV
        [['⇧','SHIFT',1.5],['Z','Z',1],['X','X',1],['C','C',1],['V','V',1],
         ['B','B',1],['N','N',1],['M','M',1],[',',',',1],['.','.', 1],['/','/','1'],['+','+',1]],
        // Row 5 — bottom symbols
        [['CAPS','CAPS',1.5],['SPACE','SPACE',4],
         ['-','-',1],['=','=',1],['*','*',1],['<','<',1],['>','>',1],['CLR','ESC',1.5]]
    ];

    // ── Build keyboard DOM ───────────────────────────────────────────────────
    var KB_HEIGHT = 252; // px — 6 rows × 38px + 14px padding

    var style = document.createElement('style');
    style.textContent = [
        '#nwkb {',
        '  position:fixed; bottom:0; left:0; right:0;',
        '  height:' + KB_HEIGHT + 'px;',
        '  background:#1a1a1a;',
        '  display:flex; flex-direction:column;',
        '  gap:2px; padding:3px 2px;',
        '  z-index:9999;',
        '  user-select:none; -webkit-user-select:none;',
        '  box-sizing:border-box;',
        '}',
        '#nwkb .row {',
        '  display:flex; flex:1; gap:2px;',
        '}',
        '#nwkb button {',
        '  flex:1;',
        '  background:#333; color:#eee;',
        '  border:1px solid #555; border-radius:5px;',
        '  font-size:13px; font-family:monospace;',
        '  padding:0; margin:0;',
        '  -webkit-tap-highlight-color:transparent;',
        '  touch-action:manipulation;',
        '  cursor:pointer;',
        '}',
        '#nwkb button:active { background:#555; }',
        '#nwkb button.wide2 { flex:2; }',
        '#nwkb button.wide15 { flex:1.5; }',
        '#nwkb button.wide4 { flex:4; }',
        '#nwkb button.fn { color:#7cf; font-size:11px; }',
        '#nwkb button.action { background:#444; color:#fc6; }',
        '#nwkb button.caps-on { background:#2a5; color:#fff; }',
        '#nwkb button.shift-on { background:#55a; color:#fff; }',
        // Shrink canvas on mobile to leave room for keyboard (desktop unchanged)
        isMobile ? 'canvas { max-height:calc(100vh - ' + KB_HEIGHT + 'px) !important; display:block; }' : '',
    ].join('\n');
    document.head.appendChild(style);

    var kb = document.createElement('div');
    kb.id = 'nwkb';

    var btns = {}; // gmlKey -> button element (for CAPS/SHIFT styling)

    ROWS.forEach(function (row) {
        var rowEl = document.createElement('div');
        rowEl.className = 'row';
        row.forEach(function (spec) {
            var label   = spec[0];
            var gmlKey  = spec[1];
            var units   = parseFloat(spec[2]) || 1;
            var btn     = document.createElement('button');
            btn.textContent = label;
            // Width class
            if (units === 2)   btn.className = 'wide2';
            else if (units === 1.5) btn.className = 'wide15';
            else if (units === 4)   btn.className = 'wide4';
            // Style special keys
            if (['F1','F2','F3','F4','F5','ESC','BACKSPACE','LEFT','RIGHT'].indexOf(gmlKey) !== -1)
                btn.classList.add('fn');
            if (['ENTER','SHIFT','CAPS'].indexOf(gmlKey) !== -1)
                btn.classList.add('action');

            btns[gmlKey] = btn;

            btn.addEventListener('touchstart', function (e) {
                e.preventDefault();
                handleKey(gmlKey);
                updateModifierStyles();
            }, { passive: false });
            // Also support click for desktop testing
            btn.addEventListener('click', function () {
                handleKey(gmlKey);
                updateModifierStyles();
            });

            rowEl.appendChild(btn);
        });
        kb.appendChild(rowEl);
    });

    // ── Key handler ──────────────────────────────────────────────────────────
    function handleKey(gmlKey) {
        console.log('[KB] tap:', gmlKey,
            '| nwbasic_key:', typeof window.nwbasic_key,
            '| gml_fn:', typeof window["gml_Script_nwbasic_handle_virtual_key"]);
        if (!window.nwbasic_key) { console.warn('[KB] nwbasic_key not defined yet'); return; }

        if (gmlKey === 'CAPS') {
            capsLock  = !capsLock;
            shiftDown = false;
            return;
        }
        if (gmlKey === 'SHIFT') {
            shiftDown = !shiftDown;
            return;
        }

        // Letter keys — apply case
        var send = gmlKey;
        if (gmlKey.length === 1 && gmlKey >= 'A' && gmlKey <= 'Z') {
            var lower = capsLock ? !shiftDown : shiftDown;
            send = lower ? gmlKey.toLowerCase() : gmlKey;
            if (shiftDown) shiftDown = false; // auto-release momentary shift
        }

        window.nwbasic_key(send);
    }

    function updateModifierStyles() {
        if (btns['CAPS']) {
            btns['CAPS'].classList.toggle('caps-on',  capsLock);
        }
        if (btns['SHIFT']) {
            btns['SHIFT'].classList.toggle('shift-on', shiftDown);
        }
    }

    // ── Show / hide ───────────────────────────────────────────────────────────
    var visible = false;

    function showKb() {
        kb.style.display = 'flex';
        visible = true;
    }
    function hideKb() {
        kb.style.display = 'none';
        visible = false;
    }

    // Exposed globally so browser_keyboard_toggle() in browser_file_tools.js can call it
    window.nwbasic_toggle_keyboard = function () {
        if (visible) hideKb(); else showKb();
    };

    // ── Long-press any key to hide ────────────────────────────────────────────
    var longPressTimer = null;
    kb.addEventListener('touchstart', function (e) {
        longPressTimer = setTimeout(function () {
            longPressTimer = null;
            hideKb();
        }, 800);
    }, { passive: true });
    kb.addEventListener('touchend',   function () { clearTimeout(longPressTimer); }, { passive: true });
    kb.addEventListener('touchmove',  function () { clearTimeout(longPressTimer); }, { passive: true });

    // ── Inject into page ─────────────────────────────────────────────────────
    function init() {
        document.body.appendChild(kb);
        if (startVisible) showKb(); else hideKb();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
}());
