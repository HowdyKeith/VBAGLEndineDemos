' ============================================================
' Class Module: OnScreenMenuRenderer.cls
' Version : BIOLOGICAL v2.60 - 2026-04-15
' Simple on-screen GUI menu rendered in OpenGL viewport
' ============================================================

Option Explicit

Private m_FontProgram As Long
Private m_QuadVAO As Long
Private m_QuadVBO As Long

Public Sub Initialize()
    m_FontProgram = ShaderProgram.CreateProgram( _
        EmbeddedShaders.FULLSCREEN_QUAD_VERTEX, _
        EmbeddedShaders.SIMPLE_TEXT_FRAGMENT)
    
    ' Semi-transparent menu background
    Dim verts(0 To 11) As Single
    verts(0) = -0.98: verts(1) = 0.55
    verts(2) = -0.35: verts(3) = 0.55
    verts(4) = -0.35: verts(5) = 0.98
    verts(6) = -0.98: verts(7) = 0.98
    
    GL.glGenVertexArrays 1, m_QuadVAO
    GL.glGenBuffers 1, m_QuadVBO
    GL.glBindVertexArray m_QuadVAO
    GL.glBindBuffer GL.GL_ARRAY_BUFFER, m_QuadVBO
    GL.glBufferData GL.GL_ARRAY_BUFFER, 32, verts(0), GL.GL_STATIC_DRAW
    GL.glEnableVertexAttribArray 0
    GL.glVertexAttribPointer 0, 2, GL.GL_FLOAT, GL.GL_FALSE, 8, ByVal 0&
    GL.glBindVertexArray 0
End Sub

Public Sub Render()
    GL.glUseProgram m_FontProgram
    GL.glUniform4f GL.glGetUniformLocation(m_FontProgram, "color"), 0#, 0#, 0#, 0.82
    GL.glBindVertexArray m_QuadVAO
    GL.glDrawArrays GL.GL_TRIANGLE_FAN, 0, 4
    GL.glBindVertexArray 0
    
    Debug.Print "=== LIVE ON-SCREEN MENU (v2.60) ==="
    Debug.Print "1-4 : RD Pattern"
    Debug.Print "Q/A : Activator Diff   W/S : Inhibitor Diff"
    Debug.Print "E/D : Production Rate"
    Debug.Print "U/J : Activator Decay  I/K : Inhibitor Decay"
    Debug.Print "O/L : Base Production"
    Debug.Print "Z/X : Slime Diffuse    C/V : Slime Decay"
    Debug.Print "T/G : Enemy Aggro      Y/H : Global Difficulty"
    Debug.Print "R   : Reload Weapon    F   : Take Damage"
    Debug.Print "F5  : Save Config      F9  : Load Config"
    Debug.Print "P   : Print Full Status"
    Debug.Print "=============================="
End Sub

Public Sub Shutdown()
    If m_FontProgram <> 0 Then GL.glDeleteProgram m_FontProgram
    If m_QuadVAO <> 0 Then GL.glDeleteVertexArrays 1, m_QuadVAO
    If m_QuadVBO <> 0 Then GL.glDeleteBuffers 1, m_QuadVBO
End Sub

