' ============================================================
' Class Module: NeuralEnemyBrain.cls
' Version : BIOLOGICAL v2.61 - 2026-04-15
' Enhanced feed-forward neural network for enemy AI
' Real inputs from pheromone, Lotka-Volterra, morphogenesis, health, velocity
' Outputs steering and speed modifier
' ============================================================

Option Explicit

Private m_InputHidden() As Single
Private m_HiddenOutput() As Single
Private m_HiddenBias() As Single
Private m_OutputBias() As Single

Private Const INPUT_COUNT As Long = 8
Private Const HIDDEN_COUNT As Long = 12
Private Const OUTPUT_COUNT As Long = 3   ' steerX, steerZ, speedMod

Public Sub Initialize()
    ReDim m_InputHidden(1 To INPUT_COUNT, 1 To HIDDEN_COUNT)
    ReDim m_HiddenOutput(1 To HIDDEN_COUNT, 1 To OUTPUT_COUNT)
    ReDim m_HiddenBias(1 To HIDDEN_COUNT)
    ReDim m_OutputBias(1 To OUTPUT_COUNT)
    RandomizeWeights
End Sub

Private Sub RandomizeWeights()
    Dim i As Long, j As Long
    For i = 1 To INPUT_COUNT
        For j = 1 To HIDDEN_COUNT
            m_InputHidden(i, j) = (Rnd - 0.5) * 2#
        Next j
    Next i
    For i = 1 To HIDDEN_COUNT
        For j = 1 To OUTPUT_COUNT
            m_HiddenOutput(i, j) = (Rnd - 0.5) * 2#
        Next j
        m_HiddenBias(i) = (Rnd - 0.5) * 0.5
    Next i
    For i = 1 To OUTPUT_COUNT
        m_OutputBias(i) = (Rnd - 0.5) * 0.5
    Next i
End Sub

' ============================================================
' Think - Forward pass with real inputs
' ============================================================
Public Sub Think(ByRef inputs() As Single, ByRef steerX As Single, ByRef steerZ As Single, ByRef speedMod As Single)
    Dim hidden(1 To HIDDEN_COUNT) As Single
    Dim i As Long, j As Long
    
    ' Hidden layer
    For j = 1 To HIDDEN_COUNT
        hidden(j) = m_HiddenBias(j)
        For i = 1 To INPUT_COUNT
            hidden(j) = hidden(j) + inputs(i) * m_InputHidden(i, j)
        Next i
        hidden(j) = Sgn(hidden(j))   ' Simple activation for speed in VBA
    Next j
    
    ' Output layer
    Dim out(1 To OUTPUT_COUNT) As Single
    For j = 1 To OUTPUT_COUNT
        out(j) = m_OutputBias(j)
        For i = 1 To HIDDEN_COUNT
            out(j) = out(j) + hidden(i) * m_HiddenOutput(i, j)
        Next i
    Next j
    
    steerX = out(1)
    steerZ = out(2)
    speedMod = out(3)
End Sub

' ============================================================
' Mutate weights when morphogenesis complexity is high
' ============================================================
Public Sub Mutate(ByVal mutationRate As Single)
    Dim i As Long, j As Long
    If Rnd < mutationRate Then
        For i = 1 To INPUT_COUNT
            For j = 1 To HIDDEN_COUNT
                If Rnd < 0.3 Then m_InputHidden(i, j) = m_InputHidden(i, j) + (Rnd - 0.5) * 0.8
            Next j
        Next i
    End If
End Sub

Public Sub Shutdown()
End Sub
