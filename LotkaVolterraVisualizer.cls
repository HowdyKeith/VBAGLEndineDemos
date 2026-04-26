''''''''''''''''''''''


' ============================================================
' Class Module: LotkaVolterraVisualizer.cls
' Version : BIOLOGICAL v1.2 - 2026-04-15
' Renders Spatial Lotka-Volterra grid as colored heatmap
' ============================================================

Option Explicit

Private m_TextureID As Long
Private m_QuadVAO As Long
Private m_QuadVBO As Long
Private m_VisualProgram As Long
Private m_GridWidth As Long
Private m_GridHeight As Long

Public Sub Initialize(ByVal gridWidth As Long, ByVal gridHeight As Long)
    m_GridWidth = gridWidth
    m_GridHeight = gridHeight
    
    GL.glGenTextures 1, m_TextureID
    GL.glBindTexture GL.GL_TEXTURE_2D, m_TextureID
    GL.glTexImage2D GL.GL_TEXTURE_2D, 0, GL.GL_RGBA32F, gridWidth, gridHeight, 0, GL.GL_RGBA, GL.GL_FLOAT, ByVal 0&
    GL.glTexParameteri GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_LINEAR
    GL.glTexParameteri GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR
    GL.glTexParameteri GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_CLAMP_TO_EDGE
    GL.glTexParameteri GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP_TO_EDGE
    
    CreateFullScreenQuad
    
    m_VisualProgram = ShaderProgram.CreateProgram(EmbeddedShaders.LOTKA_VIS_VERTEX, EmbeddedShaders.LOTKA_VIS_FRAGMENT)
End Sub

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

Public Sub UpdateTexture(ByVal gridSSBO As Long)
    GL.glBindTexture GL.GL_TEXTURE_2D, m_TextureID
    GL.glBindBuffer GL.GL_PIXEL_UNPACK_BUFFER, gridSSBO
    GL.glTexSubImage2D GL.GL_TEXTURE_2D, 0, 0, 0, m_GridWidth, m_GridHeight, GL.GL_RGBA, GL.GL_FLOAT, ByVal 0&
    GL.glBindBuffer GL.GL_PIXEL_UNPACK_BUFFER, 0
End Sub

Public Sub Render()
    GL.glUseProgram m_VisualProgram
    GL.glBindTexture GL.GL_TEXTURE_2D, m_TextureID
    GL.glBindVertexArray m_QuadVAO
    GL.glDrawArrays GL.GL_TRIANGLE_FAN, 0, 4
    GL.glBindVertexArray 0
End Sub

Public Sub Shutdown()
    If m_TextureID <> 0 Then GL.glDeleteTextures 1, m_TextureID
    If m_QuadVAO <> 0 Then GL.glDeleteVertexArrays 1, m_QuadVAO
    If m_QuadVBO <> 0 Then GL.glDeleteBuffers 1, m_QuadVBO
    If m_VisualProgram <> 0 Then GL.glDeleteProgram m_VisualProgram
End Sub

'''''''''''''''''''''


'Here are four alternative visualization shaders for your Spatial Lotka-Volterra simulation.
'You can swap them in easily by changing the fragment shader used in LotkaVolterraVisualizer.cls.
'1. Classic Heatmap (High Contrast – Recommended Default)
'vbPublic Const LV_HEATMAP_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform sampler2D gridTexture;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    vec4 data = texture(gridTexture, vTexCoord);" & vbCrLf & _
"    float prey = data.r;" & vbCrLf & _
"    float pred = data.g;" & vbCrLf & vbCrLf & _
"    vec3 color = vec3(0.0);" & vbCrLf & _
"    color += vec3(0.0, 1.0, 0.3) * prey;" & vbCrLf & _
"    color += vec3(1.0, 0.2, 0.1) * pred;" & vbCrLf & _
"    float overlap = min(prey, pred) * 1.4;" & vbCrLf & _
"    color += vec3(1.0, 0.9, 0.0) * overlap;" & vbCrLf & vbCrLf & _
"    FragColor = vec4(color, 1.0);" & vbCrLf & _
"}"
'2. Separate Channels (Split View – Prey Left, Predator Right)
'vbPublic Const LV_SPLIT_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform sampler2D gridTexture;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    vec2 uv = vTexCoord;" & vbCrLf & _
"    if (uv.x < 0.5) {" & vbCrLf & _
"        float prey = texture(gridTexture, vec2(uv.x * 2.0, uv.y)).r;" & vbCrLf & _
"        FragColor = vec4(0.0, prey * 1.2, 0.4, 1.0);" & vbCrLf & _   ' Prey on left
'"    } else {" & vbCrLf & _
"        float pred = texture(gridTexture, vec2((uv.x - 0.5) * 2.0, uv.y)).g;" & vbCrLf & _
"        FragColor = vec4(pred * 1.4, 0.1, 0.2, 1.0);" & vbCrLf & _   ' Predator on right
'"    }" & vbCrLf & _
"}"
'3. Phase-Space Style (Hue based on Prey/Predator Ratio)
'vbPublic Const LV_PHASE_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform sampler2D gridTexture;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    vec4 data = texture(gridTexture, vTexCoord);" & vbCrLf & _
"    float prey = data.r;" & vbCrLf & _
"    float pred = data.g;" & vbCrLf & _
"    float ratio = prey / (pred + 0.001);" & vbCrLf & vbCrLf & _
"    vec3 color;" & vbCrLf & _
"    if (ratio > 2.0) color = vec3(0.0, 1.0, 0.0);" & vbCrLf & _   ' Prey dominant
'"    else if (ratio < 0.5) color = vec3(1.0, 0.0, 0.0);" & vbCrLf & _   ' Predator dominant
'"    else color = vec3(1.0, 0.8, 0.0);" & vbCrLf & _   ' Balanced
'"    FragColor = vec4(color, 1.0);" & vbCrLf & _
"}"
'4. Log-Scale Heatmap (Better for large population swings)
'vbPublic Const LV_LOG_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform sampler2D gridTexture;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    vec4 data = texture(gridTexture, vTexCoord);" & vbCrLf & _
"    float prey = log(1.0 + data.r * 10.0);" & vbCrLf & _
"    float pred = log(1.0 + data.g * 10.0);" & vbCrLf & vbCrLf & _
"    vec3 color = vec3(0.0);" & vbCrLf & _
"    color += vec3(0.0, prey * 0.8, 0.4);" & vbCrLf & _
"    color += vec3(pred * 1.1, 0.1, 0.2);" & vbCrLf & _
"    FragColor = vec4(color, 1.0);" & vbCrLf & _
"}"
'How to Use Any of These
'In your LotkaVolterraVisualizer.cls, simply change the fragment shader when creating the program:
'vbm_VisualProgram = ShaderProgram.CreateProgram( _
    EmbeddedShaders.LOTKA_VIS_VERTEX, _
    EmbeddedShaders.LV_HEATMAP_FRAGMENT)     ' Change this line to any of the above








