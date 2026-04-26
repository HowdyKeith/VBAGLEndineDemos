' ============================================================
' Class Module: CameraEffectSystem.cls
' Version : BIOLOGICAL v1.6 - 2026-04-15
' Morphogenesis-driven camera effects using live Turing analysis
' ============================================================

Option Explicit

Private m_Camera As GLCamera
Private m_Turing As TuringPatternAnalyzer

Public Sub Initialize(ByVal camera As GLCamera, ByVal turingAnalyzer As TuringPatternAnalyzer)
    Set m_Camera = camera
    Set m_Turing = turingAnalyzer
End Sub

Public Sub ApplyEffects(ByVal deltaTime As Single)
    Dim complexity As Single
    complexity = m_Turing.Entropy + m_Turing.SpotRatio * 1.5
    
    ' Breathing FOV (pulse with pattern complexity)
    m_Camera.FOV = 75 + Sin(Timer * 6) * (complexity * 12)
    
    ' Color tint based on morphogenesis (cyan for waves, orange for spots)
    If m_Turing.SpotRatio > 0.4 Then
        m_Camera.SetColorTint 1.2, 0.8, 0.3   ' Warm orange
    Else
        m_Camera.SetColorTint 0.4, 1.1, 1.3   ' Cool cyan
    End If
    
    ' Camera shake on high entropy (chaotic patterns)
    If m_Turing.Entropy > 0.6 Then
        m_Camera.Position.x = m_Camera.Position.x + (Rnd - 0.5) * complexity * 0.3
        m_Camera.Position.y = m_Camera.Position.y + (Rnd - 0.5) * complexity * 0.3
    End If
End Sub

Public Sub Shutdown()
    Set m_Turing = Nothing
End Sub
