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

| Command   | Description |
|-----------|-------------|
| `PRINT`   | Output text or variable values. Use `+` for concatenation. Use `;` to suppress newline. |
| `LET`     | Assign values to variables (e.g., `LET A = 10`) |
| `INPUT`   | Prompt the user and store text input into a variable |
| `COLOR`   | Change text color (`COLOR RED`, `COLOR rgb(255,255,0)`) |
| `CLS`     | Clear the screen output |
| `GOTO`    | Jump to a specific line number |

#### ➕ Special Print Behavior

- `;` at the end of a `PRINT` line **suppresses the newline**, continuing on the next `PRINT`.
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
| `RUN`         | Run the current BASIC program in the interpreter |
| `CLEAR`       | Wipe all program lines from memory |
| `LIST`        | Display all currently stored BASIC lines |
| F5            | Output the full program as a raw BASIC listing to console |
| `:PASTE`       | Pastes a multi-line BASIC program from clipboard (as if typing `Ctrl+V` in Windows) |


### 🔁 Navigation Shortcuts

| Key            | Action |
|----------------|--------|
| `PageUp`       | Scroll backward through code listing (in long programs) |
| `PageDown`     | Scroll forward through code listing |
| `Esc` (during RUN) | Exit interpreter and return to editor |

---

## 💾 Saving and Version Control

This project uses **Git** for version control. You can connect to GitHub to track changes, back up progress, and collaborate:

```bash
git remote add origin https://github.com/JohnNWFS/GameMakerBASIC.git
git branch -M main
git push -u origin main

🤝 Credits
Built by John Hoffer
Assisted by OpenAI ChatGPT (4o) and Claude Sonnet 4 for code prototyping, logic planning, and debugging support.

10 CLS
20 COLOR GREEN
30 PRINT "WELCOME TO THE TEST"
40 INPUT name$
50 COLOR CYAN
60 PRINT "HELLO "; 
70 PRINT name$
80 PRINT "TESTING COMPLETE"


---


