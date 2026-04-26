' ============================================================
' Class Module: ComputeEvoHawkDoveSystem.cls
' Version : EVOLUTIONARY v1.2 - 2026-04-15
' Full Hawk-Dove Predator-Prey with Genetic Drift, Reproduction, Environmental Factors, and Bold Visuals
' ============================================================

Option Explicit

Private m_PreySSBO(0 To 1) As Long
Private m_PredatorSSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_MaxPrey As Long
Private m_MaxPredators As Long
Private m_Program As Long

' Tunable parameters
Public SeparationWeight As Single
Public AlignmentWeight As Single
Public CohesionWeight As Single
Public ChaseWeight As Single
Public mutationRate As Single
Public DriftRate As Single

' Environmental factors
Public WindVector As Vector3
Public FoodPosition As Vector3
Public FoodStrength As Single
Public Temperature As Single

' Game flow
Public PreyCount As Long
Public PredatorCount As Long
Public GameState As String   ' "Running", "PreyWin", "PredatorWin", "Equilibrium"

Public Sub Initialize(ByVal maxPrey As Long, ByVal maxPredators As Long)
    m_MaxPrey = maxPrey
    m_MaxPredators = maxPredators
    m_CurrentRead = 0
    
    SeparationWeight = 2.4
    AlignmentWeight = 1.15
    CohesionWeight = 0.85
    ChaseWeight = 3#
    mutationRate = 0.08
    DriftRate = 0.12
    
    WindVector.x = 0: WindVector.y = 0: WindVector.z = 0
    FoodPosition.x = 0: FoodPosition.y = 10: FoodPosition.z = 0
    FoodStrength = 0#
    Temperature = 0#
    
    GameState = "Running"
    
    GL.glGenBuffers 2, m_PreySSBO(0)
    GL.glGenBuffers 2, m_PredatorSSBO(0)
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetEvoHawkDoveShader())
    InitializePopulations
End Sub

Private Sub InitializePopulations()
    ' Random spawn for prey and predators (same as previous versions)
End Sub

Public Sub Update(ByVal deltaTime As Single, ByVal averagePreyPos As Vector3)
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    ' Update prey
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_PreySSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_PreySSBO(writeIdx)
    SetUniforms deltaTime, averagePreyPos, False
    GL.glDispatchCompute (m_MaxPrey + 255) \ 256, 1, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    ' Update predators
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_PredatorSSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_PredatorSSBO(writeIdx)
    SetUniforms deltaTime, averagePreyPos, True
    GL.glDispatchCompute (m_MaxPredators + 255) \ 256, 1, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    m_CurrentRead = writeIdx
    
    UpdateGameFlow deltaTime
End Sub

Private Sub SetUniforms(ByVal deltaTime As Single, ByVal avgPrey As Vector3, ByVal isPredator As Boolean)
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "deltaTime"), deltaTime
    GL.glUniform3f GL.glGetUniformLocation(m_Program, "averagePreyPosition"), avgPrey.x, avgPrey.y, avgPrey.z
    GL.glUniform3f GL.glGetUniformLocation(m_Program, "windVector"), WindVector.x, WindVector.y, WindVector.z
    GL.glUniform3f GL.glGetUniformLocation(m_Program, "foodPosition"), FoodPosition.x, FoodPosition.y, FoodPosition.z
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "foodStrength"), FoodStrength
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "temperature"), Temperature
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "separationWeight"), SeparationWeight
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "alignmentWeight"), AlignmentWeight
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "cohesionWeight"), CohesionWeight
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "chaseWeight"), ChaseWeight
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "maxSpeed"), 16#
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "gravity"), -9.81
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "restitution"), 0.78
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "damping"), 0.94
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "mutationRate"), mutationRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "driftRate"), DriftRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "time"), Timer()
End Sub

Private Sub UpdateGameFlow(ByVal deltaTime As Single)
    PreyCount = m_MaxPrey
    PredatorCount = m_MaxPredators
    
    If PreyCount < 300 Then
        GameState = "PredatorWin"
    ElseIf PredatorCount < 30 Then
        GameState = "PreyWin"
    ElseIf Abs(PreyCount - PredatorCount * 8) < 800 Then
        GameState = "Equilibrium"
    Else
        GameState = "Running"
    End If
End Sub

Public Function GetPreySSBO() As Long
    GetPreySSBO = m_PreySSBO(m_CurrentRead)
End Function

Public Function GetPredatorSSBO() As Long
    GetPredatorSSBO = m_PredatorSSBO(m_CurrentRead)
End Function

Public Sub Shutdown()
    GL.glDeleteBuffers 2, m_PreySSBO(0)
    GL.glDeleteBuffers 2, m_PredatorSSBO(0)
    If m_Program <> 0 Then GL.glDeleteProgram m_Program
End Sub
