' ============================================================
' Class Module: WeaponTrailSystem.cls
' Version : BIOLOGICAL v2.4 - 2026-04-15
' Morphogenesis-driven weapon trails with dynamic bloom
' ============================================================

Option Explicit

Private m_Trails As instanceBuffer
Private m_Morpho As ComputeMorphogenesisSystem
Private m_Turing As TuringPatternAnalyzer

Public Sub Initialize(ByVal morpho As ComputeMorphogenesisSystem, ByVal turing As TuringPatternAnalyzer)
    Set m_Morpho = morpho
    Set m_Turing = turing
    Set m_Trails = New instanceBuffer
    m_Trails.Initialize 2000   ' more particles for bloom effect
End Sub

Public Sub FireTrail(ByVal startPos As Vector3)
    Dim complexity As Single
    complexity = m_Turing.Entropy + m_Turing.SpotRatio * 2.8
    
    Dim bloomFactor As Single
    bloomFactor = 1# + complexity * 2.5    ' bloom strength
    
    Dim i As Long
    For i = 1 To 45 + CInt(complexity * 55)
        Dim p As ParticleData
        p.Position = startPos
        p.Velocity = RandomForwardVelocity * (1.6 + complexity)
        p.Life = 1# + Rnd * complexity
        p.color = IIf(m_Turing.SpotRatio > 0.5, RGB(255, 140, 40), RGB(80, 255, 240))
        p.Size = bloomFactor * (0.8 + Rnd)   ' bloom size
        m_Trails.AddParticle p
    Next i
End Sub

Public Sub Update(ByVal deltaTime As Single)
    m_Trails.Update deltaTime
    m_Trails.UploadToGPU
End Sub

Public Sub RenderWithBloom()
    Renderer.DrawInstancedParticles m_Trails, "weapon_trails_bloom"
End Sub

Public Sub Shutdown()
    m_Trails.Shutdown
End Sub
