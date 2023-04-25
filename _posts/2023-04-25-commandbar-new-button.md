---
layout: post
title: Command Bars in new Word
published: yes
tags:
  - Visual Basic
  - VBA
  - Microsoft Word
  - Command Bar
---
At work we use Microsoft Word to author requirements and there is plenty of macros that help with the task. When it was designed years ago, it used command bars functionality. At that time, you could edit them easily, create new buttons, and assign them macros. 

With introduction of ribbons to Microsoft products, the functionality is still there, but the Word lacks ability to easily edit them. Only option I found is to edit them programmatically. First problem is to locate all command bars. Quick macro like this will do

```vb
Sub EnumerateCommandBars()
  Dim CommandBar
  
  For Each CommandBar In ActiveDocument.CommandBars
    Debug.Print CommandBar.Name
  Next
End Sub
```

Note the `Debug.Print` outputs the string into Immediate Window. You can show it with `View` / `Immediate Window` or with `Ctrl+G` shortcut.

Then adding new button can be done with macro

```vb
Sub AddButtonIntoCommandBar()
  Dim NewButton
  Set NewButton = ActiveDocument.CommandBars("CustomButtons").Controls.Add(Type:=msoControlButton)

  NewButton.caption = "Do This"
  NewButton.OnAction = "Module.DoThis"
  NewButton.Style = msoButtonCaption
End Sub
```

It will create button with `Do This` text, connected to macro `DoThis` in `Module`. Very simple tester that would bring a message box looks like this

```vb
Sub DoThis
  MsgBox "Clicked Do This"
End Sub
```

