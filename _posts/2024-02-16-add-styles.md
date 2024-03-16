---
layout: post
title: Add styles by text
published: yes
tags:
  - Word
  - Visual Basic
  - VBA
  - Microsoft Word
  - Styles
---
At work we are using Microsoft Word for software requirements and documentation. To make it easier to parse, the convention (helped by some VBA macros) is that important parts of the document are marked with semantic styles.

This works quite nice, but sometimes we interoperate with other teams that use different conventions. Recently I tried to help to "stylify" document according to its text.

One-off macro I used was rather simple, something along this lines:

```vb
Private Sub SetStyles()
    Dim p As Paragraph
    Dim story As Range

    For Each story In ActiveDocument.StoryRanges
        For Each p In story.Paragraphs
            If InStr(1, p.Range.Text, "Source:") = 1 Then
                p.Style = ActiveDocument.Styles("Source")
            End If
        Next p
    Next story
End Sub
```

The code basically just walks over all paragraphs, detect whether the paragraph starts with specific phrase and set appropriate style. Before running the macro, I needed to make sure all necessary styles are copied in the document. 

Styles have handy panel that can be enabled either by clicking small outward arrow under list of Styles on `Home` tab (there is shortcut `Ctrl + Alt + Shift + S`, too). On the dialog there is a button `Manage Styles`, which in turn has button `Import/Export` at the bottom. After all these hoops you are finally in style `Organizer` that allows to open two document with list of their styles and copy them between. It took me quite some time to figure this part out.
