' ============================================================
' Class Module: WeatherSystem.cls
' Version : BIOLOGICAL v2.5 - 2026-04-15
' Weather ecosystem effects (rain, wind, fog) coupled to morphogenesis and 9-species ecosystem
' Affects particle behavior, slime diffusion, enemy movement, and visual bloom
' ============================================================

Option Explicit

Private m_Morpho As ComputeMorphogenesisSystem
Private m_Turing As TuringPatternAnalyzer
Private m_Ecosystem As FullEcosystem9Species

' Live weather parameters
Public WindStrength As Single
Public RainIntensity As Single
Public FogDensity As Single

Public Sub Initialize(ByVal morpho As ComputeMorphogenesisSystem, ByVal turing As TuringPatternAnalyzer, ByVal ecosystem As FullEcosystem9Species)
    Set m_Morpho = morpho
    Set m_Turing = turing
    Set m_Ecosystem = ecosystem
    
    WindStrength = 0.5
    RainIntensity = 0.3
    FogDensity = 0.1
End Sub

Public Sub UpdateWeather(ByVal deltaTime As Single)
    Dim complexity As Single
    complexity = m_Turing.Entropy + m_Turing.SpotRatio * 1.8
    
    ' Morphogenesis drives weather
    WindStrength = 0.3 + complexity * 1.4
    RainIntensity = 0.2 + complexity * 0.9
    FogDensity = 0.05 + complexity * 0.6
    
    ' Weather affects ecosystem
    m_Ecosystem.WindEffect = WindStrength
    m_SlimeSystem.DiffuseRate = m_SlimeSystem.DiffuseRate * (1 + WindStrength * 0.2)
    m_EnemySwarm.Aggression = m_EnemySwarm.Aggression * (1 + RainIntensity * 0.15)
End Sub

Public Sub RenderWeatherEffects()
    ' Optional: render rain particles or fog quad
    ' (can be expanded with ParticleSystem for rain)
End Sub

Public Sub Shutdown()
    Set m_Morpho = Nothing
    Set m_Turing = Nothing
    Set m_Ecosystem = Nothing
End Sub
