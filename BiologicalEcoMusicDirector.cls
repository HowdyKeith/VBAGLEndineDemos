' ============================================================
' Class Module: BiologicalEcosystemMusicDirector.cls
' Version : BIOLOGICAL v2.3 - 2026-04-15
' Full music director – controls tempo, layers, mood, and instruments based on 7-species ecosystem + morphogenesis
' ============================================================

Option Explicit

Private m_Turing As TuringPatternAnalyzer
Private m_Ecosystem As FullEcosystem7Species
Private m_LastBeat As Single
Private m_Tempo As Single
Private m_Mood As String

Public Sub Initialize(ByVal turing As TuringPatternAnalyzer, ByVal ecosystem As FullEcosystem7Species)
    Set m_Turing = turing
    Set m_Ecosystem = ecosystem
    m_Tempo = 120
    m_Mood = "Calm"
End Sub

Public Sub UpdateMusic(ByVal deltaTime As Single)
    Dim complexity As Single
    complexity = m_Turing.Entropy + m_Turing.SpotRatio * 2.2
    
    m_Tempo = 80 + complexity * 140   ' 80–220 BPM
    
    ' Mood based on ecosystem state
    If m_Ecosystem.TopPredatorCount > m_Ecosystem.SlimeCount * 2 Then
        m_Mood = "Aggressive"
    ElseIf m_Turing.SpotRatio > 0.6 Then
        m_Mood = "Organic Pulse"
    Else
        m_Mood = "Flowing Waves"
    End If
    
    ' Beat
    If Timer() - m_LastBeat > 60 / m_Tempo Then
        Dim freq As Long
        freq = 180 + CInt(complexity * 300)
        Beep freq, 25
        If m_Mood = "Aggressive" Then Beep freq \ 2, 40   ' bass hit
        m_LastBeat = Timer()
    End If
    
    ' Melody layer
    If Rnd < 0.15 Then
        Beep freq * 1.5 + 80, 15
    End If
End Sub

Public Sub Shutdown()
    Set m_Turing = Nothing
    Set m_Ecosystem = Nothing
End Sub
