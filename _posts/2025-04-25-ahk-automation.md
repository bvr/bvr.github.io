---
layout: post
title: Automating CAFTA
published: yes
tags:
  - autohotkey
  - Windows 10
  - keyboard
  - ahk
---
The **AutoHotkey (AHK)** is very handy for automating desktop apps. I generally prefer when the application provides an API or command-line means to perform a task, but if there is no other option you must rely on the user interface to do them.

Recently I needed to use [CAFTA][1] to print fault trees designed by local Safety team to PDF in order to provide them to customer. Initially I looked for an API for the task, but even the vendor of the tool confirmed there is nothing we can use for this task.

Here are some techniques used in the script.

## Get the parameters

The autohotkey script perform an one-off task, so I needed to supply it with parameters. I am using v1 of the tool and the parameters are acquired this way

```ahk
program = %1%
input = %2%
MsgBox, Parameters:`n1: %program%`n2: %input%
```

The script is called like this

```
"c:\Program Files\AutoHotkey\AutoHotkey.exe" script.ahk "c:\Program Files\EPRI Phoenix\Phoenix Architect 2.1\CAFTA.exe" "input.txt"
```

## Run the application and wait for the main window

Here is the code to launch the specified program, wait for its main window to show up and activate it. The method for waiting for a window is rather handy and I am using to check that we are ready to send the keystrokes.

```ahk
Run, %program%
WinWait, CAFTA, ,10        ; wait maximum 10s
WinActivate, CAFTA
```

## Ribbon and dialogs

With older versions of Windows, it was a standard to provide a menu with underlined accelerators, so it was easy to directly see what keyboard combination you can use. Things like `Alt+F`, `O` could get you to `File`/`Open` entry. These days we have to use the ribbons, much more stupid way to navigate the application. Fortunately ribbon still supports keyboard access, you can learn what the keys are by holding `Alt`:

![CAFTA Ribbon](/img/cafta-ribbon.png)

Launching an entry from the ribbon is as easy as 

```ahk
Send,!HF     ; Home/Fault Tree
```

`HF` is simply pressing `H` and `F` keys, `!` stands for `Alt`. Here are few things available:

| Shortcut   | Meaning |
| ---------- | ------- |
| `+`        | Shift   |
| `^`        | Ctrl    |
| `!`        | Alt     |
| `{Tab}`    | Tab     |
| `{Enter}`  | Enter   |
| `{F4}`     | F4      |

Navigation along a dialog box is similar:

```ahk
Send,{Tab}{Tab}{Enter}{Tab}5{Tab}5{Enter}
```

## Waiting for a dialog to show up and disappear

At some point it is useful to wait for a dialog and then wait until the printing process is done. Here is my solution:

```ahk
ToolTip, Waiting for Printing ...
Loop
{
    IfWinExist, Printing
        break
    Sleep, 100
}    

; Wait until printing exits
ToolTip, Print ...
Loop
{
    IfWinNotExist, Printing
        break
    Sleep, 100
}
```


[1]: https://polestartechnicalservices.com/cafta-software/
