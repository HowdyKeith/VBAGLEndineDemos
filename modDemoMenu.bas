' ============================================================
' Module: modDemoMenu.bas
' Version : BIOLOGICAL v2.4 - 2026-04-15
' Comprehensive keyboard menu for ALL biological + evolutionary demos
' One unified module - press keys to control everything live
' ============================================================

Option Explicit

' ============================================================
' Global References (set in StartFullBioFPSDemo)
' ============================================================
Public lvSystem As ComputeSpatialLotkaVolterra
Public SlimeSystem As ComputeSlimeMoldSystem
Public BacteriaSystem As ComputeBacterialColonySystem
Public FitzSystem As ComputeFitzHughNagumoSystem
Public antSystem As ComputeAntColonySystem
Public MorphoSystem As ComputeMorphogenesisSystem
Public RDSystem As ComputeReactionDiffusionSystem
Public EnemySwarm As FPSPredatorPreySwarm
Public WeaponHealth As FPSWeaponHealthSystem
Public AIDirector As BiologicalAIDirector

' ============================================================
' Main Menu Handler - Call this every frame
' ============================================================
Public Sub HandleAllDemoMenu()
    ' === Pattern Selection (Reaction-Diffusion / Morphogenesis) ===
    If GetAsyncKeyState(vbKey1) Then RDSystem.CurrentPatternID = 0: Debug.Print "Pattern: Gray-Scott"
    If GetAsyncKeyState(vbKey2) Then RDSystem.CurrentPatternID = 1: Debug.Print "Pattern: Oregonator"
    If GetAsyncKeyState(vbKey3) Then RDSystem.CurrentPatternID = 2: Debug.Print "Pattern: FitzHugh-Nagumo"
    If GetAsyncKeyState(vbKey4) Then RDSystem.CurrentPatternID = 3: Debug.Print "Pattern: Schnakenberg"
    
    ' === Morphogenesis Controls ===
    If GetAsyncKeyState(vbKeyQ) Then MorphoSystem.ActivatorDiff = MorphoSystem.ActivatorDiff + 0.01
    If GetAsyncKeyState(vbKeyA) Then MorphoSystem.ActivatorDiff = MorphoSystem.ActivatorDiff - 0.01
    If GetAsyncKeyState(vbKeyW) Then MorphoSystem.InhibitorDiff = MorphoSystem.InhibitorDiff + 0.02
    If GetAsyncKeyState(vbKeyS) Then MorphoSystem.InhibitorDiff = MorphoSystem.InhibitorDiff - 0.02
    If GetAsyncKeyState(vbKeyE) Then MorphoSystem.ProductionRate = MorphoSystem.ProductionRate + 0.005
    If GetAsyncKeyState(vbKeyD) Then MorphoSystem.ProductionRate = MorphoSystem.ProductionRate - 0.005
    
    ' === Slime Mold Controls ===
    If GetAsyncKeyState(vbKeyZ) Then SlimeSystem.DiffuseRate = SlimeSystem.DiffuseRate + 0.05
    If GetAsyncKeyState(vbKeyX) Then SlimeSystem.DiffuseRate = SlimeSystem.DiffuseRate - 0.05
    If GetAsyncKeyState(vbKeyC) Then SlimeSystem.DecayRate = SlimeSystem.DecayRate + 0.02
    If GetAsyncKeyState(vbKeyV) Then SlimeSystem.DecayRate = SlimeSystem.DecayRate - 0.02
    
    ' === FPS Enemy Swarm Controls ===
    If GetAsyncKeyState(vbKeyT) Then EnemySwarm.Aggression = EnemySwarm.Aggression + 0.1
    If GetAsyncKeyState(vbKeyG) Then EnemySwarm.Aggression = EnemySwarm.Aggression - 0.1
    If GetAsyncKeyState(vbKeyY) Then EnemySwarm.GlobalDifficulty = EnemySwarm.GlobalDifficulty + 0.1
    If GetAsyncKeyState(vbKeyH) Then EnemySwarm.GlobalDifficulty = EnemySwarm.GlobalDifficulty - 0.1
    
    ' === Weapon & Health ===
    If GetAsyncKeyState(vbKeyR) Then WeaponHealth.ReloadAmmo
    If GetAsyncKeyState(vbKeyF) Then WeaponHealth.TakeDamage 10   ' test damage
    
    ' === Save / Load Configurations ===
    If GetAsyncKeyState(vbKeyF5) Then QuickSaveConfig
    If GetAsyncKeyState(vbKeyF9) Then QuickLoadConfig
    
    ' === Print Status (every second or on demand)
    If GetAsyncKeyState(vbKeyP) Then PrintFullStatus
End Sub

' ============================================================
' Print comprehensive status to Immediate Window
' ============================================================
Public Sub PrintFullStatus()
    Debug.Print "=== BIOLOGICAL DEMO STATUS ==="
    Debug.Print "Reaction-Diffusion Pattern: " & RDSystem.CurrentPatternID
    Debug.Print "Morphogenesis ActivatorDiff: " & MorphoSystem.ActivatorDiff
    Debug.Print "Morphogenesis InhibitorDiff: " & MorphoSystem.InhibitorDiff
    Debug.Print "Slime Diffuse Rate: " & SlimeSystem.DiffuseRate
    Debug.Print "Enemy Aggression: " & EnemySwarm.Aggression
    Debug.Print "Global Difficulty: " & EnemySwarm.GlobalDifficulty
    Debug.Print "Player Health: " & WeaponHealth.health
    Debug.Print "Player Ammo: " & WeaponHealth.ammo
    Debug.Print "Turing Complexity: " & turingAnalyzer.Entropy
    Debug.Print "Current Pattern Type: " & turingAnalyzer.patternType
    Debug.Print "=============================="
End Sub

' ============================================================
' Quick Save / Load (uses modConfigManager)
' ============================================================
Public Sub QuickSaveConfig()
    SaveCurrentConfig 1
End Sub

Public Sub QuickLoadConfig()
    LoadConfig 1
End Sub

' ============================================================
' Reload ammo helper
' ============================================================
Public Sub ReloadAmmo()
    WeaponHealth.ammo = WeaponHealth.maxAmmo
    Debug.Print "Weapon reloaded!"
End Sub
