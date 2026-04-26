' ============================================================
' Module: EmbeddedShaders.bas
' Version : BIOLOGICAL v2.60 - 2026-04-15
' Complete embedded shader library for the full biological FPS engine
' Includes all visualization, bloom, refraction, and particle shaders
' ============================================================

Option Explicit

' ============================================================
' COMMON FULL-SCREEN QUAD VERTEX SHADER
' ============================================================
Public Const FULLSCREEN_QUAD_VERTEX As String = _
"#version 330 core" & vbCrLf & _
"layout (location = 0) in vec2 aPos;" & vbCrLf & _
"out vec2 vTexCoord;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    gl_Position = vec4(aPos, 0.0, 1.0);" & vbCrLf & _
"    vTexCoord = aPos * 0.5 + 0.5;" & vbCrLf & _
"}"

' ============================================================
' SLIME MOLD VISUALIZATION
' ============================================================
Public Const SLIME_VIS_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform sampler2D trailTexture;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    float p = texture(trailTexture, vTexCoord).r;" & vbCrLf & _
"    vec3 color = vec3(1.0, 0.65, 0.1) * p * 1.6;" & vbCrLf & _
"    FragColor = vec4(color, 1.0);" & vbCrLf & _
"}"

' ============================================================
' LOTKA-VOLTERRA VISUALIZATION
' ============================================================
Public Const LOTKA_VIS_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform sampler2D gridTexture;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    vec4 data = texture(gridTexture, vTexCoord);" & vbCrLf & _
"    float prey = data.r;" & vbCrLf & _
"    float pred = data.g;" & vbCrLf & _
"    vec3 color = vec3(0.0, prey * 1.4, 0.4) + vec3(pred * 1.2, 0.1, 0.2);" & vbCrLf & _
"    float overlap = min(prey, pred) * 1.6;" & vbCrLf & _
"    color += vec3(1.0, 0.9, 0.0) * overlap;" & vbCrLf & _
"    FragColor = vec4(color, 1.0);" & vbCrLf & _
"}"

' ============================================================
' BACTERIAL COLONY VISUALIZATION
' ============================================================
Public Const BACTERIA_VIS_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform sampler2D gridTexture;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    vec4 data = texture(gridTexture, vTexCoord);" & vbCrLf & _
"    float bac = data.r;" & vbCrLf & _
"    float nut = data.g;" & vbCrLf & _
"    vec3 color = vec3(0.0, bac * 1.8, 0.5) + vec3(0.2, 0.4, nut * 1.4);" & vbCrLf & _
"    FragColor = vec4(color, 1.0);" & vbCrLf & _
"}"

' ============================================================
' FITZHUGH-NAGUMO VISUALIZATION
' ============================================================
Public Const FITZ_VIS_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform sampler2D gridTexture;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    vec4 data = texture(gridTexture, vTexCoord);" & vbCrLf & _
"    float u = data.r;" & vbCrLf & _
"    float v = data.g;" & vbCrLf & _
"    FragColor = vec4(0.0, u * 1.5, v * 2.2, 1.0);" & vbCrLf & _
"}"

' ============================================================
' ANT COLONY VISUALIZATION
' ============================================================
Public Const ANT_COLONY_VIS_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform sampler2D pheromoneTexture;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    float p = texture(pheromoneTexture, vTexCoord).r;" & vbCrLf & _
"    FragColor = vec4(p * 1.9, p * 0.9, 0.05, 1.0);" & vbCrLf & _
"}"

' ============================================================
' HUD OVERLAY
' ============================================================
Public Const HUD_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform float health;" & vbCrLf & _
"uniform float ammoRatio;" & vbCrLf & _
"uniform int ammo;" & vbCrLf & _
"uniform int maxAmmo;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    vec3 color = vec3(0.0);" & vbCrLf & _
"    if (vTexCoord.x < 0.35 && vTexCoord.y > 0.82) color = vec3(1.0 - health, health, 0.0);" & vbCrLf & _
"    if (vTexCoord.x > 0.65 && vTexCoord.y > 0.82) color = vec3(1.0, 0.85, 0.25) * ammoRatio;" & vbCrLf & _
"    if (abs(vTexCoord.x - 0.5) < 0.012 || abs(vTexCoord.y - 0.5) < 0.012) color = vec3(1.0, 0.3, 0.3);" & vbCrLf & _
"    FragColor = vec4(color, 0.85);" & vbCrLf & _
"}"

' ============================================================
' REVISED BLOOM FRAGMENT (cinematic Gaussian bloom)
' ============================================================
Public Const BLOOM_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform sampler2D sceneTexture;" & vbCrLf & _
"uniform float bloomIntensity;" & vbCrLf & _
"uniform float time;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    vec4 color = texture(sceneTexture, vTexCoord);" & vbCrLf & _
"    vec2 texel = 1.0 / vec2(1200.0, 800.0);" & vbCrLf & _
"    vec3 bloom = color.rgb * 0.2;" & vbCrLf & _
"    bloom += texture(sceneTexture, vTexCoord + vec2(-texel.x, 0.0)).rgb * 0.15;" & vbCrLf & _
"    bloom += texture(sceneTexture, vTexCoord + vec2(texel.x, 0.0)).rgb * 0.15;" & vbCrLf & _
"    bloom += texture(sceneTexture, vTexCoord + vec2(0.0, -texel.y)).rgb * 0.15;" & vbCrLf & _
"    bloom += texture(sceneTexture, vTexCoord + vec2(0.0, texel.y)).rgb * 0.15;" & vbCrLf & _
"    bloom += texture(sceneTexture, vTexCoord + vec2(-texel.x, -texel.y)).rgb * 0.1;" & vbCrLf & _
"    bloom += texture(sceneTexture, vTexCoord + vec2(texel.x, texel.y)).rgb * 0.1;" & vbCrLf & _
"    bloom += texture(sceneTexture, vTexCoord + vec2(-texel.x, texel.y)).rgb * 0.1;" & vbCrLf & _
"    bloom += texture(sceneTexture, vTexCoord + vec2(texel.x, -texel.y)).rgb * 0.1;" & vbCrLf & vbCrLf & _
"    float boost = bloomIntensity * (1.0 + sin(time * 8.0) * 0.15);" & vbCrLf & _
"    FragColor = vec4(color.rgb + bloom * boost, color.a);" & vbCrLf & _
"}"

' ============================================================
' REFRACTION POST-PROCESS
' ============================================================
Public Const REFRACTION_POST_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform sampler2D fpsSceneTexture;" & vbCrLf & _
"uniform float time;" & vbCrLf & _
"uniform float refractionStrength;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    vec2 uv = vTexCoord;" & vbCrLf & _
"    float wave = sin(time * 14.0 + uv.y * 35.0) * 0.014 * refractionStrength;" & vbCrLf & _
"    vec2 refractUV = uv + vec2(wave, wave * 0.7);" & vbCrLf & _
"    vec4 color = texture(fpsSceneTexture, refractUV);" & vbCrLf & _
"    FragColor = vec4(color.rgb * vec3(0.78, 0.92, 1.15), color.a);" & vbCrLf & _
"}"

' ============================================================
' SIMPLE TEXT FRAGMENT (for on-screen menu)
' ============================================================
Public Const SIMPLE_TEXT_FRAGMENT As String = _
"#version 330 core" & vbCrLf & _
"in vec2 vTexCoord;" & vbCrLf & _
"uniform vec4 color;" & vbCrLf & _
"out vec4 FragColor;" & vbCrLf & vbCrLf & _
"void main() {" & vbCrLf & _
"    FragColor = color;" & vbCrLf & _
"}"

' ============================================================
' COMPUTE SHADERS - Morphogenesis (with all parameters)
' ============================================================
Public Function GetMorphogenesisShader() As String
    Dim s As String
    s = "#version 430 core" & vbCrLf
    s = s & "layout (local_size_x = 16, local_size_y = 16, local_size_z = 1) in;" & vbCrLf & vbCrLf
    s = s & "layout(std430, binding = 0) buffer Current { float activator[]; float inhibitor[]; };" & vbCrLf
    s = s & "layout(std430, binding = 1) buffer Next { float nextActivator[]; float nextInhibitor[]; };" & vbCrLf & vbCrLf
    s = s & "uniform float deltaTime;" & vbCrLf
    s = s & "uniform float activatorDiff;" & vbCrLf
    s = s & "uniform float inhibitorDiff;" & vbCrLf
    s = s & "uniform float productionRate;" & vbCrLf
    s = s & "uniform float activatorDecay;" & vbCrLf
    s = s & "uniform float inhibitorDecay;" & vbCrLf
    s = s & "uniform float baseProduction;" & vbCrLf
    s = s & "uniform int gridWidth;" & vbCrLf
    s = s & "uniform int gridHeight;" & vbCrLf & vbCrLf
    s = s & "int idx(int x, int y) { return y * gridWidth + x; }" & vbCrLf & vbCrLf
    s = s & "void main() {" & vbCrLf
    s = s & "    ivec2 pos = ivec2(gl_GlobalInvocationID.xy);" & vbCrLf
    s = s & "    if (pos.x >= gridWidth || pos.y >= gridHeight) return;" & vbCrLf
    s = s & "    int i = idx(pos.x, pos.y);" & vbCrLf
    s = s & "    float a = activator[i];" & vbCrLf
    s = s & "    float h = inhibitor[i];" & vbCrLf
    s = s & "    float da = baseProduction + productionRate * (a*a / (1.0 + a*a)) - activatorDecay * a - h * a;" & vbCrLf
    s = s & "    float dh = 0.02 * a - inhibitorDecay * h;" & vbCrLf
    s = s & "    float lapA = -4.0 * a;" & vbCrLf
    s = s & "    if (pos.x > 0) lapA += activator[idx(pos.x-1, pos.y)];" & vbCrLf
    s = s & "    if (pos.x < gridWidth-1) lapA += activator[idx(pos.x+1, pos.y)];" & vbCrLf
    s = s & "    if (pos.y > 0) lapA += activator[idx(pos.x, pos.y-1)];" & vbCrLf
    s = s & "    if (pos.y < gridHeight-1) lapA += activator[idx(pos.x, pos.y+1)];" & vbCrLf
    s = s & "    float lapH = -4.0 * h;" & vbCrLf
    s = s & "    if (pos.x > 0) lapH += inhibitor[idx(pos.x-1, pos.y)];" & vbCrLf
    s = s & "    if (pos.x < gridWidth-1) lapH += inhibitor[idx(pos.x+1, pos.y)];" & vbCrLf
    s = s & "    if (pos.y > 0) lapH += inhibitor[idx(pos.x, pos.y-1)];" & vbCrLf
    s = s & "    if (pos.y < gridHeight-1) lapH += inhibitor[idx(pos.x, pos.y+1)];" & vbCrLf
    s = s & "    nextActivator[i] = clamp(a + deltaTime * (da + activatorDiff * lapA), 0.0, 1.0);" & vbCrLf
    s = s & "    nextInhibitor[i] = clamp(h + deltaTime * (dh + inhibitorDiff * lapH), 0.0, 1.0);" & vbCrLf
    s = s & "}" & vbCrLf
    GetMorphogenesisShader = s
End Function

' Helper to create compute program
Public Function CreateComputeProgram(ByVal source As String) As Long
    Dim shader As Long, program As Long
    shader = GL.glCreateShader(GL.GL_COMPUTE_SHADER)
    GL.glShaderSource shader, 1, source, 0
    GL.glCompileShader shader
    program = GL.glCreateProgram()
    GL.glAttachShader program, shader
    GL.glLinkProgram program
    GL.glDeleteShader shader
    CreateComputeProgram = program
End Function

