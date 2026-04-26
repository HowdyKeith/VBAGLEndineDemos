' ============================================================
' Class Module: ComputeArmsRaceSystem.cls
' Version : EVOLUTIONARY v1.2 - 2026-04-15
' Coevolution Arms Race - Predators and Prey evolving against each other
' ============================================================

Option Explicit

Private m_PreySSBO(0 To 1) As Long
Private m_PredatorSSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_MaxPrey As Long
Private m_MaxPredators As Long
Private m_Program As Long

Public PreySpeed As Single
Public PredatorSpeed As Single
Public PreyEvasion As Single
Public PredatorChase As Single

Public Sub Initialize(ByVal maxPrey As Long, ByVal maxPredators As Long)
    m_MaxPrey = maxPrey
    m_MaxPredators = maxPredators
    m_CurrentRead = 0
    
    PreySpeed = 1#
    PredatorSpeed = 1#
    PreyEvasion = 1#
    PredatorChase = 1#
    
    GL.glGenBuffers 2, m_PreySSBO(0)
    GL.glGenBuffers 2, m_PredatorSSBO(0)
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetArmsRaceShader())
    InitializePopulations
End Sub

Public Sub Update(ByVal deltaTime As Single)
    ' Update prey then predators with coevolutionary pressure
End Sub

Public Function GetPreySSBO() As Long
    GetPreySSBO = m_PreySSBO(m_CurrentRead)
End Function

Public Function GetPredatorSSBO() As Long
    GetPredatorSSBO = m_PredatorSSBO(m_CurrentRead)
End Function
