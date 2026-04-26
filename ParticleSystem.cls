' ============================================================
' Class Module: ParticleSystem.cls
' Version : BIOLOGICAL v2.5 - 2026-04-15
' Central high-performance particle manager with morphogenesis coupling
' Uses InstanceBuffer for GPU instancing and bloom support
' ============================================================

Option Explicit

Private m_InstanceBuffer As instanceBuffer
Private m_Morpho As ComputeMorphogenesisSystem
Private m_Turing As TuringPatternAnalyzer

Public SpawnRateMultiplier As Single

Public Sub Initialize(ByVal morpho As ComputeMorphogenesisSystem, ByVal turing As TuringPatternAnalyzer)
    Set m_Morpho = morpho
    Set m_Turing = turing
    Set m_InstanceBuffer = New instanceBuffer
    m_InstanceBuffer.Initialize 8000   ' High capacity for rich effects
    SpawnRateMultiplier = 1#
End Sub

Public Sub Update(ByVal deltaTime As Single)
    Dim complexity As Single
    complexity = m_Turing.Entropy + m_Turing.SpotRatio * 2#
    
    ' Morphogenesis-driven spawn rate
    Dim spawnCount As Long
    spawnCount = CInt(SpawnRateMultiplier * complexity * 100)
    
    Dim i As Long
    For i = 1 To spawnCount
        Dim p As ParticleData
        p.Position = RandomPointNearCamera
        p.Velocity = RandomVelocity * (1# + complexity)
        p.Life = 1.2 + Rnd * complexity
        p.Size = 1# + Rnd * complexity * 0.8
        p.ColorR = IIf(m_Turing.SpotRatio > 0.5, 1#, 0.35)
        p.ColorG = IIf(m_Turing.SpotRatio > 0.5, 0.65, 1#)
        p.ColorB = IIf(m_Turing.SpotRatio > 0.5, 0.25, 1#)
        m_InstanceBuffer.AddParticle p
    Next i
    
    m_InstanceBuffer.Update deltaTime
    m_InstanceBuffer.UploadToGPU
End Sub

Public Sub Render()
    Renderer.DrawInstancedParticles m_InstanceBuffer, "weapon_trails_bloom"
End Sub

Public Sub Shutdown()
    If Not m_InstanceBuffer Is Nothing Then m_InstanceBuffer.Shutdown
End Sub
