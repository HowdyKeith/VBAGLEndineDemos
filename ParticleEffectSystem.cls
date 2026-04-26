' ============================================================
' Class Module: ParticleEffectSystem.cls
' Version : BIOLOGICAL v1.8 - 2026-04-15
' Morphogenesis-driven GPU particles reacting to activator/inhibitor fields
' ============================================================

Option Explicit

Private m_Particles As instanceBuffer
Private m_Morpho As ComputeMorphogenesisSystem
Private m_Turing As TuringPatternAnalyzer

Public Sub Initialize(ByVal morpho As ComputeMorphogenesisSystem, ByVal turing As TuringPatternAnalyzer)
    Set m_Morpho = morpho
    Set m_Turing = turing
    Set m_Particles = New instanceBuffer
    m_Particles.Initialize 5000   ' max particles
End Sub

Public Sub Update(ByVal deltaTime As Single)
    Dim complexity As Single
    complexity = m_Turing.Entropy + m_Turing.SpotRatio * 2
    
    ' Spawn rate scales with morphogenesis activity
    Dim spawnCount As Long
    spawnCount = CInt(complexity * 120)
    
    Dim i As Long
    For i = 1 To spawnCount
        Dim p As ParticleData
        p.Position = RandomPointInGrid
        p.Velocity = RandomVelocity * (1 + complexity)
        p.Life = 2# + Rnd * complexity
        p.color = IIf(m_Turing.SpotRatio > 0.4, RGB(255, 180, 60), RGB(80, 255, 255))   ' orange spots vs cyan waves
        m_Particles.AddParticle p
    Next i
    
    m_Particles.Update deltaTime
    m_Particles.UploadToGPU
End Sub

Public Sub Render()
    Renderer.DrawInstancedParticles m_Particles, "morpho_particles"
End Sub

Public Sub Shutdown()
    m_Particles.Shutdown
End Sub
