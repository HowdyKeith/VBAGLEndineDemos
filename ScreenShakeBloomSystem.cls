' ============================================================
' Class Module: ScreenShakeBloomSystem.cls
' Version : BIOLOGICAL v2.1 - 2026-04-15
' Morphogenesis-driven screen shake + bloom post-process
' ============================================================

Option Explicit

Private m_Camera As GLCamera
Private m_PostProcessProgram As Long
Private m_Turing As TuringPatternAnalyzer
Private m_QuadVAO As Long
Private m_QuadVBO As Long

Public Sub Initialize(ByVal camera As GLCamera, ByVal turing As TuringPatternAnalyzer)
    Set m_Camera = camera
    Set m_Turing = turing
    
    m_PostProcessProgram = ShaderProgram.CreateProgram(EmbeddedShaders.FULLSCREEN_QUAD_VERTEX, EmbeddedShaders.BLOOM_FRAGMENT)
    
    ' Simple quad for post-process
    Dim verts(0 To 11) As Single
    verts(0) = -1: verts(1) = -1
    verts(2) = 1:  verts(3) = -1
    verts(4) = 1:  verts(5) = 1
    verts(6) = -1: verts(7) = 1
    GL.glGenVertexArrays 1, m_QuadVAO
    GL.glGenBuffers 1, m_QuadVBO
    GL.glBindVertexArray m_QuadVAO
    GL.glBindBuffer GL.GL_ARRAY_BUFFER, m_QuadVBO
    GL.glBufferData GL.GL_ARRAY_BUFFER, 32, verts(0), GL.GL_STATIC_DRAW
    GL.glEnableVertexAttribArray 0
    GL.glVertexAttribPointer 0, 2, GL.GL_FLOAT, GL.GL_FALSE, 8, ByVal 0&
    GL.glBindVertexArray 0
End Sub

Public Sub ApplyEffects(ByVal deltaTime As Single)
    Dim complexity As Single
    complexity = m_Turing.Entropy + m_Turing.SpotRatio * 2#
    
    ' Screen shake
    If complexity > 0.6 Then
        m_Camera.AddScreenShake complexity * 1.2
    End If
    
    ' Bloom intensity
    Dim bloom As Single
    bloom = 0.6 + complexity * 1.8
    GL.glUseProgram m_PostProcessProgram
    GL.glUniform1f GL.glGetUniformLocation(m_PostProcessProgram, "bloomIntensity"), bloom
    GL.glBindVertexArray m_QuadVAO
    GL.glDrawArrays GL.GL_TRIANGLE_FAN, 0, 4
    GL.glBindVertexArray 0
End Sub

Public Sub Shutdown()
    If m_PostProcessProgram <> 0 Then GL.glDeleteProgram m_PostProcessProgram
    If m_QuadVAO <> 0 Then GL.glDeleteVertexArrays 1, m_QuadVAO
    If m_QuadVBO <> 0 Then GL.glDeleteBuffers 1, m_QuadVBO
End Sub
