' ============================================================
' LiveSheetDataManager.bas
' Version : BIOLOGICAL v1.3 - 2026-04-15
' Real-time Excel sheet data for all biological sims + FPS swarm
' ============================================================

Option Explicit

Public Sub ReadLiveSheetParameters()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("BioControls")   ' Create this sheet with named cells below
    
    ' === Biological Simulation Tuning ===
    lvSystem.FeedRate = ws.range("B2").value
    lvSystem.KillRate = ws.range("B3").value
    SlimeSystem.DiffuseRate = ws.range("B5").value
    SlimeSystem.DecayRate = ws.range("B6").value
    BacteriaSystem.GrowthRate = ws.range("B8").value
    BacteriaSystem.ConsumptionRate = ws.range("B9").value
    FitzSystem.a = ws.range("B11").value
    FitzSystem.epsilon = ws.range("B12").value
    antSystem.EvaporationRate = ws.range("B14").value
    antSystem.DepositRate = ws.range("B15").value
    
    ' === FPS Enemy Swarm Tuning ===
    EnemySwarm.MaxEnemies = ws.range("D2").value
    EnemySwarm.PredatorRatio = ws.range("D3").value
    EnemySwarm.Aggression = ws.range("D4").value
    EnemySwarm.HealthMultiplier = ws.range("D5").value
    
    ' Optional: write current population back to sheet
    ws.range("F2").value = lvSystem.CurrentPreyCount
    ws.range("F3").value = lvSystem.CurrentPredatorCount
End Sub
