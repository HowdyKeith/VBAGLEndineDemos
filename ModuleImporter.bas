Option Explicit
'ModuleImporter.bas v1.0
Public Sub StartModuleImporter()
    Dim rawInput As String
    Dim moduleName As String
    Dim compType As Long
    
    Do
        ' 1. Prompt for the pasted text
        rawInput = InputBox("Paste the module text below. Click Cancel to stop.", "New Module Import")
        
        If rawInput = "" Then Exit Do
        
        ' 2. Parse the name and type
        moduleName = ParseModuleName(rawInput, compType)
        
        If moduleName = "" Then
            MsgBox "Could not determine module name from header.", vbCritical
        Else
            ' 3. Clean and check name length
            moduleName = SanitizeModuleName(moduleName)
            
            ' 4. Create and Fill (Late Bound)
            ImportToProjectLateBound moduleName, compType, rawInput
        End If
    Loop
End Sub

Private Function ParseModuleName(txt As String, ByRef outType As Long) As String
    Dim lines() As String
    Dim i As Integer
    
    lines = Split(txt, vbCrLf)
    outType = 1 ' Default: vbext_ct_StdModule
    
    ' Scan first few lines
    For i = 0 To IIf(UBound(lines) < 5, UBound(lines), 5)
        If InStr(1, lines(i), "Module:", vbTextCompare) > 0 Then
            outType = 1
            ParseModuleName = Trim(Mid(lines(i), InStr(lines(i), ":") + 1))
            Exit For
        ElseIf InStr(1, lines(i), "Class:", vbTextCompare) > 0 Then
            outType = 2 ' vbext_ct_ClassModule
            ParseModuleName = Trim(Mid(lines(i), InStr(lines(i), ":") + 1))
            Exit For
        End If
    Next i
    
    ParseModuleName = Replace(ParseModuleName, ".bas", "", , , vbTextCompare)
    ParseModuleName = Replace(ParseModuleName, ".cls", "", , , vbTextCompare)
End Function

Private Function SanitizeModuleName(ByVal Name As String) As String
    Const MAX_LEN As Integer = 31
    Name = Trim(Name)
    If Len(Name) > MAX_LEN Then
        Name = Left(Name, MAX_LEN - 1) & "1"
    End If
    SanitizeModuleName = Name
End Function

Private Sub ImportToProjectLateBound(modName As String, modType As Long, fullText As String)
    Dim vbp As Object ' VBIDE.VBProject
    Dim vbc As Object ' VBIDE.VBComponent
    
    ' Access the VBE via Application object
    On Error Resume Next
    Set vbp = Application.VBE.ActiveVBProject
    On Error GoTo 0
    
    If vbp Is Nothing Then
        MsgBox "Access to the VBA Project is denied. Check 'Trust access to the VBA project object model'.", vbCritical
        Exit Sub
    End If
    
    ' Check if it already exists
    On Error Resume Next
    Set vbc = vbp.VBComponents(modName)
    On Error GoTo 0
    
    If Not vbc Is Nothing Then
        MsgBox "The component '" & modName & "' already exists.", vbExclamation
    Else
        ' Create the new component using the integer constant
        Set vbc = vbp.VBComponents.Add(modType)
        vbc.Name = modName
        
        ' Insert the code
        vbc.CodeModule.AddFromString fullText
    End If
End Sub
