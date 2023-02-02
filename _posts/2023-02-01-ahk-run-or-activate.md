---
layout: post
title: Run or Activate Program
published: yes
tags:
  - autohotkey
  - Windows 10
---
I was always into efficient control of the computer and use of keyboard is key to it. Probably everybody is using the `Alt+Tab` and `Shift+Alt+Tab` to cycle active windows. It is useful, but requires finding the intended application in displayed windows and press the combination until it becomes active.

Since I am frequently using only small amount of applications, my idea was to assign each of them a key and activate them with `Win+key`. Below is the [AutoHotKey][1] script running in background. When the activation key is pressed, the associated application is either activated and if it is not running, it is run.

The script defines following applications:

| Key         | Application        |
| ----------- | ------------------ |
| Win+Shift+C | Calculator         |
| Win+B       | Browser - Firefox  |
| Win+H       | HeidiSQL           |
| Win+C       | Visual Studio Code |

If there is multiple windows running, it activates the most bottom one, which means you can cycle all windows of the application with repeated key presses.

```
#SingleInstance force
#Persistent

SetTitleMatchMode, 2
SetKeyDelay 0

+#c:: RunOrActivateProgram("calc.exe")
#b::  RunOrActivateProgram("C:\Program Files\Firefox Developer Edition\firefox.exe")
#h::  RunOrActivateProgram("C:\Program Files\HeidiSQL\heidisql.exe")
#c::  RunOrActivateProgram("C:\Users\Roman\AppData\Local\Programs\Microsoft VS Code\Code.exe")

RunOrActivateProgram(Program, WorkingDir="", WindowSize="") {
    SplitPath Program, ExeFile
    Process, Exist, %ExeFile%
    PID = %ErrorLevel%
    if (PID = 0) {
        Run, %Program%, %WorkingDir%, %WindowSize%, PID
        WinWait, ahk_pid %PID%, , 10        ; wait maximum 10s
    }

    WinActivateBottom, ahk_pid %PID%
}
```

[1]: https://www.autohotkey.com/
