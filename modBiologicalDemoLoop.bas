' ============================================================
' Module: modBiologicalDemoLoop.bas
' Version : BIOLOGICAL v1.2 - 2026-04-15
' Simple example loop – runs ALL four biological demos live
' ============================================================

Option Explicit

Private lvSystem As ComputeSpatialLotkaVolterra
Private LVVis As LotkaVolterraVisualizer

Private SlimeSystem As ComputeSlimeMoldSystem
Private SlimeVis As SlimeMoldVisualizer

Private BacteriaSystem As ComputeBacterialColonySystem
Private BacteriaVis As BacterialColonyVisualizer

Private FitzSystem As ComputeFitzHughNagumoSystem
Private FitzVis As FitzHughNagumoVisualizer

Private antSystem As ComputeAntColonySystem
Private AntVis As AntColonyVisualizer

Private LastTime As Single

Public Sub StartBiologicalDemos()
    Dim Size As Long
    Size = 256
    
    ' Initialize systems
    Set lvSystem = New ComputeSpatialLotkaVolterra
    lvSystem.Initialize Size, Size
    Set LVVis = New LotkaVolterraVisualizer
    LVVis.Initialize Size, Size
    
    Set SlimeSystem = New ComputeSlimeMoldSystem
    SlimeSystem.Initialize Size, Size
    Set SlimeVis = New SlimeMoldVisualizer
    SlimeVis.Initialize Size, Size
    
    Set BacteriaSystem = New ComputeBacterialColonySystem
    BacteriaSystem.Initialize Size, Size
    Set BacteriaVis = New BacterialColonyVisualizer
    BacteriaVis.Initialize Size, Size
    
    Set FitzSystem = New ComputeFitzHughNagumoSystem
    FitzSystem.Initialize Size, Size
    Set FitzVis = New FitzHughNagumoVisualizer
    FitzVis.Initialize Size, Size
    
    Set antSystem = New ComputeAntColonySystem
    antSystem.Initialize Size, Size
    Set AntVis = New AntColonyVisualizer
    AntVis.Initialize Size, Size
    
    LastTime = Timer()
    Debug.Print "All biological demos started – press any key to stop"
End Sub

Public Sub UpdateBiologicalDemos()
    Dim now As Single, delta As Single
    now = Timer()
    delta = now - LastTime
    LastTime = now
    
    ' Update all simulations
    lvSystem.Update delta
    SlimeSystem.Update delta
    BacteriaSystem.Update delta
    FitzSystem.Update delta
    antSystem.Update delta
    
    ' Render (you can position them anywhere on screen)
    LVVis.UpdateTexture lvSystem.GetCurrentGridSSBO()
    LVVis.Render()
    
    ' For side-by-side: use glViewport to place each in its own quadrant
    ' Example (top-left slime, top-right bacteria, etc.)
    ' GL.glViewport 0, 450, 400, 400: SlimeVis.UpdateTexture SlimeSystem.GetCurrentTrailSSBO(): SlimeVis.Render()
    ' (repeat for others)
End Sub

Public Sub StopBiologicalDemos()
    lvSystem.Shutdown
    SlimeSystem.Shutdown
    BacteriaSystem.Shutdown
    FitzSystem.Shutdown
    antSystem.Shutdown
    
    LVVis.Shutdown
    SlimeVis.Shutdown
    BacteriaVis.Shutdown
    FitzVis.Shutdown
    AntVis.Shutdown
    
    Debug.Print "All biological demos stopped"
End Sub
