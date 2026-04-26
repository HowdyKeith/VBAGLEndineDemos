' ============================================================
' Class Module: ComputeBoidSystem.cls
' Version : ADVANCED v1.2 - 2026-04-15
' Advanced GPU Flocking with leaders, goal seeking, and formation bias
' ============================================================

Option Explicit

Private m_SSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_MaxBoids As Long
Private m_BoidProgram As Long

Public SeparationWeight As Single
Public AlignmentWeight As Single
Public CohesionWeight As Single
Public LeaderWeight As Single
Public GoalWeight As Single
Public ObstacleWeight As Single
Public MaxSpeed As Single
Public Gravity As Single
Public Restitution As Single
Public Damping As Single

Public GoalPosition As Vector3   ' Moving target for goal seeking

Public Sub Initialize(ByVal maxBoids As Long)
    m_MaxBoids = maxBoids
    m_CurrentRead = 0
    
    SeparationWeight = 2.4
    AlignmentWeight = 1.15
    CohesionWeight = 0.85
    LeaderWeight = 1.8
    GoalWeight = 1.2
    ObstacleWeight = 3.2
    MaxSpeed = 15.5
    Gravity = -9.81
    Restitution = 0.78
    Damping = 0.94
    
    GoalPosition.x = 0
    GoalPosition.y = 8
    GoalPosition.z = 0
    
    GL.glGenBuffers 2, m_SSBO(0)
    Dim i As Long
    For i = 0 To 1
        GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_SSBO(i)
        GL.glBufferData GL.GL_SHADER_STORAGE_BUFFER, maxBoids * 32, ByVal 0&, GL.GL_DYNAMIC_DRAW
    Next i
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_SSBO(0)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_SSBO(1)
    
    m_BoidProgram = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetAdvancedBoidShader())
    InitializeBoids
End Sub

' ... (InitializeBoids, UpdateBoids, GetCurrentSSBO, Shutdown remain similar to previous version)

Public Sub UpdateBoids(ByVal deltaTime As Single, ByVal playerX As Single, ByVal playerY As Single, ByVal playerZ As Single)
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_SSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_SSBO(writeIdx)
    
    GL.glUseProgram m_BoidProgram
    
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "deltaTime"), deltaTime
    GL.glUniform3f GL.glGetUniformLocation(m_BoidProgram, "playerPosition"), playerX, playerY, playerZ
    GL.glUniform3f GL.glGetUniformLocation(m_BoidProgram, "goalPosition"), GoalPosition.x, GoalPosition.y, GoalPosition.z
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "separationWeight"), SeparationWeight
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "alignmentWeight"), AlignmentWeight
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "cohesionWeight"), CohesionWeight
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "leaderWeight"), LeaderWeight
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "goalWeight"), GoalWeight
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "obstacleWeight"), ObstacleWeight
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "maxSpeed"), MaxSpeed
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "gravity"), Gravity
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "restitution"), Restitution
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "damping"), Damping
    GL.glUniform1f GL.glGetUniformLocation(m_BoidProgram, "time"), Timer()
    
    Dim groups As Long
    groups = (m_MaxBoids + 255) \ 256
    GL.glDispatchCompute groups, 1, 1
    
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    m_CurrentRead = writeIdx
End Sub

' ... (rest of the class unchanged)
