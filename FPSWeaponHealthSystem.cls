' ============================================================
' Class Module: FPSWeaponHealthSystem.cls
' Version : BIOLOGICAL v1.6 - 2026-04-15
' Weapon + Health with morphogenesis-driven upgrades
' ============================================================

Option Explicit

Private m_Health As Single
Private m_Ammo As Long
Private m_MaxAmmo As Long
Private m_UpgradeSystem As WeaponUpgradeSystem

Public Sub Initialize(ByVal upgradeSystem As WeaponUpgradeSystem)
    m_Health = 100
    m_MaxAmmo = 30
    m_Ammo = m_MaxAmmo
    Set m_UpgradeSystem = upgradeSystem
End Sub

Public Sub Update()
    m_UpgradeSystem.UpdateUpgrades   ' Live morphogenesis upgrades every frame
    ReadLiveSheetData
End Sub

Public Sub Shoot()
    If m_Ammo > 0 Then
        m_Ammo = m_Ammo - 1
        Dim dmg As Single
        dmg = 25 * m_UpgradeSystem.GetDamageMultiplier()
        EnemySwarm.ApplyDamage dmg
        If Rnd < m_UpgradeSystem.GetSpecialBlastChance() Then EnemySwarm.TriggerBlast
        WriteLiveSheetData
    End If
End Sub


Public Sub TakeDamage(ByVal amount As Single)
    m_Health = m_Health - amount
    If m_Health < 0 Then m_Health = 0
    WriteLiveSheetData
End Sub

Private Sub WriteLiveSheetData()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BioControls")
    ws.range("H2").value = m_Health
    ws.range("H3").value = m_Ammo
End Sub

Public Function IsDead() As Boolean
    IsDead = m_Health <= 0
End Function

