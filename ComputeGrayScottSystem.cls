' ============================================================
' Class Module: ComputeGrayScottSystem.cls
' Version : EVOLUTIONARY v1.2 - 2026-04-15
' GPU Reaction-Diffusion (Gray-Scott Model)
' ============================================================

Option Explicit

Private m_GridSSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_GridWidth As Long
Private m_GridHeight As Long
Private m_Program As Long

' Classic Gray-Scott parameters
Public FeedRate As Single        ' F
Public KillRate As Single        ' k
Public DiffusionU As Single
Public DiffusionV As Single

Public Sub Initialize(ByVal width As Long, ByVal height As Long)
    m_GridWidth = width
    m_GridHeight = height
    m_CurrentRead = 0
    
    FeedRate = 0.035
    KillRate = 0.065
    DiffusionU = 0.2097
    DiffusionV = 0.105
    
    GL.glGenBuffers 2, m_GridSSBO(0)
    Dim i As Long
    For i = 0 To 1
        GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_GridSSBO(i)
        GL.glBufferData GL.GL_SHADER_STORAGE_BUFFER, width * height * 8, ByVal 0&, GL.GL_DYNAMIC_DRAW
    Next i
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_GridSSBO(0)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_GridSSBO(1)
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetGrayScottShader())
    InitializeRandomGrid
End Sub

Private Sub InitializeRandomGrid()
    ' Initialize with classic Gray-Scott seed pattern (central square of V)
End Sub

Public Sub Update(ByVal deltaTime As Single)
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_GridSSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_GridSSBO(writeIdx)
    
    GL.glUseProgram m_Program
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "deltaTime"), deltaTime
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "feedRate"), FeedRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "killRate"), KillRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "diffusionU"), DiffusionU
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "diffusionV"), DiffusionV
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
