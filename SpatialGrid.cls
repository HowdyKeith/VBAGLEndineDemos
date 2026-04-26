' ============================================================
' Class Module: SpatialGrid.cls
' Version : BIOLOGICAL v2.67 - 2026-04-15
' Uniform grid spatial partitioning (best performance for VBA)
' Includes enemy-enemy and player-enemy collision response
' ============================================================

Option Explicit

Private m_CellSize As Single
Private m_GridWidth As Long
Private m_GridHeight As Long
Private m_Cells() As Collection

Public Sub Initialize(ByVal worldMinX As Single, ByVal worldMinZ As Single, ByVal worldMaxX As Single, ByVal worldMaxZ As Single, ByVal cellSize As Single)
    m_CellSize = cellSize
    m_GridWidth = CInt((worldMaxX - worldMinX) / cellSize) + 1
    m_GridHeight = CInt((worldMaxZ - worldMinZ) / cellSize) + 1
    
    ReDim m_Cells(0 To m_GridWidth - 1, 0 To m_GridHeight - 1)
    Dim x As Long, z As Long
    For x = 0 To m_GridWidth - 1
        For z = 0 To m_GridHeight - 1
            Set m_Cells(x, z) = New Collection
        Next z
    Next x
End Sub

Public Sub Clear()
    Dim x As Long, z As Long
    For x = 0 To m_GridWidth - 1
        For z = 0 To m_GridHeight - 1
            Set m_Cells(x, z) = New Collection
        Next z
    Next x
End Sub

Public Sub AddEnemy(ByVal enemy As EnemyInstance)
    If enemy Is Nothing Or enemy.IsDead Then Exit Sub
    Dim cellX As Long, cellZ As Long
    cellX = CInt(enemy.Position.x / m_CellSize)
    cellZ = CInt(enemy.Position.z / m_CellSize)
    If cellX >= 0 And cellX < m_GridWidth And cellZ >= 0 And cellZ < m_GridHeight Then
        m_Cells(cellX, cellZ).Add enemy
    End If
End Sub

Public Function QueryRadius(ByRef center As Vector3, ByVal radius As Single) As Collection
    Dim result As New Collection
    Dim cellX As Long, cellZ As Long
    cellX = CInt(center.x / m_CellSize)
    cellZ = CInt(center.z / m_CellSize)
    Dim range As Long
    range = CInt(radius / m_CellSize) + 1
    
    Dim x As Long, z As Long, i As Long
    For x = cellX - range To cellX + range
        For z = cellZ - range To cellZ + range
            If x >= 0 And x < m_GridWidth And z >= 0 And z < m_GridHeight Then
                Dim col As Collection
                Set col = m_Cells(x, z)
                For i = 1 To col.count
                    Dim e As EnemyInstance
                    Set e = col(i)
                    If Not e.IsDead Then
                        If Vec3Distance(e.Position, center) <= radius Then
                            result.Add e
                        End If
                    End If
                Next i
            End If
        Next z
    Next x
    Set QueryRadius = result
End Function

Public Sub ResolveCollisions()
    Dim x As Long, z As Long, i As Long, j As Long
    For x = 0 To m_GridWidth - 1
        For z = 0 To m_GridHeight - 1
            Dim col As Collection
            Set col = m_Cells(x, z)
            For i = 1 To col.count
                Dim e1 As EnemyInstance
                Set e1 = col(i)
                If e1.IsDead Then Continue For
                For j = i + 1 To col.count
                    Dim e2 As EnemyInstance
                    Set e2 = col(j)
                    If e2.IsDead Then Continue For
                    
                    Dim dist As Single
                    dist = Vec3Distance(e1.Position, e2.Position)
                    Dim minDist As Single
                    minDist = e1.Size + e2.Size
                    
                    If dist < minDist And dist > 0.001 Then
                        Dim push As Vector3
                        push.x = (e1.Position.x - e2.Position.x) / dist
                        push.z = (e1.Position.z - e2.Position.z) / dist
                        Dim overlap As Single
                        overlap = minDist - dist
                        e1.Position.x = e1.Position.x + push.x * overlap * 0.5
                        e1.Position.z = e1.Position.z + push.z * overlap * 0.5
                        e2.Position.x = e2.Position.x - push.x * overlap * 0.5
                        e2.Position.z = e2.Position.z - push.z * overlap * 0.5
                    End If
                Next j
            Next i
        Next z
    Next x
End Sub

Public Sub ResolvePlayerCollisions(ByRef playerPos As Vector3, ByVal playerRadius As Single, ByVal damageAmount As Single)
    Dim nearby As Collection
    Set nearby = QueryRadius(playerPos, playerRadius + 3)
    
    Dim i As Long
    For i = 1 To nearby.count
        Dim e As EnemyInstance
        Set e = nearby(i)
        If e.IsDead Then Continue For
        
        Dim dist As Single
        dist = Vec3Distance(e.Position, playerPos)
        Dim minDist As Single
        minDist = e.Size + playerRadius
        
        If dist < minDist And dist > 0.001 Then
            Dim push As Vector3
            push.x = (e.Position.x - playerPos.x) / dist
            push.z = (e.Position.z - playerPos.z) / dist
            Dim overlap As Single
            overlap = minDist - dist
            e.Position.x = e.Position.x + push.x * overlap * 1.2
            e.Position.z = e.Position.z + push.z * overlap * 1.2
            
            Debug.Print "PLAYER HIT by enemy! Distance: " & format(dist, "0.00")
            ' TODO: Call your player damage method here: Player.TakeDamage damageAmount
        End If
    Next i
End Sub

Public Sub Shutdown()
    Erase m_Cells
End Sub
