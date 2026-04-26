' ============================================================
' Class Module: FullEcosystem7Species.cls
' Version : BIOLOGICAL v2.2 - 2026-04-15
' Complete 7-species ecosystem (Nutrient ? Bacteria ? Slime ? Mid-Pred ? Top-Pred ? Apex-Pred ? FPS Swarm)
' ============================================================

Option Explicit

Private m_Nutrient As ComputeBacterialColonySystem
Private m_Bacteria As ComputeBacterialColonySystem
Private m_Slime As ComputeSlimeMoldSystem
Private m_MidPred As ComputePredatorPreySystem
Private m_TopPred As ComputePredatorPreySystem
Private m_ApexPred As ComputePredatorPreySystem
Private m_FPS_Swarm As FPSPredatorPreySwarm

Public Sub Initialize( _
    ByVal nutrient As ComputeBacterialColonySystem, _
    ByVal bacteria As ComputeBacterialColonySystem, _
    ByVal slime As ComputeSlimeMoldSystem, _
    ByVal midPred As ComputePredatorPreySystem, _
    ByVal topPred As ComputePredatorPreySystem, _
    ByVal apexPred As ComputePredatorPreySystem, _
    ByVal fpsSwarm As FPSPredatorPreySwarm)
    
    Set m_Nutrient = nutrient
    Set m_Bacteria = bacteria
    Set m_Slime = slime
    Set m_MidPred = midPred
    Set m_TopPred = topPred
    Set m_ApexPred = apexPred
    Set m_FPS_Swarm = fpsSwarm
End Sub

Public Sub UpdateEcosystem(ByVal deltaTime As Single)
    ' 7-species food chain with morphogenesis coupling
    m_Nutrient.ConsumptionRate = m_Morpho.ProductionRate * 1.8
    m_Bacteria.GrowthRate = m_Nutrient.CurrentLevel * 1.1
    m_Slime.DiffuseRate = 0.7 + m_Turing.SpotRatio * 0.9
    m_MidPred.Aggression = 1# + m_Turing.Entropy * 1.4
    m_TopPred.Aggression = 1.3 + m_Turing.SpotRatio * 1.6
    m_ApexPred.Aggression = 1.6 + m_Turing.Entropy * 2.2
    m_FPS_Swarm.GlobalDifficulty = m_Turing.Entropy + m_Turing.SpotRatio * 2#
End Sub

Public Sub Shutdown()
    ' references only
End Sub

