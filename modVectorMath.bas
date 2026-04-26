' ============================================================
' Module: modVectorMath.bas
' Version : BIOLOGICAL v2.60 - 2026-04-15
' High-performance Vector3 math using Types (ByRef where possible)
' ============================================================

Option Explicit

Public Sub Vec3Add(ByRef a As Vector3, ByRef b As Vector3, ByRef result As Vector3)
    result.x = a.x + b.x
    result.y = a.y + b.y
    result.z = a.z + b.z
End Sub

Public Sub Vec3Subtract(ByRef a As Vector3, ByRef b As Vector3, ByRef result As Vector3)
    result.x = a.x - b.x
    result.y = a.y - b.y
    result.z = a.z - b.z
End Sub

Public Sub Vec3Scale(ByRef v As Vector3, ByVal scalar As Single, ByRef result As Vector3)
    result.x = v.x * scalar
    result.y = v.y * scalar
    result.z = v.z * scalar
End Sub

Public Function Vec3Length(ByRef v As Vector3) As Single
    Vec3Length = Sqr(v.x * v.x + v.y * v.y + v.z * v.z)
End Function

Public Sub Vec3Normalize(ByRef v As Vector3, ByRef result As Vector3)
    Dim len As Single
    len = Vec3Length(v)
    If len > 0.00001 Then
        result.x = v.x / len
        result.y = v.y / len
        result.z = v.z / len
    Else
        result.x = 0: result.y = 0: result.z = 0
    End If
End Sub

Public Function Vec3Dot(ByRef a As Vector3, ByRef b As Vector3) As Single
    Vec3Dot = a.x * b.x + a.y * b.y + a.z * b.z
End Function

Public Sub Vec3Cross(ByRef a As Vector3, ByRef b As Vector3, ByRef result As Vector3)
    result.x = a.y * b.z - a.z * b.y
    result.y = a.z * b.x - a.x * b.z
    result.z = a.x * b.y - a.y * b.x
End Sub

Public Function Vec3Distance(ByRef a As Vector3, ByRef b As Vector3) As Single
    Dim dx As Single, dy As Single, dz As Single
    dx = a.x - b.x
    dy = a.y - b.y
    dz = a.z - b.z
    Vec3Distance = Sqr(dx * dx + dy * dy + dz * dz)
End Function

Public Sub Vec3Zero(ByRef v As Vector3)
    v.x = 0: v.y = 0: v.z = 0
End Sub

Public Sub Vec3Copy(ByRef source As Vector3, ByRef dest As Vector3)
    dest.x = source.x
    dest.y = source.y
    dest.z = source.z
End Sub

Public Sub Vec3RandomUnit(ByRef result As Vector3)
    result.x = Rnd - 0.5
    result.y = Rnd - 0.5
    result.z = Rnd - 0.5
    Vec3Normalize result, result
End Sub
