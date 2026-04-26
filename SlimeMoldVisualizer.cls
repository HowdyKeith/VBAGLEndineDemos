' ============================================================
' Class Module: SlimeMoldVisualizer.cls
' Version : BIOLOGICAL v2.4 - 2026-04-15
' Renders Slime Mold (Physarum) pheromone trails with glowing orange effect
' Fully integrated with 7-viewport FPS demo and morphogenesis system
' ============================================================

Option Explicit

Private m_TextureID As Long
Private m_QuadVAO As Long
Private m_QuadVBO As Long
Private m_VisualProgram As Long
Private m_GridWidth As Long
Private m_GridHeight As Long

' ============================================================
' Initialize - Creates texture and full-screen quad for trails
' ============================================================
Public Sub Initialize(ByVal gridWidth As Long, ByVal gridHeight As Long)
    m_GridWidth = gridWidth
    m_GridHeight = gridHeight
    
    ' Create texture for slime mold trails
    GL.glGenTextures 1, m_TextureID
    GL.glBindTexture GL.GL_TEXTURE_2D, m_TextureID
    GL.glTexImage2D GL.GL_TEXTURE_2D, 0, GL.GL_RGBA32F, gridWidth, gridHeight, 0, GL.GL_RED, GL.GL_FLOAT, ByVal 0&
    GL.glTexParameteri GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_LINEAR
    GL.glTexParameteri GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR
    GL.glTexParameteri GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_CLAMP_TO_EDGE
    GL.glTexParameteri GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP_TO_EDGE
    
    CreateFullScreenQuad
    
    ' Use common fullscreen vertex + slime-specific fragment
    m_VisualProgram = ShaderProgram.CreateProgram( _
        EmbeddedShaders.FULLSCREEN_QUAD_VERTEX, _
        EmbeddedShaders.SLIME_VIS_FRAGMENT)
End Sub

' ============================================================
' Create full-screen quad for rendering
' ============================================================
Private Sub CreateFullScreenQuad()
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

' ============================================================
' Update texture from current slime mold SSBO
' ============================================================
Public Sub UpdateTexture(ByVal trailSSBO As Long)
    GL.glBindTexture GL.GL_TEXTURE_2D, m_TextureID
    GL.glBindBuffer GL.GL_PIXEL_UNPACK_BUFFER, trailSSBO
    GL.glTexSubImage2D GL.GL_TEXTURE_2D, 0, 0, 0, m_GridWidth, m_GridHeight, GL.GL_RED, GL.GL_FLOAT, ByVal 0&
    GL.glBindBuffer GL.GL_PIXEL_UNPACK_BUFFER, 0
End Sub

' ============================================================
' Render slime mold trails
' ============================================================
Public Sub Render()
    GL.glUseProgram m_VisualProgram
    GL.glBindTexture GL.GL_TEXTURE_2D, m_TextureID
    GL.glBindVertexArray m_QuadVAO
    GL.glDrawArrays GL.GL_TRIANGLE_FAN, 0, 4
    GL.glBindVertexArray 0
End Sub

' ============================================================
' Cleanup
' ============================================================
Public Sub Shutdown()
    If m_TextureID <> 0 Then GL.glDeleteTextures 1, m_TextureID
    If m_QuadVAO <> 0 Then GL.glDeleteVertexArrays 1, m_QuadVAO
    If m_QuadVBO <> 0 Then GL.glDeleteBuffers 1, m_QuadVBO
    If m_VisualProgram <> 0 Then GL.glDeleteProgram m_VisualProgram
End Sub

