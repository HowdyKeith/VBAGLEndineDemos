' ============================================================
' Class Module: ComputePhysicsSystem.cls
' Version : IMPROVED v1.2 - 2026-04-15
' GPU Compute-based Physics Simulation with Ping-Pong SSBOs
' ============================================================

Option Explicit

Private m_SSBO(0 To 1) As Long          ' Ping-pong buffers
Private m_CurrentRead As Long
Private m_MaxObjects As Long
Private m_PhysicsProgram As Long

Public Sub Initialize(ByVal maxObjects As Long)
    m_MaxObjects = maxObjects
    m_CurrentRead = 0
    
    ' Create two SSBOs for ping-pong
    GL.glGenBuffers 2, m_SSBO(0)
    
    Dim i As Long
    For i = 0 To 1
        GL.glBindBuffer GL.GL_SHADER_STORAGE_BUFFER, m_SSBO(i)
        GL.glBufferData GL.GL_SHADER_STORAGE_BUFFER, maxObjects * 32, ByVal 0&, GL.GL_DYNAMIC_DRAW
    Next i
    
    ' Bind both buffers (read = 0, write = 1)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_SSBO(0)
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_SSBO(1)
    
    ' Compile physics compute shader
    m_PhysicsProgram = ShaderProgram.CreateComputeProgram(EmbeddedShaders.PHYSICS_UPDATE_COMP)
End Sub

Public Sub UpdatePhysics(ByVal deltaTime As Single)
    Dim readIdx As Long, writeIdx As Long
    readIdx = m_CurrentRead
    writeIdx = 1 - m_CurrentRead
    
    ' Bind correct buffers
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 0, m_SSBO(readIdx)   ' Read
    GL.glBindBufferBase GL.GL_SHADER_STORAGE_BUFFER, 1, m_SSBO(writeIdx)  ' Write
    
    GL.glUseProgram m_PhysicsProgram
    
    ' Set uniforms
    GL.glUniform1f GL.glGetUniformLocation(m_PhysicsProgram, "deltaTime"), deltaTime
    GL.glUniform1f GL.glGetUniformLocation(m_PhysicsProgram, "gravity"), -9.81
    GL.glUniform1f GL.glGetUniformLocation(m_PhysicsProgram, "damping"), 0.98
    GL.glUniform1f GL.glGetUniformLocation(m_PhysicsProgram, "restitution"), 0.85
    
    ' Dispatch
    Dim groups As Long
    groups = (m_MaxObjects + 255) \ 256          ' Use 256 workgroup size
    GL.glDispatchCompute groups, 1, 1
    
    GL.glMemoryBarrier GL.GL_SHADER_STORAGE_BARRIER_BIT
    
    m_CurrentRead = writeIdx                     ' Swap buffers
End Sub

' Get current read buffer for rendering
Public Function GetCurrentSSBO() As Long
    GetCurrentSSBO = m_SSBO(m_CurrentRead)
End Function

Public Sub Shutdown()
    GL.glDeleteBuffers 2, m_SSBO(0)
    If m_PhysicsProgram <> 0 Then GL.glDeleteProgram m_PhysicsProgram
End Sub
