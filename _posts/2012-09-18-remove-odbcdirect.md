---
layout: post
title: Replace ODBCDirect DAO in old code
category: vba
perex: >
  ??
published: no
tags:
  - Visual Basic
  - VBA
  - DAO
  - ADO
  - ODBCDirect
---

{% highlight vb %}
Private Sub cmd_Click()
    Dim wrkMain As Workspace
    Dim conMain As Connection
    Dim qdfTemp As QueryDef
    Dim strSQL As String
    Dim e As Error
    Dim vRc As Variant
    Dim db As Database, rs As Recordset, tbl As TableDef
    
    On Error GoTo Enum_Error

    Set wrkMain = DBEngine.CreateWorkspace("ODBCWorkspace", "", "", dbUseODBC)
    Set conMain = wrkMain.OpenConnection("", dbDriverComplete, False, _
        "ODBC;Driver=SQL Server;Server=SOMESRV;Database=DB;UID=username;PWD=password")

    strSQL = "{? = call DoAction (?,?,?)}"
    
    Set qdfTemp = conMain.CreateQueryDef("")

    With qdfTemp
        .sql = strSQL
        .Parameters(0).direction = dbParamReturnValue
        
        .Parameters(1).Value = Forms![Main]![ID]
        .Parameters(2).Value = Me.Name
        .Parameters(3).Value = Me.Desc
            
        .Execute
        
        If .Parameters(0).Value = 0 Then
            vRc = MsgBox("Success!", vbOKOnly + vbExclamation, "Action Status")
            DoCmd.Close
        Else
            vRc = MsgBox("Error!", vbOKOnly + vbCritical, "Action Status")
        End If
    End With
    
    conMain.Close
    wrkMain.Close
    
    Exit Sub
    
Enum_Error:
    Debug.Print Err & ":  " & Error$
    For Each e In DBEngine.Errors
        Debug.Print e.Number & ":  " & e.Description
    Next e
End Sub    
{% endhighlight %}

