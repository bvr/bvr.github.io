---
layout: post
title: Title
published: no
tags:
  - tag
---
Great question — **AutoHotkey (AHK)** is very handy for automating desktop apps, especially when you can't access a COM or API directly.

When it comes to **timing**, the key is to **wait for the right window, control, or process state** before sending keystrokes or clicks. Here's a solid breakdown:

---

### ✅ **1. Basic AutoHotkey Example**

```ahk
Run, C:\Path\To\App.exe
WinWait, App Title
WinActivate, App Title

; Wait a bit just to be safe
Sleep, 1000

; Send some keystrokes
Send, {Alt}f ; Open File menu
Send, o      ; Choose "Open"
Sleep, 500
Send, C:\Path\To\File.fts{Enter}
```

---

### ⏱️ **2. Timing Techniques in AHK**

#### **A. `Sleep`**
- Pauses the script for N milliseconds.
```ahk
Sleep, 500 ; wait 0.5 seconds
```

#### **B. `WinWait`, `WinWaitActive`**
- Waits until a window is created/active.
```ahk
WinWait, CAFTA
WinActivate, CAFTA
```

#### **C. `PixelSearch`, `ImageSearch`**
- Wait for a certain pixel or image on the screen to appear:
```ahk
ImageSearch, x, y, 0, 0, 1920, 1080, *n image.png
if (ErrorLevel = 0)
{
   Click, %x%, %y%
}
```

#### **D. `Process, Wait`**
- Wait for a process to start or stop.
```ahk
Process, Wait, CAFTA.exe
```

#### **E. Loops with `IfWinExist`**
To check a condition repeatedly:
```ahk
Loop
{
    IfWinExist, CAFTA
        break
    Sleep, 100
}
```

---

### 🔄 **3. Example: Wait for CAFTA to Load and Open File**

```ahk
Run, C:\Program Files\CAFTA\CAFTA.exe
WinWaitActive, CAFTA

; Wait an extra second in case the UI is slow
Sleep, 1000

; Simulate pressing Alt+F, then O to open a file
Send, !f
Sleep, 300
Send, o
Sleep, 300

; Paste file path and hit Enter
Send, C:\Projects\FaultTrees\example.fts{Enter}
```

---

### 📌 **Tips**
- Add **sound or tooltips** for debugging:
```ahk
SoundBeep
ToolTip, Waiting for CAFTA...
```

- Use **Window Spy** (comes with AutoHotkey) to get:
  - Exact window titles
  - Control names (if using `ControlSend`, `ControlClick`)

---

If you're working with a specific app like **CAFTA**, you can also:
- Record your actions with **Pulover’s Macro Creator** (AHK GUI recorder)
- Or ask me to help write a tailored script if you describe what the app workflow looks like (e.g. launch → wait → import file → export report).

Want to build a real example together?