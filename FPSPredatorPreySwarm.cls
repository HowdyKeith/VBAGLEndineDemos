' ============================================================
' Class Module: FPSPredatorPreySwarm.cls
' Version : BIOLOGICAL v2.67 - 2026-04-15
' Full predator-prey enemy swarm with uniform grid + player-enemy collisions
' ============================================================

Option Explicit

Private m_Enemies() As EnemyInstance
Private m_MaxEnemies As Long
Private m_CurrentCount As Long

Public GlobalDifficulty As Single
Public Aggression As Single
Public CurrentScore As Long

Private m_Camera As GLCamera
Private m_AntSystem As ComputeAntColonySystem
Private m_LVSystem As ComputeSpatialLotkaVolterra

Private m_SpatialGrid As SpatialGrid

Public Sub Initialize(ByVal camera As GLCamera, ByVal antSystem As ComputeAntColonySystem, ByVal lvSystem As ComputeSpatialLotkaVolterra)
    Set m_Camera = camera
    Set m_AntSystem = antSystem
    Set m_LVSystem = lvSystem
    
    m_MaxEnemies = 80
    GlobalDifficulty = 0.5
    Aggression = 1.2
    CurrentScore = 0
    
    ReDim m_Enemies(1 To m_MaxEnemies)
    Dim i As Long
    For i = 1 To m_MaxEnemies
        Set m_Enemies(i) = New EnemyInstance
        m_Enemies(i).SpawnRandom (i > m_MaxEnemies * 0.4)
    Next i
    m_CurrentCount = m_MaxEnemies
    
    Set m_SpatialGrid = New SpatialGrid
    m_SpatialGrid.Initialize -50, -50, 50, 50, 8
End Sub

Public Sub Update(ByVal deltaTime As Single)
    m_SpatialGrid.Clear
    Dim i As Long
    For i = 1 To m_CurrentCount
        If Not m_Enemies(i).IsDead Then
            m_SpatialGrid.AddEnemy m_Enemies(i)
        End If
    Next i
    
    For i = 1 To m_CurrentCount
        If Not m_Enemies(i).IsDead Then
            m_Enemies(i).Update deltaTime, m_AntSystem.GetCurrentPheromoneSSBO(), m_LVSystem.GetCurrentGridSSBO()
        End If
    Next i
    
    m_SpatialGrid.ResolveCollisions
    
    Dim playerPos As Vector3
    playerPos = m_Camera.Position
    m_SpatialGrid.ResolvePlayerCollisions playerPos, 1.8, 8   ' player radius + damage amount
End Sub

Public Sub RenderScene(ByVal camera As GLCamera)
    Dim i As Long
    For i = 1 To m_CurrentCount
        If Not m_Enemies(i).IsDead Then
            m_Enemies(i).Render camera
        End If
    Next i
End Sub

Public Sub Shutdown()
    Dim i As Long
    For i = 1 To m_CurrentCount
        m_Enemies(i).Shutdown
    Next i
    If Not m_SpatialGrid Is Nothing Then m_SpatialGrid.Shutdown
End Sub
