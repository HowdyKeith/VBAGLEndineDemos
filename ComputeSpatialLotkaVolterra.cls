' ============================================================
' Class Module: ComputeSpatialLotkaVolterra.cls
' Version : EVOLUTIONARY v1.2 - 2026-04-15
' Spatial Lotka-Volterra Reaction-Diffusion on GPU Grid
' ============================================================

Option Explicit

Private m_GridSSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_GridWidth As Long
Private m_GridHeight As Long
Private m_Program As Long

Public PreyGrowthRate As Single
Public PredatorDeathRate As Single
Public InteractionRate As Single
Public DiffusionRate As Single

Public Sub Initialize(ByVal width As Long, ByVal height As Long)
    m_GridWidth = width
    m_GridHeight = height
    m_CurrentRead = 0
    
    PreyGrowthRate = 0.6
    PredatorDeathRate = 0.4
    InteractionRate = 0.35
    DiffusionRate = 0.08
    
    GL.glGenBuffers 2, m_GridSSBO(0)
    Dim i As Long
    For i = 0 To 1
        GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_GridSSBO(i)
        GL.glBufferData GL.GL_SHADER_STORAGE_BUFFER, width * height * 8, ByVal 0&, GL.GL_DYNAMIC_DRAW
    Next i
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_GridSSBO(0)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_GridSSBO(1)
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetSpatialLotkaVolterraShader())
    InitializeGrid
End Sub

Public Sub Update(ByVal deltaTime As Single)
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_GridSSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_GridSSBO(writeIdx)
    
    GL.glUseProgram m_Program
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "deltaTime"), deltaTime
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "preyGrowth"), PreyGrowthRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "predatorDeath"), PredatorDeathRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "interaction"), InteractionRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "diffusion"), DiffusionRate
    GL.glUniform1i GL.glGetUniformLocation(m_Program, "gridWidth"), m_GridWidth
    GL.glUniform1i GL.glGetUniformLocation(m_Program, "gridHeight"), m_GridHeight
    
    GL.glDispatchCompute (m_GridWidth + 15) \ 16, (m_GridHeight + 15) \ 16, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    m_CurrentRead = writeIdx
End Sub

Public Function GetCurrentGridSSBO() As Long
    GetCurrentGridSSBO = m_GridSSBO(m_CurrentRead)
End Function

Public Sub Shutdown()
    GL.glDeleteBuffers 2, m_GridSSBO(0)
    If m_Program <> 0 Then GL.glDeleteProgram m_Program
End Sub
