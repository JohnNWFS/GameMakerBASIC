# GameMakerBASIC

A lightweight, custom-built BASIC interpreter and code editor created using **GameMaker Studio**. This project aims to recreate the feel of early home computer BASIC environments—reimagined for modern use and ultimately targeting **Android deployment**.

> **Built for fun**, educational exploration, and retro coding joy — this project is co-developed using LLMs (Large Language Models) to assist with iterative code design, debugging, and feature expansion.

---

## 🎯 Project Goals

- Build a **fully functional** interpreted BASIC environment from scratch
- Run on **GameMaker Studio** and be easily portable to **Android devices**
- Maintain a lightweight and nostalgic programming feel
- Encourage experimentation, creativity, and fun with retro-style code

---

## 🧠 Features Overview

### ✅ Working BASIC Interpreter Commands

| Command    | Description |
|------------|-------------|
| `PRINT`    | Output text or variable values. Use `+` for concatenation. Use `;` to suppress newline. |
| `LET`      | Assign values to variables (e.g., `LET A = 10`) |
| `INPUT`    | Prompt the user and store input into a variable |
| `COLOR`    | Change text color (`COLOR RED`, or `COLOR rgb(255,255,0)`) |
| `CLS`      | Clear the screen output |
| `GOTO`     | Jump to a specific line number |
| `GOSUB`    | Call a subroutine at a given line number |
| `RETURN`   | Return from a subroutine |
| `IF ... THEN GOTO` | Conditional branching (e.g., `IF A = 10 THEN GOTO 100`) |
| `END`      | Stops the program and shows a “Program has ended” message |
| `FOR/NEXT` | Simple counted loops (`FOR I = 1 TO 5 ... NEXT`) |
| `REM` or `'` | Comment/no-op lines |

#### ➕ Special Print Behavior

- `;` at the end of a `PRINT` line **suppresses the newline**, continuing on the same line:
    ```basic
    10 PRINT "HELLO ";
    20 PRINT name$
    ```
- `+` is used to concatenate strings and variables:
    ```basic
    10 PRINT "HELLO " + name$
    ```

---

## 🖊️ Built-in Editor Commands

All editor commands are typed on a line that **does not begin with a number**:

| Command        | Action |
|----------------|--------|
| `RUN`          | Run the current BASIC program in the interpreter |
| `CLEAR`        | Wipe all program lines from memory |
| `LIST`         | Display all currently stored BASIC lines |
| `:PASTE`       | Paste a multi-line BASIC program from clipboard |
| `F5`           | Dump the BASIC program to the console |

---

## 🔁 Interpreter Controls & Navigation

| Key                 | Action |
|---------------------|--------|
| `PageUp` / `PageDown` | Scroll editor listing up/down |
| `Esc` (during RUN)   | Exit the interpreter and return to the editor |
| `Enter` (after `END`) | Return to editor manually after program finishes |

---

## 🔧 Under the Hood

- BASIC source lines are stored in a `ds_map` by line number
- Execution occurs line-by-line using a custom interpreter loop
- Variables are stored in a dynamic `ds_map` (`global.basic_variables`)
- Subroutine stack and FOR/NEXT stack are tracked using DS stacks

---

## 💾 Saving and Version Control

This project uses **Git** for version control. You can connect to GitHub to track changes, back up progress, and collaborate:

```bash
git remote add origin https://github.com/JohnNWFS/GameMakerBASIC.git
git branch -M main
git push -u origin main
```

---

## 🧪 Sample BASIC Program

```basic
10 CLS
20 COLOR GREEN
30 PRINT "WELCOME TO THE TEST"
40 INPUT name$
50 COLOR CYAN
60 PRINT "HELLO ";
70 PRINT name$
80 PRINT "TESTING COMPLETE"
90 END
```

---

## 🤝 Credits

Built by **John Hoffer**  
Assisted by OpenAI ChatGPT (GPT-4o) and Claude Sonnet 4 for code prototyping, logic planning, and debugging support.

---
