' ============================================================
' Class Module: FullEcosystem5Species.cls
' Version : BIOLOGICAL v2.0 - 2026-04-15
' Complete 5-species ecosystem: Nutrient ? Bacteria ? Slime ? Mid-Predators ? Top Predators
' All interact with live morphogenesis pattern
' ============================================================

Option Explicit

Private m_Nutrient As ComputeBacterialColonySystem   ' base layer
Private m_Bacteria As ComputeBacterialColonySystem
Private m_Slime As ComputeSlimeMoldSystem
Private m_MidPredators As ComputePredatorPreySystem
Private m_TopPredators As FPSPredatorPreySwarm      ' your FPS enemy swarm

Public Sub Initialize(ByVal nutrient As ComputeBacterialColonySystem, _
                      ByVal bacteria As ComputeBacterialColonySystem, _
                      ByVal slime As ComputeSlimeMoldSystem, _
                      ByVal midPred As ComputePredatorPreySystem, _
                      ByVal topPred As FPSPredatorPreySwarm)
    Set m_Nutrient = nutrient
    Set m_Bacteria = bacteria
    Set m_Slime = slime
    Set m_MidPredators = midPred
    Set m_TopPredators = topPred
End Sub

Public Sub UpdateEcosystem(ByVal deltaTime As Single)
    ' Nutrient diffuses into morphogenesis activator
    m_Nutrient.ConsumptionRate = m_Morpho.ProductionRate * 1.5
    
    ' Bacteria eat nutrient and feed slime
    m_Bacteria.GrowthRate = m_Nutrient.CurrentLevel * 0.9
    
    ' Slime follows bacteria and is eaten by mid-predators
    m_Slime.DiffuseRate = 0.6 + m_Turing.SpotRatio * 0.7
    
    ' Mid-predators chase slime and are hunted by top predators
    m_MidPredators.Aggression = 1# + m_Turing.Entropy * 1.3
    
    ' Top predators (FPS enemies) get stronger with overall ecosystem complexity
    m_TopPredators.Aggression = 1.2 + (m_Turing.Entropy + m_Turing.SpotRatio) * 1.8
End Sub

Public Sub Shutdown()
    ' references only – systems are cleaned up elsewhere
End Sub

