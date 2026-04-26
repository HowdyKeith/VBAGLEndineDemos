' ============================================================
' Module: modConfigManager.bas
' Version : BIOLOGICAL v2.4 - 2026-04-15
' Save/Load + auto-create BioControls and SavedConfigs sheets
' ============================================================

Option Explicit

Public Sub EnsureSheetsExist()
    Dim ws As Worksheet
    
    ' Auto-create BioControls sheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("BioControls")
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Sheets.Add
        ws.Name = "BioControls"
        ' Add default values for all parameters
        ws.range("B20").value = 0          ' RD Pattern
        ws.range("B32").value = 0.08       ' ActivatorDiff
        ws.range("B33").value = 0.4        ' InhibitorDiff
        ws.range("B34").value = 0.02       ' ProductionRate
        ws.range("B35").value = 0.04       ' ActivatorDecay
        ws.range("B36").value = 0.06       ' InhibitorDecay
        ws.range("B37").value = 0.01       ' BaseProduction
        ws.range("B5").value = 0.8         ' Slime Diffuse
        ws.range("B6").value = 0.95        ' Slime Decay
    End If
    
    ' Auto-create SavedConfigs sheet
    Set ws = ThisWorkbook.Sheets("SavedConfigs")
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Sheets.Add
        ws.Name = "SavedConfigs"
    End If
    On Error GoTo 0
End Sub


Public Sub SaveCurrentConfig(ByVal slot As Long)
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BioControls")
    Dim saveSheet As Worksheet
    Set saveSheet = ThisWorkbook.Sheets("SavedConfigs")
    
    saveSheet.Cells(slot * 10 + 1, 1).value = "Slot " & slot & " - " & now
    saveSheet.range("B" & slot * 10 + 2).value = ws.range("B20").value   ' Pattern ID
    saveSheet.range("B" & slot * 10 + 3).value = ws.range("B32").value   ' ActivatorDiff
    saveSheet.range("B" & slot * 10 + 4).value = ws.range("B33").value   ' InhibitorDiff
    saveSheet.range("B" & slot * 10 + 5).value = ws.range("B34").value   ' ProductionRate
    ' ... add more parameters as needed ...
    
    Debug.Print "Configuration saved to slot " & slot
End Sub

Public Sub LoadConfig(ByVal slot As Long)
    Dim saveSheet As Worksheet
    Set saveSheet = ThisWorkbook.Sheets("SavedConfigs")
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BioControls")
    
    ws.range("B20").value = saveSheet.range("B" & slot * 10 + 2).value
    ws.range("B32").value = saveSheet.range("B" & slot * 10 + 3).value
    ws.range("B33").value = saveSheet.range("B" & slot * 10 + 4).value
    ws.range("B34").value = saveSheet.range("B" & slot * 10 + 5).value
    ' ... load more ...
    
    Debug.Print "Configuration loaded from slot " & slot
End Sub

Public Sub QuickSaveConfig()   ' F5
    SaveCurrentConfig 1
End Sub

Public Sub QuickLoadConfig()   ' F9
    LoadConfig 1
End Sub
