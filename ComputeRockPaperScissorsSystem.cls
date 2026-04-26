' ============================================================
' Class Module: ComputeRockPaperScissorsSystem.cls
' Version : EVOLUTIONARY v1.2 - 2026-04-15
' Rock-Paper-Scissors Evolution Demo on GPU
' ============================================================

Option Explicit

Private m_SSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_MaxAgents As Long
Private m_Program As Long

Public mutationRate As Single
Public DriftRate As Single

Public Sub Initialize(ByVal maxAgents As Long)
    m_MaxAgents = maxAgents
    m_CurrentRead = 0
    mutationRate = 0.08
    DriftRate = 0.12
    
    GL.glGenBuffers 2, m_SSBO(0)
    Dim i As Long
    For i = 0 To 1
        GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_SSBO(i)
        GL.glBufferData GL.GL_SHADER_STORAGE_BUFFER, maxAgents * 32, ByVal 0&, GL.GL_DYNAMIC_DRAW
    Next i
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_SSBO(0)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_SSBO(1)
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetRockPaperScissorsShader())
    InitializeAgents
End Sub

Private Sub InitializeAgents()
    ' Random initial strategies (Rock, Paper, Scissors)
    ' Implementation left as exercise or reuse from previous demos
End Sub

Public Sub Update(ByVal deltaTime As Single)
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_SSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_SSBO(writeIdx)
    
    GL.glUseProgram m_Program
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "deltaTime"), deltaTime
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "mutationRate"), mutationRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "driftRate"), DriftRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "time"), Timer()
    
    Dim groups As Long
    groups = (m_MaxAgents + 255) \ 256
    GL.glDispatchCompute groups, 1, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    m_CurrentRead = writeIdx
End Sub

Public Function GetCurrentSSBO() As Long
    GetCurrentSSBO = m_SSBO(m_CurrentRead)
End Function

Public Sub Shutdown()
    GL.glDeleteBuffers 2, m_SSBO(0)
    If m_Program <> 0 Then GL.glDeleteProgram m_Program
End Sub
