' ============================================================
' Class Module: ComputeMorphogenesisSystem.cls
' Version : BIOLOGICAL v2.4 - 2026-04-15
' Gierer-Meinhardt Morphogenesis with expanded live parameters
' Fully wired into menu and save/load system
' ============================================================

Option Explicit

Private m_GridSSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_GridWidth As Long
Private m_GridHeight As Long
Private m_Program As Long

' Expanded Morphogenesis Parameters (all controllable from modDemoMenu)
Public ActivatorDiff As Single
Public InhibitorDiff As Single
Public ProductionRate As Single
Public ActivatorDecay As Single      ' NEW
Public InhibitorDecay As Single      ' NEW
Public BaseProduction As Single      ' NEW

Public Sub Initialize(ByVal width As Long, ByVal height As Long)
    m_GridWidth = width
    m_GridHeight = height
    m_CurrentRead = 0
    
    ' Default values
    ActivatorDiff = 0.08
    InhibitorDiff = 0.4
    ProductionRate = 0.02
    ActivatorDecay = 0.04          ' NEW
    InhibitorDecay = 0.06          ' NEW
    BaseProduction = 0.01          ' NEW
    
    GL.glGenBuffers 2, m_GridSSBO(0)
    Dim i As Long
    For i = 0 To 1
        GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_GridSSBO(i)
        GL.glBufferData GL.GL_SHADER_STORAGE_BUFFER, width * height * 8, ByVal 0&, GL.GL_DYNAMIC_DRAW
    Next i
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetMorphogenesisShader())
    InitializeMorphoGrid
End Sub

Public Sub Update(ByVal deltaTime As Single)
    ' Read live values from sheet / menu
    ReadLiveSheetData
    
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_GridSSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_GridSSBO(writeIdx)
    
    GL.glUseProgram m_Program
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "deltaTime"), deltaTime
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "activatorDiff"), ActivatorDiff
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "inhibitorDiff"), InhibitorDiff
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "productionRate"), ProductionRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "activatorDecay"), ActivatorDecay
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "inhibitorDecay"), InhibitorDecay
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "baseProduction"), BaseProduction
    GL.glUniform1i GL.glGetUniformLocation(m_Program, "gridWidth"), m_GridWidth
    GL.glUniform1i GL.glGetUniformLocation(m_Program, "gridHeight"), m_GridHeight
    
    GL.glDispatchCompute (m_GridWidth + 15) \ 16, (m_GridHeight + 15) \ 16, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    m_CurrentRead = writeIdx
End Sub

Private Sub ReadLiveSheetData()
    On Error Resume Next
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BioControls")
    
    ActivatorDiff = ws.range("B32").value
    InhibitorDiff = ws.range("B33").value
    ProductionRate = ws.range("B34").value
    ActivatorDecay = ws.range("B35").value      ' NEW
    InhibitorDecay = ws.range("B36").value      ' NEW
    BaseProduction = ws.range("B37").value      ' NEW
End Sub

Public Function GetCurrentGridSSBO() As Long
    GetCurrentGridSSBO = m_GridSSBO(m_CurrentRead)
End Function

Public Sub Shutdown()
    GL.glDeleteBuffers 2, m_GridSSBO(0)
    If m_Program <> 0 Then GL.glDeleteProgram m_Program
End Sub
