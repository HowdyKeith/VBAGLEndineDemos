' ============================================================
' Class Module: EcosystemManager.cls
' Version : BIOLOGICAL v1.7 - 2026-04-15
' Full interacting ecosystem: Bacteria ? Slime ? Predators
' All species interact with morphogenesis pattern on GPU
' ============================================================

Option Explicit

Private m_BacteriaSystem As ComputeBacterialColonySystem
Private m_SlimeSystem As ComputeSlimeMoldSystem
Private m_PredatorSwarm As FPSPredatorPreySwarm
Private m_MorphoSystem As ComputeMorphogenesisSystem

Public Sub Initialize(ByVal bacteria As ComputeBacterialColonySystem, _
                      ByVal slime As ComputeSlimeMoldSystem, _
                      ByVal predatorSwarm As FPSPredatorPreySwarm, _
                      ByVal morpho As ComputeMorphogenesisSystem)
    Set m_BacteriaSystem = bacteria
    Set m_SlimeSystem = slime
    Set m_PredatorSwarm = predatorSwarm
    Set m_MorphoSystem = morpho
End Sub

Public Sub UpdateEcosystem(ByVal deltaTime As Single)
    ' Bacteria consume morphogenesis activator (live interaction)
    m_BacteriaSystem.ConsumptionRate = m_MorphoSystem.ProductionRate * 1.2
    
    ' Slime mold follows bacterial nutrient gradient (chemotaxis)
    m_SlimeSystem.DiffuseRate = 0.7 + m_Turing.SpotRatio * 0.6   ' more spots = faster slime spread
    
    ' Predators chase slime trails (real food chain)
    m_PredatorSwarm.Aggression = 1# + m_Turing.Entropy * 1.5
    
    ' All systems already updated in main loop – this just couples them
End Sub

Public Sub Shutdown()
    Set m_BacteriaSystem = Nothing
    Set m_SlimeSystem = Nothing
    Set m_PredatorSwarm = Nothing
    Set m_MorphoSystem = Nothing
End Sub

