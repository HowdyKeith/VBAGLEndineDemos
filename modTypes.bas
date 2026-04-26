' ============================================================
' Module: modTypes.bas
' Version : BIOLOGICAL v2.67 - 2026-04-15
' Core types for all biological simulations + Vector3 helper functions
' ============================================================

Option Explicit

Public Type Vector3
    x As Single
    y As Single
    z As Single
End Type

Public Type Vector4
    x As Single
    y As Single
    z As Single
    w As Single
End Type

Public Type Matrix4
    m(0 To 15) As Single   ' Column-major
End Type

Public Type ParticleData
    Position As Vector3
    Velocity As Vector3
    Life As Single
    Size As Single
    ColorR As Single
    ColorG As Single
    ColorB As Single
    Padding As Single
End Type

Public Type CollisionSphere
    center As Vector3
    radius As Single
End Type

' Simple vector helper (used by collision response)
Public Function Vec3Distance(ByRef a As Vector3, ByRef b As Vector3) As Single
    Dim dx As Single, dy As Single, dz As Single
    dx = a.x - b.x
    dy = a.y - b.y
    dz = a.z - b.z
    Vec3Distance = Sqr(dx * dx + dy * dy + dz * dz)
End Function
