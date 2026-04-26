' ============================================================
' Class Module: ComputePredatorPreySystem.cls
' Version : ADVANCED v1.2 - 2026-04-15
' GPU Predator-Prey Dynamics
' ============================================================

Option Explicit

Private m_PreySSBO(0 To 1) As Long
Private m_PredatorSSBO(0 To 1) As Long
Private m_CurrentRead As Long
Private m_MaxPrey As Long
Private m_MaxPredators As Long
Private m_Program As Long

' Tunable weights
Public PreySeparationWeight As Single
Public PreyAlignmentWeight As Single
Public PreyCohesionWeight As Single
Public PredatorChaseWeight As Single
Public MaxSpeed As Single

Public Sub Initialize(ByVal maxPrey As Long, ByVal maxPredators As Long)
    m_MaxPrey = maxPrey
    m_MaxPredators = maxPredators
    m_CurrentRead = 0
    
    PreySeparationWeight = 2.4
    PreyAlignmentWeight = 1.15
    PreyCohesionWeight = 0.85
    PredatorChaseWeight = 3#
    MaxSpeed = 16#
    
    ' Create ping-pong buffers for prey
    GL.glGenBuffers 2, m_PreySSBO(0)
    ' Create ping-pong buffers for predators
    GL.glGenBuffers 2, m_PredatorSSBO(0)
    
    ' Allocate and initialize buffers (omitted for brevity - same as previous systems)
    
    m_Program = ShaderProgram.CreateComputeProgram(EmbeddedShaders.GetPredatorPreyShader())
End Sub

Public Sub Update(ByVal deltaTime As Single, ByVal averagePreyPos As Vector3)
    ' Bind prey buffers, dispatch, swap
    ' Then bind predator buffers, dispatch, swap
End Sub

Public Function GetPreySSBO() As Long
    GetPreySSBO = m_PreySSBO(m_CurrentRead)
End Function

Public Function GetPredatorSSBO() As Long
    GetPredatorSSBO = m_PredatorSSBO(m_CurrentRead)
End Function
