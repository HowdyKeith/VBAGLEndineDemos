' ============================================================
' Class Module: TuringPatternAnalyzer.cls
' Version : BIOLOGICAL v1.4 - 2026-04-15
' Real-time Turing pattern analysis (spots, stripes, labyrinths, waves)
' Writes live metrics to BioControls sheet
' ============================================================

Option Explicit

Private m_AnalyzerProgram As Long
Private m_StatsSSBO As Long
Private m_RDSystem As ComputeReactionDiffusionSystem

' Live results
Public patternType As String
Public Wavelength As Single
Public Entropy As Single
Public SpotRatio As Single
Public StripeRatio As Single

Public Sub Initialize(ByVal RDSystem As ComputeReactionDiffusionSystem)
    Set m_RDSystem = RDSystem
    
    m_AnalyzerProgram = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetTuringAnalyzerShader())
    
    GL.glGenBuffers 1, m_StatsSSBO
    GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_StatsSSBO
    GL.glBufferData GL.GL_SHADER_STORAGE_BUFFER, 16, ByVal 0&, GL.GL_DYNAMIC_DRAW   ' 4 floats
End Sub

Public Sub Update()
    ' Run GPU analysis on current RD grid
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_RDSystem.GetCurrentGridSSBO()
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_StatsSSBO
    
    GL.glUseProgram m_AnalyzerProgram
    GL.glUniform1i GL.glGetUniformLocation(m_AnalyzerProgram, "gridWidth"), 256
    GL.glUniform1i GL.glGetUniformLocation(m_AnalyzerProgram, "gridHeight"), 256
    GL.glDispatchCompute 16, 16, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    ' Read back results to VBA
    Dim stats(0 To 3) As Single
    GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_StatsSSBO
    GL.glGetBufferSubData GL.GL_SHADER_STORAGE_BUFFER, 0, 16, stats(0)
    
    Wavelength = stats(0) / (256 * 256)
    Entropy = -stats(1) / (256 * 256)
    SpotRatio = stats(2) / (256 * 256)
    StripeRatio = stats(3) / (256 * 256)
    
    ' Classify pattern
    If SpotRatio > 0.35 Then
        patternType = "Spots (Classic Turing)"
    ElseIf StripeRatio > 0.4 Then
        patternType = "Stripes / Labyrinth"
    ElseIf Wavelength > 0.15 Then
        patternType = "Traveling Waves"
    Else
        patternType = "Chaotic / Mixed"
    End If
    
    ' Write live results to BioControls sheet
    WriteLiveAnalysisToSheet
End Sub

Private Sub WriteLiveAnalysisToSheet()
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("BioControls")
    ws.range("B25").value = patternType
    ws.range("B26").value = Wavelength
    ws.range("B27").value = Entropy
    ws.range("B28").value = SpotRatio
    ws.range("B29").value = StripeRatio
End Sub

Public Sub Shutdown()
    If m_StatsSSBO <> 0 Then GL.glDeleteBuffers 1, m_StatsSSBO
    If m_AnalyzerProgram <> 0 Then GL.glDeleteProgram m_AnalyzerProgram
End Sub
