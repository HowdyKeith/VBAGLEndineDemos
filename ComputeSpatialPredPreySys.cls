' ============================================================
' Class Module: ComputeSpatialPredPreySys.cls
' Version : EVOLUTIONARY v1.2 - 2026-04-15
' Spatial Predator-Prey with local interactions + reproduction
' ============================================================

Option Explicit

Private m_PreySSBO(0 To 1) As Long
Private m_PredatorSSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_MaxPrey As Long
Private m_MaxPredators As Long
Private m_Program As Long

' Tunable parameters
Public InteractionRadius As Single
Public SeparationWeight As Single
Public AlignmentWeight As Single
Public CohesionWeight As Single
Public ChaseWeight As Single
Public ReproductionThreshold As Single   ' Fitness needed to reproduce
Public BirthRate As Single               ' Birth probability per update
Public DeathRate As Single

Public Sub Initialize(ByVal maxPrey As Long, ByVal maxPredators As Long)
    m_MaxPrey = maxPrey
    m_MaxPredators = maxPredators
    m_CurrentRead = 0
    
    InteractionRadius = 10#
    SeparationWeight = 2.4
    AlignmentWeight = 1.15
    CohesionWeight = 0.85
    ChaseWeight = 3#
    ReproductionThreshold = 8#
    BirthRate = 0.03
    DeathRate = 0.015
    
    GL.glGenBuffers 2, m_PreySSBO(0)
    GL.glGenBuffers 2, m_PredatorSSBO(0)
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetSpatialPredatorPreyShader())
    InitializePopulations
End Sub

Public Sub Update(ByVal deltaTime As Single)
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    ' Update prey
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_PreySSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_PreySSBO(writeIdx)
    SetUniforms deltaTime, False
    GL.glDispatchCompute (m_MaxPrey + 255) \ 256, 1, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    ' Update predators
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_PredatorSSBO(readIdx)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_PredatorSSBO(writeIdx)
    SetUniforms deltaTime, True
    GL.glDispatchCompute (m_MaxPredators + 255) \ 256, 1, 1
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    m_CurrentRead = writeIdx
End Sub

Private Sub SetUniforms(ByVal deltaTime As Single, ByVal isPredator As Boolean)
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "deltaTime"), deltaTime
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "interactionRadius"), InteractionRadius
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "separationWeight"), SeparationWeight
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "alignmentWeight"), AlignmentWeight
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "cohesionWeight"), CohesionWeight
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "chaseWeight"), ChaseWeight
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "reproductionThreshold"), ReproductionThreshold
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "birthRate"), BirthRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "deathRate"), DeathRate
    GL.glUniform1f GL.glGetUniformLocation(m_Program, "time"), Timer()
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
