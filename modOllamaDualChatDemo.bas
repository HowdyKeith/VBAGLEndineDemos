' ============================================================
' Module: modOllamaDualChatDemo.bas
' Version : BIOLOGICAL v2.60 - 2026-04-15
' Demo of two Ollama instances discussing with each other
' Outputs live dialog to Immediate Window
' Non-blocking
' ============================================================

Option Explicit

Private m_Ollama1 As NonBlockingOllama   ' Predator Strategist
Private m_Ollama2 As NonBlockingOllama   ' Ecosystem Observer
Private m_Turn As Long

Public Sub StartOllamaDualChatDemo()
    Set m_Ollama1 = New NonBlockingOllama
    Set m_Ollama2 = New NonBlockingOllama
    
    m_Turn = 1
    Debug.Print "=== OLLAMA DUAL CONVERSATION STARTED ==="
    Debug.Print "Predator Strategist vs Ecosystem Observer"
    Debug.Print "========================================"
    
    ' Start conversation
    m_Ollama1.QueryOllamaAsync "You are the Predator Strategist. The morphogenesis pattern is becoming highly complex. What is your strategy for the swarm?"
End Sub

Private Sub m_Ollama1_OnOllamaResponse(ByVal responseText As String)
    Debug.Print "Predator Strategist: " & responseText
    
    ' Let the other Ollama respond
    If m_Turn = 1 Then
        m_Turn = 2
        m_Ollama2.QueryOllamaAsync "You are the Ecosystem Observer. The Predator Strategist just said: " & responseText & ". What is your observation about the morphogenesis pattern?"
    End If
End Sub

Private Sub m_Ollama2_OnOllamaResponse(ByVal responseText As String)
    Debug.Print "Ecosystem Observer: " & responseText
    
    ' Continue the conversation (loop)
    If m_Turn = 2 Then
        m_Turn = 1
        m_Ollama1.QueryOllamaAsync "You are the Predator Strategist. The Ecosystem Observer just said: " & responseText & ". Respond with your next strategic adjustment."
    End If
End Sub

Public Sub StopOllamaDualChatDemo()
    If Not m_Ollama1 Is Nothing Then m_Ollama1.Shutdown
    If Not m_Ollama2 Is Nothing Then m_Ollama2.Shutdown
    Set m_Ollama1 = Nothing
    Set m_Ollama2 = Nothing
    Debug.Print "=== OLLAMA DUAL CONVERSATION STOPPED ==="
End Sub
