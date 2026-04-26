' ============================================================
' Class Module: ComputeCellularAutomata.cls
' Version : EVOLUTIONARY v1.2 - 2026-04-15
' Conway's Game of Life on GPU
' ============================================================

Option Explicit

Private m_GridSSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_Width As Long
Private m_Height As Long
Private m_Program As Long

Public Sub Initialize(ByVal width As Long, ByVal height As Long)
    m_Width = width
    m_Height = height
    m_CurrentRead = 0
    
    GL.glGenBuffers 2, m_GridSSBO(0)
    Dim i As Long
    For i = 0 To 1
        GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_GridSSBO(i)
        GL.glBufferData GL.GL_SHADER_STORAGE_BUFFER, width * height * 4, ByVal 0&, GL.GL_DYNAMIC_DRAW
    Next i
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetConwayShader())
    InitializeRandomGrid
End Sub

Public Sub Update()
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_GridSSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_GridSSBO(writeIdx)
    
    GL.glUseProgram m_Program
    GL.glDispatchCompute (m_Width + 15) \ 16, (m_Height + 15) \ 16, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    m_CurrentRead = writeIdx
End Sub

Public Function GetCurrentGridSSBO() As Long
    GetCurrentGridSSBO = m_GridSSBO(m_CurrentRead)
End Function
