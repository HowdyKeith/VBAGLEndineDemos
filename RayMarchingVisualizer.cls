' ============================================================
' Class Module: RayMarchingVisualizer.cls
' Version : ADVANCED v1.2 - 2026-04-15
' Pure shader ray marching demo (no meshes)
' ============================================================

Option Explicit

Private m_FullScreenVAO As Long
Private m_FullScreenVBO As Long
Private m_RayMarchProgram As Long

Public Sub Initialize()
    CreateFullScreenQuad
    m_RayMarchProgram = ShaderProgram.CreateProgram( _
        EmbeddedShaders.RAY_MARCH_VERTEX, _
        EmbeddedShaders.RAY_MARCH_FRAGMENT)
End Sub

Private Sub CreateFullScreenQuad()
    Dim verts(0 To 11) As Single
    verts(0) = -1: verts(1) = -1
    verts(2) = 1:  verts(3) = -1
    verts(4) = 1:  verts(5) = 1
    verts(6) = -1: verts(7) = 1
    
    GL.glGenVertexArrays 1, m_FullScreenVAO
    GL.glGenBuffers 1, m_FullScreenVBO
    GL.glBindVertexArray m_FullScreenVAO
    GL.glBindBuffer GL.GL_ARRAY_BUFFER, m_FullScreenVBO
    GL.glBufferData GL.GL_ARRAY_BUFFER, 32, verts(0), GL.GL_STATIC_DRAW
    GL.glEnableVertexAttribArray 0
    GL.glVertexAttribPointer 0, 2, GL.GL_FLOAT, GL.GL_FALSE, 8, ByVal 0&
    GL.glBindVertexArray 0
End Sub

Public Sub Render(ByVal camera As GLCamera)
    GL.glUseProgram m_RayMarchProgram
    GL.glUniform3f GL.glGetUniformLocation(m_RayMarchProgram, "cameraPos"), camera.m_Position.x, camera.m_Position.y, camera.m_Position.z
    GL.glUniform1f GL.glGetUniformLocation(m_RayMarchProgram, "time"), Timer()
    GL.glBindVertexArray m_FullScreenVAO
    GL.glDrawArrays GL.GL_TRIANGLE_FAN, 0, 4
    GL.glBindVertexArray 0
End Sub

Public Sub Shutdown()
    If m_FullScreenVAO <> 0 Then GL.glDeleteVertexArrays 1, m_FullScreenVAO
    If m_FullScreenVBO <> 0 Then GL.glDeleteBuffers 1, m_FullScreenVBO
    If m_RayMarchProgram <> 0 Then GL.glDeleteProgram m_RayMarchProgram
End Sub

