' ============================================================
' Class Module: NonBlockingOllama.cls
' Version : BIOLOGICAL v2.2 - 2026-04-15
' Non-blocking Ollama calls (no VBA freeze) – polls every 0.5s
' ============================================================

Option Explicit

Private m_TimerID As Long
Private m_PendingPrompt As String
Private m_LastResponse As String

Public Event OnOllamaResponse(ByVal responseText As String)

Public Sub QueryOllamaAsync(ByVal prompt As String)
    m_PendingPrompt = prompt
    If m_TimerID = 0 Then
        m_TimerID = Application.OnTime(now + TimeValue("00:00:00.5"), "OllamaPollTimer")
    End If
End Sub

' Called by timer – non-blocking poll
Private Sub PollOllama()
    If m_PendingPrompt = "" Then Exit Sub
    
    Dim http As Object
    Set http = CreateObject("MSXML2.XMLHTTP")
    http.Open "POST", "http://localhost:11434/api/generate", False
    http.setRequestHeader "Content-Type", "application/json"
    http.Send "{""model"": ""llama3"", ""prompt"": """ & Replace(m_PendingPrompt, """", "'") & """, ""stream"": false}"
    
    If http.Status = 200 Then
        m_LastResponse = http.responseText
        RaiseEvent OnOllamaResponse(m_LastResponse)
        Debug.Print "Ollama (non-blocking): " & Left(m_LastResponse, 120) & "..."
    End If
    
    m_PendingPrompt = ""
    m_TimerID = Application.OnTime(now + TimeValue("00:00:00.5"), "OllamaPollTimer")
End Sub

Public Sub Shutdown()
    If m_TimerID <> 0 Then Application.OnTime m_TimerID, "OllamaPollTimer", , False
End Sub
