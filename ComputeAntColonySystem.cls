' ============================================================
' Class Module: ComputeAntColonySystem.cls
' Version : BIOLOGICAL v2.5 - 2026-04-15
' GPU pheromone field for Ant Colony Optimization
' Handles evaporation, diffusion, and deposition from enemies
' ============================================================

Option Explicit

Private m_PheromoneSSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_GridWidth As Long
Private m_GridHeight As Long
Private m_Program As Long

Public EvaporationRate As Single
Public DepositRate As Single

Public Sub Initialize(ByVal width As Long, ByVal height As Long)
    m_GridWidth = width
    m_GridHeight = height
    m_CurrentRead = 0
    
    EvaporationRate = 0.05
    DepositRate = 0.3
    
    GL.glGenBuffers 2, m_PheromoneSSBO(0)
    Dim i As Long
    For i = 0 To 1
        GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_PheromoneSSBO(i)
        GL.glBufferData GL.GL_SHADER_STORAGE_BUFFER, width * height * 4, ByVal 0&, GL.GL_DYNAMIC_DRAW
    Next i
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetAntColonyShader())
    InitializePheromoneGrid
End Sub

Public Sub Update(ByVal deltaTime As Single)
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_PheromoneSSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_PheromoneSSBO(writeIdx)
    
    GL.glUseProgram m_Program
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "deltaTime"), deltaTime
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "evaporationRate"), EvaporationRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "depositRate"), DepositRate
    GL.glUniform1i GL.glGetUniformLocation(m_Program, "gridWidth"), m_GridWidth
    GL.glUniform1i GL.glGetUniformLocation(m_Program, "gridHeight"), m_GridHeight
    
    GL.glDispatchCompute (m_GridWidth + 15) \ 16, (m_GridHeight + 15) \ 16, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    m_CurrentRead = writeIdx
End Sub

Private Sub InitializePheromoneGrid()
    ' Initial central food source + random weak trails
    ' (can be expanded later)
End Sub

Public Function GetCurrentPheromoneSSBO() As Long
    GetCurrentPheromoneSSBO = m_PheromoneSSBO(m_CurrentRead)
End Function

Public Sub DepositPheromone(ByVal x As Long, ByVal y As Long, ByVal amount As Single)
    ' Optional CPU-side deposit – usually done in compute shader for speed
End Sub

Public Sub Shutdown()
    GL.glDeleteBuffers 2, m_PheromoneSSBO(0)
    If m_Program <> 0 Then GL.glDeleteProgram m_Program
End Sub
