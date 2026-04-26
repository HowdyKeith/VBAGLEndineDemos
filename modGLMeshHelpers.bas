' ============================================================
' Module: modGLMeshHelpers.bas
' Version : EVOLUTIONARY v1.2 - 2026-04-15
' Mesh helpers for the evolutionary boid demos
' ============================================================

Option Explicit

Public Function CreateBoidMesh() As GLMesh
    Set CreateBoidMesh = New GLMesh
    
    ' Simple arrow shape (pointing forward)
    Dim verts(0 To 8) As Single
    verts(0) = 0:   verts(1) = 0:   verts(2) = 0.8   ' tip
    verts(3) = -0.25: verts(4) = 0: verts(5) = -0.4  ' left wing
    verts(6) = 0.25:  verts(7) = 0: verts(8) = -0.4  ' right wing
    
    Dim indices(0 To 2) As Long
    indices(0) = 0: indices(1) = 1: indices(2) = 2
    
    ' TODO: Replace with your existing mesh creation code
    ' (Create VAO, VBO, IBO from verts and indices)
    CreateBoidMesh.IndexCount = 3
End Function

Public Function CreatePredatorMesh() As GLMesh
    Set CreatePredatorMesh = New GLMesh
    ' Slightly larger and more aggressive shape (optional)
    ' You can reuse CreateBoidMesh or make a different shape
    Set CreatePredatorMesh = CreateBoidMesh
End Function
