' ============================================================
' Class Module: FullEcosystem9Species.cls
' Version : BIOLOGICAL v2.5 - 2026-04-15
' Complete 9-species ecosystem with full morphogenesis coupling
' ============================================================

Option Explicit

Private m_Nutrient As ComputeBacterialColonySystem
Private m_Bacteria As ComputeBacterialColonySystem
Private m_Slime As ComputeSlimeMoldSystem
Private m_MidPred As ComputePredatorPreySystem
Private m_TopPred As ComputePredatorPreySystem
Private m_ApexPred As ComputePredatorPreySystem
Private m_Parasites As ComputePredatorPreySystem
Private m_Scavengers As ComputePredatorPreySystem
Private m_FPS_Swarm As FPSPredatorPreySwarm

Public Sub Initialize( _
    ByVal nutrient As ComputeBacterialColonySystem, _
    ByVal bacteria As ComputeBacterialColonySystem, _
    ByVal slime As ComputeSlimeMoldSystem, _
    ByVal midPred As ComputePredatorPreySystem, _
    ByVal topPred As ComputePredatorPreySystem, _
    ByVal apexPred As ComputePredatorPreySystem, _
    ByVal parasites As ComputePredatorPreySystem, _
    ByVal scavengers As ComputePredatorPreySystem, _
    ByVal fpsSwarm As FPSPredatorPreySwarm)
    
    Set m_Nutrient = nutrient
    Set m_Bacteria = bacteria
    Set m_Slime = slime
    Set m_MidPred = midPred
    Set m_TopPred = topPred
    Set m_ApexPred = apexPred
    Set m_Parasites = parasites
    Set m_Scavengers = scavengers
    Set m_FPS_Swarm = fpsSwarm
End Sub

Public Sub UpdateEcosystem(ByVal deltaTime As Single)
    m_Nutrient.ConsumptionRate = m_Morpho.ProductionRate * 2#
    m_Bacteria.GrowthRate = m_Nutrient.CurrentLevel * 1.3
    m_Slime.DiffuseRate = 0.8 + m_Turing.SpotRatio * 1.1
    m_MidPred.Aggression = 1# + m_Turing.Entropy * 1.6
    m_TopPred.Aggression = 1.4 + m_Turing.SpotRatio * 1.8
    m_ApexPred.Aggression = 1.8 + m_Turing.Entropy * 2.4
    m_Parasites.Aggression = 0.8 + m_Turing.SpotRatio * 2#
    m_Scavengers.DiffuseRate = 1.2 + m_Turing.Entropy * 1.5
    m_FPS_Swarm.GlobalDifficulty = m_Turing.Entropy + m_Turing.SpotRatio * 2.5
End Sub

Public Sub Shutdown()
    Set m_Nutrient = Nothing
    Set m_Bacteria = Nothing
    Set m_Slime = Nothing
    Set m_MidPred = Nothing
    Set m_TopPred = Nothing
    Set m_ApexPred = Nothing
    Set m_Parasites = Nothing
    Set m_Scavengers = Nothing
    Set m_FPS_Swarm = Nothing
End Sub

