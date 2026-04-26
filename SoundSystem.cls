' ============================================================
' Class Module: SoundSystem.cls
' Version : BIOLOGICAL v2.60 - 2026-04-15
' Morphogenesis-driven real-time sound effects via Win32 API
' Fixed Declare statements for 32/64-bit compatibility
' ============================================================

Option Explicit

' Correct Declare statements for both 32-bit and 64-bit Excel
#If VBA7 Then
    Private Declare PtrSafe Function Beep Lib "kernel32" (ByVal dwFreq As Long, ByVal dwDuration As Long) As Long
    Private Declare PtrSafe Function PlaySound Lib "winmm" Alias "PlaySoundA" (ByVal lpszName As String, ByVal hModule As LongPtr, ByVal dwFlags As Long) As Long
#Else
    Private Declare Function Beep Lib "kernel32" (ByVal dwFreq As Long, ByVal dwDuration As Long) As Long
    Private Declare Function PlaySound Lib "winmm" Alias "PlaySoundA" (ByVal lpszName As String, ByVal hModule As Long, ByVal dwFlags As Long) As Long
#End If

Private m_Turing As TuringPatternAnalyzer
Private m_LastComplexity As Single

Public Sub Initialize(ByVal turingAnalyzer As TuringPatternAnalyzer)
    Set m_Turing = turingAnalyzer
    m_LastComplexity = 0
End Sub

Public Sub UpdateSound(ByVal deltaTime As Single)
    Dim complexity As Single
    complexity = m_Turing.Entropy + m_Turing.SpotRatio * 2#
   
    ' Morphogenesis complexity drives sound
    Dim freq As Long
    freq = 200 + CInt(complexity * 800)   ' base 200 Hz ? high chaos = high pitch
   
    ' Pulse rhythm based on pattern
    If Abs(complexity - m_LastComplexity) > 0.3 Then
        Beep freq, 40   ' Sharp "heartbeat" on sudden pattern change
    ElseIf complexity > 0.7 Then
        Beep freq, 15   ' Fast chaotic beeps for high complexity
    Else
        Beep freq, 80   ' Slow pulsing for calm patterns
    End If
   
    m_LastComplexity = complexity
End Sub

Public Sub Shutdown()
    Set m_Turing = Nothing
End Sub
