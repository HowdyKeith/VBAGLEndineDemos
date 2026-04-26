' ============================================================
' Class Module: ComputeSlimeMoldSystem.cls
' Version : BIOLOGICAL v1.2 - 2026-04-15
' Real Slime Mold (Physarum) Foraging Simulation on GPU
' ============================================================

Option Explicit

Private m_TrailSSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_GridWidth As Long
Private m_GridHeight As Long
Private m_Program As Long

Public DiffuseRate As Single
Public DecayRate As Single

Public Sub Initialize(ByVal width As Long, ByVal height As Long)
    m_GridWidth = width
    m_GridHeight = height
    m_CurrentRead = 0
    
    DiffuseRate = 0.8
    DecayRate = 0.95
    
    GL.glGenBuffers 2, m_TrailSSBO(0)
    Dim i As Long
    For i = 0 To 1
        GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_TrailSSBO(i)
        GL.glBufferData GL.GL_SHADER_STORAGE_BUFFER, width * height * 4, ByVal 0&, GL.GL_DYNAMIC_DRAW
    Next i
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_TrailSSBO(0)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_TrailSSBO(1)
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetSlimeMoldShader())
    InitializeSlimeGrid
End Sub

Private Sub InitializeSlimeGrid()
    ' Classic starting pattern: central food source + random agents
End Sub

Public Sub Update(ByVal deltaTime As Single)
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_TrailSSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_TrailSSBO(writeIdx)
    
    GL.glUseProgram m_Program
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "deltaTime"), deltaTime
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "diffuseRate"), DiffuseRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "decayRate"), DecayRate
    GL.glUniform1i GL.glGetUniformLocation(m_Program, "gridWidth"), m_GridWidth
    GL.glUniform1i GL.glGetUniformLocation(m_Program, "gridHeight"), m_GridHeight
    
    GL.glDispatchCompute (m_GridWidth + 15) \ 16, (m_GridHeight + 15) \ 16, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    m_CurrentRead = writeIdx
End Sub

Public Function GetCurrentTrailSSBO() As Long
    GetCurrentTrailSSBO = m_TrailSSBO(m_CurrentRead)
End Function

Public Sub Shutdown()
    GL.glDeleteBuffers 2, m_TrailSSBO(0)
    If m_Program <> 0 Then GL.glDeleteProgram m_Program
End Sub
