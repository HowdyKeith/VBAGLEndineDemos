' ============================================================
' Module: modMultiBioDemoLoop.bas
' Version : BIOLOGICAL v2.60 - 2026-04-15
' Main render loop for the full biological FPS demo with 9-species ecosystem
' ============================================================

Option Explicit

Private Const WINDOW_WIDTH As Long = 1200
Private Const WINDOW_HEIGHT As Long = 800

Private lvSystem As ComputeSpatialLotkaVolterra
Private SlimeSystem As ComputeSlimeMoldSystem
Private BacteriaSystem As ComputeBacterialColonySystem
Private FitzSystem As ComputeFitzHughNagumoSystem
Private antSystem As ComputeAntColonySystem
Private MorphoSystem As ComputeMorphogenesisSystem
Private RDSystem As ComputeReactionDiffusionSystem

Private EnemySwarm As FPSPredatorPreySwarm
Private WeaponHealth As FPSWeaponHealthSystem
Private WeaponTrails As WeaponTrailSystem
Private ExplosionVFX As ExplosionVFXSystem
Private ParticleSys As ParticleSystem
Private FullEcosystem9 As FullEcosystem9Species
Private WeatherSys As WeatherSystem

Private MainCamera As GLCamera
Private OnScreenMenu As OnScreenMenuRenderer

Private LastTime As Single

Public Sub StartFullBioFPSDemo()
    EnsureSheetsExist
    
    Dim Size As Long: Size = 256
    
    Set lvSystem = New ComputeSpatialLotkaVolterra: lvSystem.Initialize Size, Size
    Set SlimeSystem = New ComputeSlimeMoldSystem: SlimeSystem.Initialize Size, Size
    Set BacteriaSystem = New ComputeBacterialColonySystem: BacteriaSystem.Initialize Size, Size
    Set FitzSystem = New ComputeFitzHughNagumoSystem: FitzSystem.Initialize Size, Size
    Set antSystem = New ComputeAntColonySystem: antSystem.Initialize Size, Size
    Set MorphoSystem = New ComputeMorphogenesisSystem: MorphoSystem.Initialize Size, Size
    Set RDSystem = New ComputeReactionDiffusionSystem: RDSystem.Initialize Size, Size
    
    Set MainCamera = New GLCamera: MainCamera.Initialize
    Set EnemySwarm = New FPSPredatorPreySwarm
    EnemySwarm.Initialize MainCamera, antSystem, lvSystem
    
    Set WeaponHealth = New FPSWeaponHealthSystem: WeaponHealth.Initialize
    Set WeaponTrails = New WeaponTrailSystem: WeaponTrails.Initialize MorphoSystem, turingAnalyzer
    Set ExplosionVFX = New ExplosionVFXSystem: ExplosionVFX.Initialize MorphoSystem, turingAnalyzer, MainCamera
    Set ParticleSys = New ParticleSystem: ParticleSys.Initialize MorphoSystem, turingAnalyzer
    
    Set FullEcosystem9 = New FullEcosystem9Species
    FullEcosystem9.Initialize NutrientSystem, BacteriaSystem, SlimeSystem, MidPredSystem, TopPredSystem, ApexPredSystem, ParasiteSystem, ScavengerSystem, EnemySwarm
    
    Set WeatherSys = New WeatherSystem
    WeatherSys.Initialize MorphoSystem, turingAnalyzer, FullEcosystem9
    
    Set OnScreenMenu = New OnScreenMenuRenderer: OnScreenMenu.Initialize
    
    LastTime = Timer()
    Debug.Print "=== FULL 9-SPECIES BIOLOGICAL FPS DEMO INITIALIZED (v2.60) ==="
End Sub

Public Sub UpdateFullBioFPSDemo()
    Dim delta As Single
    delta = Timer() - LastTime
    LastTime = Timer()
    
    ReadLiveSheetParameters
    WeaponHealth.Update
    HandleAllDemoMenu
    
    MorphoSystem.Update delta
    turingAnalyzer.Update
    FullEcosystem9.UpdateEcosystem delta
    WeatherSys.UpdateWeather delta
    
    If GetAsyncKeyState(vbKeySpace) Then WeaponTrails.FireTrail MainCamera.Position
    WeaponTrails.Update delta
    ExplosionVFX.Update delta
    ParticleSys.Update delta
    
    GL.glClear GL.GL_COLOR_BUFFER_BIT Or GL.GL_DEPTH_BUFFER_BIT
    
    ' 6 biological viewports (adjust as needed)
    ' ...
    
    ' 7TH VIEWPORT – FPS with refraction + HUD + trails with bloom
    GL.glViewport cellW * 3, 0, cellW, cellH
    FPSPost.CaptureFPSScene
    EnemySwarm.RenderScene MainCamera
    WeaponTrails.RenderWithBloom
    ExplosionVFX.Render
    ParticleSys.Render
    FPSPost.ApplyRefraction
    HUD.Render WeaponHealth.health, WeaponHealth.ammo, WeaponHealth.maxAmmo
    
    OnScreenMenu.Render
End Sub

Public Sub StopFullBioFPSDemo()
    FullEcosystem9.Shutdown
    WeaponTrails.Shutdown
    ExplosionVFX.Shutdown
    ParticleSys.Shutdown
    OnScreenMenu.Shutdown
    Debug.Print "=== FULL BIOLOGICAL FPS DEMO STOPPED ==="
End Sub
