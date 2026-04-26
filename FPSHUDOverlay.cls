' ============================================================
' Class Module: FPSHUDOverlay.cls
' Version : BIOLOGICAL v1.5 - 2026-04-15
' Weapon + Health HUD drawn directly in the FPS viewport
' ============================================================

Option Explicit

Private m_HUDProgram As Long
Private m_QuadVAO As Long
Private m_QuadVBO As Long

Public Sub Initialize()
    m_HUDProgram = ShaderProgram.CreateProgram(EmbeddedShaders.FULLSCREEN_QUAD_VERTEX, EmbeddedShaders.HUD_FRAGMENT)
    
    ' Simple quad for HUD elements
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

Public Sub Render(ByVal health As Single, ByVal ammo As Long, ByVal maxAmmo As Long)
    GL.glUseProgram m_HUDProgram
    GL.glUniform1f GL.glGetUniformLocation(m_HUDProgram, "health"), health / 100
    GL.glUniform1f GL.glGetUniformLocation(m_HUDProgram, "ammoRatio"), ammo / maxAmmo
    GL.glUniform1i GL.glGetUniformLocation(m_HUDProgram, "ammo"), ammo
    GL.glUniform1i GL.glGetUniformLocation(m_HUDProgram, "maxAmmo"), maxAmmo
    GL.glBindVertexArray m_QuadVAO
    GL.glDrawArrays GL.GL_TRIANGLE_FAN, 0, 4
    GL.glBindVertexArray 0
End Sub

Public Sub Shutdown()
    If m_HUDProgram <> 0 Then GL.glDeleteProgram m_HUDProgram
    If m_QuadVAO <> 0 Then GL.glDeleteVertexArrays 1, m_QuadVAO
    If m_QuadVBO <> 0 Then GL.glDeleteBuffers 1, m_QuadVBO
End Sub
