' ============================================================
' Class Module: EnemyEvolutionManager.cls
' Version : BIOLOGICAL v2.61 - 2026-04-15
' Morphogenesis-driven enemy evolution using live Turing analysis
' Enhanced with neural network mutation
' ============================================================

Option Explicit

Private m_Turing As TuringPatternAnalyzer

Public Sub Initialize(ByVal turingAnalyzer As TuringPatternAnalyzer)
    Set m_Turing = turingAnalyzer
End Sub

Public Sub EvolveEnemy(ByVal enemy As EnemyInstance, ByVal deltaTime As Single)
    If enemy Is Nothing Then Exit Sub
    
    Dim complexity As Single
    complexity = m_Turing.Entropy + m_Turing.SpotRatio * 2#
    
    ' Core evolution
    enemy.Speed = enemy.BaseSpeed * (1# + complexity * 0.9)
    enemy.Aggression = enemy.BaseAggression * (1# + complexity * 1.3)
    enemy.Size = enemy.BaseSize * (0.8 + complexity * 0.7)
    
    ' Neural network mutation when complexity is high
    If complexity > 0.75 And Rnd < 0.12 Then
        If Not enemy.Brain Is Nothing Then
            enemy.Brain.Mutate 0.25
        End If
    End If
    
    ' Clamp values
    If enemy.Speed > 35 Then enemy.Speed = 35
    If enemy.Aggression > 4.5 Then enemy.Aggression = 4.5
    If enemy.Size > 3# Then enemy.Size = 3#
End Sub

Public Sub EvolveSwarm(ByVal swarm As FPSPredatorPreySwarm, ByVal deltaTime As Single)
    If swarm Is Nothing Then Exit Sub
    Dim i As Long
    For i = 1 To swarm.CurrentCount
        Dim enemy As EnemyInstance
        Set enemy = swarm.GetEnemy(i)
        If Not enemy Is Nothing Then EvolveEnemy enemy, deltaTime
    Next i
End Sub

Public Sub Shutdown()
    Set m_Turing = Nothing
End Sub
