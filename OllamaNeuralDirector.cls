' ============================================================
' Class Module: OllamaNeuralDirector.cls
' Version : BIOLOGICAL v2.60 - 2026-04-15
' Integrates Ollama with neural networks for high-level strategy and mutation suggestions
' Non-blocking calls
' ============================================================

Option Explicit

Private m_NonBlockingOllama As NonBlockingOllama
Private m_EvolutionManager As EnemyEvolutionManager

Public Event OnStrategySuggestion(ByVal suggestion As String)

Public Sub Initialize(ByVal evolutionManager As EnemyEvolutionManager)
    Set m_EvolutionManager = evolutionManager
    Set m_NonBlockingOllama = New NonBlockingOllama
End Sub

' Ask Ollama for high-level strategy based on current morphogenesis state
Public Sub RequestStrategy(ByVal complexity As Single, ByVal patternType As String)
    Dim prompt As String
    prompt = "Current morphogenesis complexity is " & format(complexity, "0.00") & ". " & _
             "Pattern type: " & patternType & ". " & _
             "Suggest one short strategic change for the enemy swarm (e.g. 'increase aggression', 'focus center', 'mutate speed')."
    
    m_NonBlockingOllama.QueryOllamaAsync prompt
End Sub

' Called when Ollama responds (non-blocking)
Private Sub m_NonBlockingOllama_OnOllamaResponse(ByVal responseText As String)
    RaiseEvent OnStrategySuggestion(responseText)
    
    ' Optional: apply suggestion to evolution manager
    If InStr(responseText, "aggression") > 0 Then
        ' Example: tell evolution manager to boost aggression
        Debug.Print "Ollama suggests: Increase aggression"
    ElseIf InStr(responseText, "speed") > 0 Then
        Debug.Print "Ollama suggests: Mutate speed"
    End If
End Sub

Public Sub Shutdown()
    If Not m_NonBlockingOllama Is Nothing Then m_NonBlockingOllama.Shutdown
    Set m_NonBlockingOllama = Nothing
    Set m_EvolutionManager = Nothing
End Sub

