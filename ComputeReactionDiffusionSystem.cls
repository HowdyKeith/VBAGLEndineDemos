' ============================================================
' Class Module: ComputeReactionDiffusionSystem.cls
' Version : BIOLOGICAL v1.4 - 2026-04-15
' Live pattern selector – controlled from BioControls sheet
' ============================================================

Option Explicit

Private m_GridSSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_GridWidth As Long
Private m_GridHeight As Long
Private m_Program As Long

' Live sheet controlled
Public CurrentPatternID As Long   ' 0=Gray-Scott, 1=Oregonator, 2=FitzHugh, 3=Schnakenberg

Public Sub Initialize(ByVal width As Long, ByVal height As Long)
    m_GridWidth = width
    m_GridHeight = height
    m_CurrentRead = 0
    CurrentPatternID = 0   ' default Gray-Scott
    
    GL.glGenBuffers 2, m_GridSSBO(0)
    Dim i As Long
    For i = 0 To 1
        GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_GridSSBO(i)
        GL.glBufferData GL.GL_SHADER_STORAGE_BUFFER, width * height * 8, ByVal 0&, GL.GL_DYNAMIC_DRAW
    Next i
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetReactionDiffusionShader())
    InitializeRandomGrid
End Sub

Public Sub Update(ByVal deltaTime As Single)
    ' Pull live pattern ID from sheet every frame
    ReadLivePatternID
    
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_GridSSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_GridSSBO(writeIdx)
    
    GL.glUseProgram m_Program
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "deltaTime"), deltaTime
    GL.glUniform1i GL.glGetUniformLocation(m_Program, "patternID"), CurrentPatternID
    GL.glUniform1i GL.glGetUniformLocation(m_Program, "gridWidth"), m_GridWidth
    GL.glUniform1i GL.glGetUniformLocation(m_Program, "gridHeight"), m_GridHeight
    
    GL.glDispatchCompute (m_GridWidth + 15) \ 16, (m_GridHeight + 15) \ 16, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    m_CurrentRead = writeIdx
End Sub

Private Sub ReadLivePatternID()
    On Error Resume Next
    CurrentPatternID = ThisWorkbook.Sheets("BioControls").range("B20").value
    If CurrentPatternID < 0 Or CurrentPatternID > 3 Then CurrentPatternID = 0
End Sub

Public Function GetCurrentGridSSBO() As Long
    GetCurrentGridSSBO = m_GridSSBO(m_CurrentRead)
End Function

Public Sub Shutdown()
    GL.glDeleteBuffers 2, m_GridSSBO(0)
    If m_Program <> 0 Then GL.glDeleteProgram m_Program
End Sub
