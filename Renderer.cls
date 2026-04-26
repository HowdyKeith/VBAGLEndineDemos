' ============================================================
' Class Module: Renderer.cls
' Version : BIOLOGICAL v2.5 - 2026-04-15
' Performance-optimized renderer with one-time VAO setup, state caching, and minimal GL calls
' ============================================================

Option Explicit

Private m_ParticleProgram As Long
Private m_ParticleBloomProgram As Long

' State caching
Private m_CurrentVAO As Long
Private m_CurrentProgram As Long

Public Sub Initialize()
    m_ParticleProgram = ShaderProgram.CreateProgram( _
        EmbeddedShaders.FULLSCREEN_QUAD_VERTEX, _
        EmbeddedShaders.PARTICLE_FRAGMENT)
    
    m_ParticleBloomProgram = ShaderProgram.CreateProgram( _
        EmbeddedShaders.FULLSCREEN_QUAD_VERTEX, _
        EmbeddedShaders.PARTICLE_BLOOM_FRAGMENT)
    
    m_CurrentVAO = 0
    m_CurrentProgram = 0
End Sub

' ============================================================
' Optimized instanced particle draw with bloom support
' ============================================================
Public Sub DrawInstancedParticles(ByVal instanceBuffer As instanceBuffer, ByVal particleType As String)
    If instanceBuffer Is Nothing Or instanceBuffer.InstanceCount = 0 Then Exit Sub
    
    Dim targetProgram As Long
    Select Case particleType
        Case "weapon_trails_bloom", "explosion_vfx"
            targetProgram = m_ParticleBloomProgram
        Case Else
            targetProgram = m_ParticleProgram
    End Select
    
    ' State caching – avoid redundant GL calls
    If m_CurrentVAO <> instanceBuffer.VAO Then
        GL.glBindVertexArray instanceBuffer.VAO
        m_CurrentVAO = instanceBuffer.VAO
    End If
    
    If m_CurrentProgram <> targetProgram Then
        GL.glUseProgram targetProgram
        m_CurrentProgram = targetProgram
    End If
    
    ' Set bloom uniforms only when needed
    If particleType = "weapon_trails_bloom" Or particleType = "explosion_vfx" Then
        GL.glUniform1f GL.glGetUniformLocation(targetProgram, "bloomIntensity"), 1.8 + turingAnalyzer.SpotRatio * 2.2
        GL.glUniform1f GL.glGetUniformLocation(targetProgram, "time"), Timer()
    End If
    
    GL.glDrawElementsInstanced GL.GL_TRIANGLES, instanceBuffer.IndexCount, GL.GL_UNSIGNED_INT, ByVal 0&, instanceBuffer.InstanceCount
End Sub

Public Sub Shutdown()
    If m_ParticleProgram <> 0 Then GL.glDeleteProgram m_ParticleProgram
    If m_ParticleBloomProgram <> 0 Then GL.glDeleteProgram m_ParticleBloomProgram
End Sub

