' ============================================================
' Class Module: LeaderboardManager.cls
' Version : BIOLOGICAL v1.6 - 2026-04-15
' Full biological leaderboard on BioControls sheet
' ============================================================

Option Explicit

Private m_Turing As TuringPatternAnalyzer
Private m_Morpho As ComputeMorphogenesisSystem

Public Sub Initialize(ByVal turing As TuringPatternAnalyzer, ByVal morpho As ComputeMorphogenesisSystem)
    Set m_Turing = turing
    Set m_Morpho = morpho
End Sub

Public Sub UpdateLeaderboard()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BioControls")
    
    ' Leaderboard table (rows 40+)
    ws.range("A40").value = "Rank"
    ws.range("B40").value = "Pattern"
    ws.range("C40").value = "Complexity"
    ws.range("D40").value = "Spot %"
    ws.range("E40").value = "Stripe %"
    
    ' Current run
    ws.range("A41").value = 1
    ws.range("B41").value = m_Turing.patternType
    ws.range("C41").value = format(m_Turing.Entropy, "0.000")
    ws.range("D41").value = format(m_Turing.SpotRatio * 100, "0") & "%"
    ws.range("E41").value = format(m_Turing.StripeRatio * 100, "0") & "%"
    
    Debug.Print "Leaderboard updated – current top pattern: " & m_Turing.patternType
End Sub

Public Sub Shutdown()
    Set m_Turing = Nothing
    Set m_Morpho = Nothing
End Sub
