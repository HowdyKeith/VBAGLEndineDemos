' ============================================================
' Class Module: BiologicalAIDirector.cls
' Version : BIOLOGICAL v2.1 - 2026-04-15
' Complete AI Director – evolves entire demo difficulty from morphogenesis
' ============================================================

Option Explicit

Private m_Morpho As ComputeMorphogenesisSystem
Private m_Turing As TuringPatternAnalyzer
Private m_Ecosystem As FullEcosystem5Species
Private m_EnemySwarm As FPSPredatorPreySwarm
Private m_CameraEffects As ScreenShakeBloomSystem
Private m_Particles As ParticleEffectSystem
Private m_Explosions As ExplosionVFXSystem
Private m_Music As BiologicalMusicSynthesizer

Public DifficultyLevel As Single   ' 0.0–1.0 driven by live morphogenesis

Public Sub Initialize( _
    ByVal morpho As ComputeMorphogenesisSystem, _
    ByVal turing As TuringPatternAnalyzer, _
    ByVal ecosystem As FullEcosystem5Species, _
    ByVal EnemySwarm As FPSPredatorPreySwarm, _
    ByVal CameraEffects As ScreenShakeBloomSystem, _
    ByVal particles As ParticleEffectSystem, _
    ByVal explosions As ExplosionVFXSystem, _
    ByVal music As BiologicalMusicSynthesizer)
    
    Set m_Morpho = morpho
    Set m_Turing = turing
    Set m_Ecosystem = ecosystem
    Set m_EnemySwarm = EnemySwarm
    Set m_CameraEffects = CameraEffects
    Set m_Particles = particles
    Set m_Explosions = explosions
    Set m_Music = music
    DifficultyLevel = 0.5
End Sub

Public Sub UpdateDirector(ByVal deltaTime As Single)
    DifficultyLevel = m_Turing.Entropy + m_Turing.SpotRatio * 1.8
    DifficultyLevel = Application.Min(DifficultyLevel, 1#)
    
    ' Evolve everything
    m_EnemySwarm.GlobalDifficulty = DifficultyLevel
    m_Ecosystem.UpdateDifficulty DifficultyLevel
    m_Particles.SpawnRateMultiplier = 1# + DifficultyLevel * 3.5
    m_Explosions.Intensity = 1# + DifficultyLevel * 2.8
    m_Music.TempoMultiplier = 1# + DifficultyLevel * 0.8
    
    ' Camera shake + bloom already handled in ScreenShakeBloomSystem
    ' (called from main loop)
End Sub

Public Sub Shutdown()
    ' references only
End Sub

Public Sub QueryOllamaForFlavor()
    ' Simple HTTP call to your running Ollama instance (localhost:11434)
    Dim http As Object
    Set http = CreateObject("MSXML2.XMLHTTP")
    http.Open "POST", "http://localhost:11434/api/generate", False
    http.setRequestHeader "Content-Type", "application/json"
    http.Send "{""model"": ""llama3"", ""prompt"": ""Describe this morphogenesis pattern in one dramatic sentence for the FPS player: complexity = " & DifficultyLevel & """, ""stream"": false}"
    
    If http.Status = 200 Then
        Debug.Print "Ollama narrative: " & http.responseText   ' e.g. "The cells are forming a living storm..."
        ' You can display this in a Debug.Print or on-sheet message box
    End If
End Sub


