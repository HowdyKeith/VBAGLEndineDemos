' ============================================================
' Class Module: EcosystemLeaderboard.cls
' Version : BIOLOGICAL v1.9 - 2026-04-15
' Full biological ecosystem leaderboard with persistent high scores
' ============================================================

Option Explicit

Private m_Turing As TuringPatternAnalyzer
Private m_Morpho As ComputeMorphogenesisSystem

Public Sub Initialize(ByVal turing As TuringPatternAnalyzer, ByVal morpho As ComputeMorphogenesisSystem)
    Set m_Turing = turing
    Set m_Morpho = morpho
End Sub

Public Sub UpdateLeaderboard(ByVal CurrentScore As Long)
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BioControls")
    
    ' Header
    ws.range("A50").value = "Rank"
    ws.range("B50").value = "Pattern"
    ws.range("C50").value = "Complexity"
    ws.range("D50").value = "High Score"
    
    ' Current run
    ws.range("A51").value = 1
    ws.range("B51").value = m_Turing.patternType
    ws.range("C51").value = format(m_Turing.Entropy, "0.000")
    ws.range("D51").value = CurrentScore
    
    ' Check & update high score
    If CurrentScore > ws.range("D52").value Then
        ws.range("D52").value = CurrentScore
        ws.range("B52").value = m_Turing.patternType
        Debug.Print "NEW HIGH SCORE! " & CurrentScore
    End If
End Sub

Public Sub Shutdown()
    Set m_Turing = Nothing
    Set m_Morpho = Nothing
End Sub
