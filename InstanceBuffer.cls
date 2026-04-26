' ============================================================
' Class Module: InstanceBuffer.cls
' Version : BIOLOGICAL v2.60 - 2026-04-15
' High-performance flat-array instance buffer with one-time VAO setup
' ============================================================

Option Explicit

Private m_VAO As Long
Private m_VBO As Long
Private m_InstanceVBO As Long
Private m_IndexVBO As Long

Private m_Particles() As ParticleData
Private m_FlatArray() As Single
Private m_InstanceCount As Long
Private m_MaxParticles As Long
Private m_AttributesSetup As Boolean

Public Sub Initialize(ByVal maxParticles As Long)
    m_MaxParticles = maxParticles
    ReDim m_Particles(1 To maxParticles)
    m_InstanceCount = 0
    m_AttributesSetup = False
    
    GL.glGenVertexArrays 1, m_VAO
    GL.glGenBuffers 1, m_VBO
    GL.glGenBuffers 1, m_InstanceVBO
    GL.glGenBuffers 1, m_IndexVBO
End Sub

Public Sub AddParticle(ByRef p As ParticleData)
    If m_InstanceCount >= m_MaxParticles Then Exit Sub
    m_InstanceCount = m_InstanceCount + 1
    m_Particles(m_InstanceCount) = p
End Sub

Public Sub Update(ByVal deltaTime As Single)
    Dim i As Long
    For i = 1 To m_InstanceCount
        With m_Particles(i)
            .Position.x = .Position.x + .Velocity.x * deltaTime
            .Position.y = .Position.y + .Velocity.y * deltaTime
            .Position.z = .Position.z + .Velocity.z * deltaTime
            .Life = .Life - deltaTime
        End With
    Next i
End Sub

Public Sub UploadToGPU()
    If m_InstanceCount = 0 Then Exit Sub
    PackParticlesFlat m_Particles, m_FlatArray
    
    GL.glBindVertexArray m_VAO
    If Not m_AttributesSetup Then
        GL.glBindBuffer GL.GL_ARRAY_BUFFER, m_VBO
        GL.glBufferData GL.GL_ARRAY_BUFFER, UBound(m_FlatArray) * 4, m_FlatArray(0), GL.GL_DYNAMIC_DRAW
        
        GL.glEnableVertexAttribArray 0
        GL.glVertexAttribPointer 0, 3, GL.GL_FLOAT, GL.GL_FALSE, 32, ByVal 0&
        GL.glEnableVertexAttribArray 1
        GL.glVertexAttribPointer 1, 3, GL.GL_FLOAT, GL.GL_FALSE, 32, ByVal 12&
        GL.glEnableVertexAttribArray 2
        GL.glVertexAttribPointer 2, 1, GL.GL_FLOAT, GL.GL_FALSE, 32, ByVal 24&
        GL.glEnableVertexAttribArray 3
        GL.glVertexAttribPointer 3, 1, GL.GL_FLOAT, GL.GL_FALSE, 32, ByVal 28&
        
        m_AttributesSetup = True
    Else
        GL.glBindBuffer GL.GL_ARRAY_BUFFER, m_VBO
        GL.glBufferSubData GL.GL_ARRAY_BUFFER, 0, m_InstanceCount * 32, m_FlatArray(0)
    End If
    GL.glBindVertexArray 0
End Sub

Public Sub Draw(ByVal particleType As String)
    If m_InstanceCount = 0 Then Exit Sub
    Renderer.DrawInstancedParticles Me, particleType
End Sub

Public Property Get InstanceCount() As Long
    InstanceCount = m_InstanceCount
End Property

Public Property Get VAO() As Long
    VAO = m_VAO
End Property

Public Sub Shutdown()
    GL.glDeleteVertexArrays 1, m_VAO
    GL.glDeleteBuffers 1, m_VBO
    GL.glDeleteBuffers 1, m_InstanceVBO
    GL.glDeleteBuffers 1, m_IndexVBO
End Sub
