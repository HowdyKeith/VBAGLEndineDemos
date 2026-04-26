' ============================================================
' Class Module: EnemyInstance.cls
' Version : BIOLOGICAL v2.67 - 2026-04-15
' Individual enemy unit with neural brain and collision support
' ============================================================

Option Explicit

Private m_Position As Vector3
Private m_Velocity As Vector3
Private m_Health As Single
Private m_Size As Single
Private m_Speed As Single
Private m_Aggression As Single
Private m_IsPredator As Boolean
Private m_IsDead As Boolean

Public BaseSpeed As Single
Public BaseAggression As Single
Public BaseSize As Single

Private m_Brain As NeuralEnemyBrain

Public Sub SpawnRandom(ByVal isPredator As Boolean)
    m_IsPredator = isPredator
    m_IsDead = False
    
    m_Position.x = -25 + Rnd * 50
    m_Position.y = 1.5 + Rnd * 10
    m_Position.z = -25 + Rnd * 50
    
    m_Velocity.x = (Rnd - 0.5) * 12
    m_Velocity.y = (Rnd - 0.5) * 6
    m_Velocity.z = (Rnd - 0.5) * 12
    
    If m_IsPredator Then
        m_Health = 85
        BaseSpeed = 15.5
        BaseAggression = 2.4
        BaseSize = 1.9
    Else
        m_Health = 48
        BaseSpeed = 9.5
        BaseAggression = 1.15
        BaseSize = 1.25
    End If
    
    m_Speed = BaseSpeed
    m_Aggression = BaseAggression
    m_Size = BaseSize
    
    Set m_Brain = New NeuralEnemyBrain
    m_Brain.Initialize
End Sub

Public Sub Update(ByVal deltaTime As Single, ByVal pheromoneSSBO As Long, ByVal lvSSBO As Long)
    If m_IsDead Then Exit Sub
    
    Dim inputs(1 To 8) As Single
    inputs(1) = 0.6
    inputs(2) = 0.5
    inputs(3) = 0.5
    inputs(4) = 0.5
    inputs(5) = m_Health / 100
    inputs(6) = m_Velocity.x
    inputs(7) = m_Velocity.z
    inputs(8) = Rnd
    
    Dim steerX As Single, steerZ As Single, speedMod As Single
    m_Brain.Think inputs, steerX, steerZ, speedMod
    
    m_Velocity.x = m_Velocity.x + steerX * m_Aggression * deltaTime
    m_Velocity.z = m_Velocity.z + steerZ * m_Aggression * deltaTime
    m_Speed = m_Speed * (1 + speedMod * 0.2)
    
    Dim len As Single
    len = Sqr(m_Velocity.x ^ 2 + m_Velocity.y ^ 2 + m_Velocity.z ^ 2)
    If len > m_Speed Then
        m_Velocity.x = m_Velocity.x * (m_Speed / len)
        m_Velocity.y = m_Velocity.y * (m_Speed / len)
        m_Velocity.z = m_Velocity.z * (m_Speed / len)
    End If
    
    m_Position.x = m_Position.x + m_Velocity.x * deltaTime
    m_Position.y = m_Position.y + m_Velocity.y * deltaTime
    m_Position.z = m_Position.z + m_Velocity.z * deltaTime
    
    If m_Position.y < m_Size Then
        m_Position.y = m_Size
        m_Velocity.y = -m_Velocity.y * 0.65
    End If
End Sub

Public Sub Render(ByVal camera As GLCamera)
    If m_IsDead Then Exit Sub
    
    GL.glPushMatrix
    GL.glTranslatef m_Position.x, m_Position.y, m_Position.z
    GL.glScalef m_Size, m_Size, m_Size
    
    If m_IsPredator Then
        GL.glColor3f 1, 0.25, 0.25
    Else
        GL.glColor3f 0.3, 1, 0.4
    End If
    
    GL.glPopMatrix
End Sub

Public Sub TakeDamage(ByVal amount As Single)
    m_Health = m_Health - amount
    If m_Health <= 0 Then m_IsDead = True
End Sub

Public Property Get IsDead() As Boolean
    IsDead = m_IsDead
End Property

Public Property Get Position() As Vector3
    Position = m_Position
End Property

Public Property Get Speed() As Single
    Speed = m_Speed
End Property
Public Property Let Speed(ByVal value As Single)
    m_Speed = value
End Property

Public Property Get Aggression() As Single
    Aggression = m_Aggression
End Property
Public Property Let Aggression(ByVal value As Single)
    m_Aggression = value
End Property

Public Property Get Size() As Single
    Size = m_Size
End Property
Public Property Let Size(ByVal value As Single)
    m_Size = value
End Property

Public Property Get Brain() As NeuralEnemyBrain
    Set Brain = m_Brain
End Property

Public Sub Shutdown()
    If Not m_Brain Is Nothing Then
        m_Brain.Shutdown
        Set m_Brain = Nothing
    End If
End Sub
