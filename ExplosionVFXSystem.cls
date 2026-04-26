' ============================================================
' Class Module: ExplosionVFXSystem.cls
' Version : BIOLOGICAL v2.3 - 2026-04-15
' Morphogenesis-driven explosions with screen shake + bloom
' ============================================================

Option Explicit

Private m_Explosions As instanceBuffer
Private m_Morpho As ComputeMorphogenesisSystem
Private m_Turing As TuringPatternAnalyzer
Private m_Camera As GLCamera
Private m_BloomIntensity As Single

Public Sub Initialize(ByVal morpho As ComputeMorphogenesisSystem, ByVal turing As TuringPatternAnalyzer, ByVal camera As GLCamera)
    Set m_Morpho = morpho
    Set m_Turing = turing
    Set m_Camera = camera
    Set m_Explosions = New instanceBuffer
    m_Explosions.Initialize 3000
    m_BloomIntensity = 1#
End Sub

Public Sub TriggerExplosion(ByVal hitPos As Vector3)
    Dim complexity As Single
    complexity = m_Turing.Entropy + m_Turing.SpotRatio * 2.8
    
    ' Trigger screen shake
    m_Camera.AddScreenShake complexity * 1.8
    
    ' Set bloom intensity for post-process
    m_BloomIntensity = 1.2 + complexity * 2.4
    
    ' Spawn explosion particles
    Dim i As Long
    For i = 1 To 90 + CInt(complexity * 70)
        Dim p As ParticleData
        p.Position = hitPos
        p.Velocity = RandomExplosionVelocity * (2# + complexity)
        p.Life = 1.4 + Rnd * complexity
        p.color = IIf(m_Turing.SpotRatio > 0.5, RGB(255, 100, 20), RGB(120, 255, 255))
        m_Explosions.AddParticle p
    Next i
End Sub

Public Sub Update(ByVal deltaTime As Single)
    m_Explosions.Update deltaTime
    m_Explosions.UploadToGPU
    m_BloomIntensity = m_BloomIntensity * 0.92   ' natural decay
End Sub

Public Sub Render()
    Renderer.DrawInstancedParticles m_Explosions, "explosion_vfx"
End Sub

Public Function GetBloomIntensity() As Single
    GetBloomIntensity = m_BloomIntensity
End Function

Public Sub Shutdown()
    m_Explosions.Shutdown
End Sub
