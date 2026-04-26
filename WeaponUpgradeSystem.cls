' ============================================================
' Class Module: WeaponUpgradeSystem.cls
' Version : BIOLOGICAL v1.6 - 2026-04-15
' Morphogenesis-driven weapon upgrades using live Turing analysis
' ============================================================

Option Explicit

Private m_Turing As TuringPatternAnalyzer
Private m_DamageMultiplier As Single
Private m_FireRateMultiplier As Single
Private m_SpecialBlastChance As Single

Public Sub Initialize(ByVal turingAnalyzer As TuringPatternAnalyzer)
    Set m_Turing = turingAnalyzer
    m_DamageMultiplier = 1#
    m_FireRateMultiplier = 1#
    m_SpecialBlastChance = 0#
End Sub

Public Sub UpdateUpgrades()
    Dim complexity As Single
    complexity = m_Turing.Entropy + m_Turing.SpotRatio * 1.8 + m_Turing.StripeRatio * 0.6
    
    ' Morphogenesis complexity directly upgrades weapons
    m_DamageMultiplier = 1# + complexity * 1.4
    m_FireRateMultiplier = 1# + complexity * 0.9
    m_SpecialBlastChance = complexity * 0.45   ' Chance of explosive shot
    
    ' Write current upgrades to BioControls sheet
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BioControls")
    ws.range("H8").value = format(m_DamageMultiplier, "0.00") & "x"
    ws.range("H9").value = format(m_FireRateMultiplier, "0.00") & "x"
    ws.range("H10").value = format(m_SpecialBlastChance * 100, "0") & "%"
End Sub

Public Function GetDamageMultiplier() As Single: GetDamageMultiplier = m_DamageMultiplier: End Function
Public Function GetFireRateMultiplier() As Single: GetFireRateMultiplier = m_FireRateMultiplier: End Function
Public Function GetSpecialBlastChance() As Single: GetSpecialBlastChance = m_SpecialBlastChance: End Function

Public Sub Shutdown()
    Set m_Turing = Nothing
End Sub
