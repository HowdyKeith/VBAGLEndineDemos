' ============================================================
' Class Module: Quadtree.cls
' Version : BIOLOGICAL v2.64 - 2026-04-15
' Adaptive quadtree spatial partitioning for fast collision detection and neighbor queries
' Optimized for 9-species ecosystem and enemy swarm clustering
' ============================================================

Option Explicit

Private Type QuadNode
    Bounds As CollisionSphere   ' Center + Radius defines the node bounds
    Entities As Collection      ' List of EnemyInstance in this node
    Children(0 To 3) As QuadNode ' 0=NE, 1=NW, 2=SE, 3=SW
    IsLeaf As Boolean
End Type

Private m_Root As QuadNode
Private m_MaxDepth As Long
Private m_MaxEntitiesPerNode As Long

Public Sub Initialize(ByVal worldMinX As Single, ByVal worldMinZ As Single, ByVal worldMaxX As Single, ByVal worldMaxZ As Single, Optional ByVal maxDepth As Long = 6, Optional ByVal maxEntitiesPerNode As Long = 8)
    m_MaxDepth = maxDepth
    m_MaxEntitiesPerNode = maxEntitiesPerNode
    
    With m_Root
        .Bounds.center.x = (worldMinX + worldMaxX) / 2
        .Bounds.center.z = (worldMinZ + worldMaxZ) / 2
        .Bounds.radius = Sqr(((worldMaxX - worldMinX) / 2) ^ 2 + ((worldMaxZ - worldMinZ) / 2) ^ 2)
        Set .Entities = New Collection
        .IsLeaf = True
    End With
End Sub

Public Sub Clear()
    Set m_Root.Entities = New Collection
    Erase m_Root.Children
    m_Root.IsLeaf = True
End Sub

Public Sub Insert(ByVal enemy As EnemyInstance)
    If enemy Is Nothing Or enemy.IsDead Then Exit Sub
    InsertRecursive m_Root, enemy, 0
End Sub

Private Sub InsertRecursive(ByRef node As QuadNode, ByVal enemy As EnemyInstance, ByVal depth As Long)
    If node.IsLeaf Then
        node.Entities.Add enemy
        If node.Entities.count > m_MaxEntitiesPerNode And depth < m_MaxDepth Then
            Subdivide node, depth
        End If
    Else
        Dim childIndex As Long
        childIndex = GetChildIndex(node, enemy.Position)
        InsertRecursive node.Children(childIndex), enemy, depth + 1
    End If
End Sub

Private Sub Subdivide(ByRef node As QuadNode, ByVal depth As Long)
    Dim halfRadius As Single
    halfRadius = node.Bounds.radius / 2
    
    Dim cx As Single, cz As Single
    cx = node.Bounds.center.x
    cz = node.Bounds.center.z
    
    Dim i As Long
    For i = 0 To 3
        Set node.Children(i) = New QuadNode
        Set node.Children(i).Entities = New Collection
        node.Children(i).IsLeaf = True
    Next i
    
    ' NE
    node.Children(0).Bounds.center.x = cx + halfRadius
    node.Children(0).Bounds.center.z = cz + halfRadius
    node.Children(0).Bounds.radius = halfRadius
    
    ' NW
    node.Children(1).Bounds.center.x = cx - halfRadius
    node.Children(1).Bounds.center.z = cz + halfRadius
    node.Children(1).Bounds.radius = halfRadius
    
    ' SE
    node.Children(2).Bounds.center.x = cx + halfRadius
    node.Children(2).Bounds.center.z = cz - halfRadius
    node.Children(2).Bounds.radius = halfRadius
    
    ' SW
    node.Children(3).Bounds.center.x = cx - halfRadius
    node.Children(3).Bounds.center.z = cz - halfRadius
    node.Children(3).Bounds.radius = halfRadius
    
    ' Re-insert existing entities
    Dim temp As Collection
    Set temp = node.Entities
    Set node.Entities = New Collection
    node.IsLeaf = False
    
    Dim e As EnemyInstance
    For Each e In temp
        InsertRecursive node, e, depth
    Next e
End Sub

Private Function GetChildIndex(ByRef node As QuadNode, ByRef pos As Vector3) As Long
    If pos.x >= node.Bounds.center.x Then
        If pos.z >= node.Bounds.center.z Then
            GetChildIndex = 0   ' NE
        Else
            GetChildIndex = 2   ' SE
        End If
    Else
        If pos.z >= node.Bounds.center.z Then
            GetChildIndex = 1   ' NW
        Else
            GetChildIndex = 3   ' SW
        End If
    End If
End Function

' Query nearby enemies within radius
Public Function QueryRadius(ByRef center As Vector3, ByVal radius As Single) As Collection
    Dim result As New Collection
    QueryRecursive m_Root, center, radius, result
    Set QueryRadius = result
End Function

Private Sub QueryRecursive(ByRef node As QuadNode, ByRef center As Vector3, ByVal radius As Single, ByRef result As Collection)
    If node Is Nothing Then Exit Sub
    
    ' Quick reject if node is completely outside query circle
    Dim dist As Single
    dist = Vec3Distance(node.Bounds.center, center)
    If dist > node.Bounds.radius + radius Then Exit Sub
    
    ' Add entities in this node
    If Not node.Entities Is Nothing Then
        Dim e As EnemyInstance
        For Each e In node.Entities
            If Not e.IsDead Then
                If Vec3Distance(e.Position, center) <= radius Then
                    result.Add e
                End If
            End If
        Next e
    End If
    
    ' Recurse into children
    If Not node.IsLeaf Then
        Dim i As Long
        For i = 0 To 3
            QueryRecursive node.Children(i), center, radius, result
        Next i
    End If
End Sub

Public Sub Shutdown()
    Clear
End Sub
