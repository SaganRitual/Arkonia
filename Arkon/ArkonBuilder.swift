import SpriteKit

struct ArkonBuilder {
    let embryo: ArkonEmbryo

    func buildGuts(_ onComplete: @escaping () -> Void) {
        let nn = embryo.parentArkon?.net

        Debug.log(level: 205) { "buildGuts" }

        Net.makeNet(embryo.netStructure!, nn?.pBiases, nn?.pWeights) { newNet in
            let em = self.embryo
            let ns = em.netStructure!

            let spindleState: Spindle.State = em.spindleTargetIsPreLocked ?
                .inBirthCellWithLockFromParent : .inBirthLimboAwaitingTargetCellReady

            em.spindle = .init(at: em.spindleTarget!, initialState: spindleState)
            em.sensorPad = SensorPad(name: em.fishday!.name, em.spindle!, ns.sensorPadCCells)
            em.metabolism = Metabolism(cNeurons: ns.cNeurons)
            em.net = newNet

            onComplete()
        }
    }

    func buildSprites(_ onComplete: @escaping () -> Void) {
        hardAssert(Display.displayCycle == .updateStarted) { "hardAssert at \(#file):\(#line)" }

        embryo.toothSprite =  SpriteFactory.shared.teethPool.makeSprite()
        embryo.noseSprite =   SpriteFactory.shared.nosesPool.makeSprite()
        embryo.thoraxSprite = SpriteFactory.shared.arkonsPool.makeSprite()

        embryo.toothSprite!.alpha = 1
        embryo.toothSprite!.color = .red
        embryo.toothSprite!.zPosition = 4
        embryo.toothSprite!.colorBlendFactor = 1

        embryo.noseSprite!.addChild(embryo.toothSprite!)
        embryo.noseSprite!.setScale(Arkonia.noseScaleFactor)
        embryo.noseSprite!.alpha = 1
        embryo.noseSprite!.color = .blue
        embryo.noseSprite!.zPosition = 3
        embryo.noseSprite!.colorBlendFactor = 1

        // We don't set the arkon's main sprite position here; we set it later,
        // after we have a sensor pad and stuff set up
        embryo.thoraxSprite!.position = embryo.spindleTarget!.properties.scenePosition
        embryo.thoraxSprite!.addChild(embryo.noseSprite!)
        embryo.thoraxSprite!.setScale(Arkonia.arkonScaleFactor * 1.0 / Arkonia.zoomFactor)
        embryo.thoraxSprite!.alpha = 1
        embryo.thoraxSprite!.zPosition = 2
        embryo.thoraxSprite!.colorBlendFactor = 0.5

        let noseColor: SKColor = (embryo.parentArkon == nil) ? .systemBlue : .yellow
        Debug.debugColor(embryo.thoraxSprite!, .blue, embryo.noseSprite!, noseColor)
        onComplete()
    }

    func setupNetDisplay(_ onComplete: @escaping () -> Void) {
        // If the drone has a NetDisplay object attached, set it up to draw
        // our layer structure on the hud
        guard let ud = embryo.thoraxSprite!.userData,
              let np = (ud[SpriteUserDataKey.net9Portal] as? SKSpriteNode),
              let hp = (ud[SpriteUserDataKey.netHalfNeuronsPortal] as? SKSpriteNode)
            else { onComplete(); return }

        embryo.netDisplay = NetDisplay(
            arkon: embryo.thoraxSprite!,
            fullNeuronsPortal: np, halfNeuronsPortal: hp,
            layerDescriptors: embryo.net!.netStructure.layerDescriptors
        )

        embryo.netDisplay!.display()
        onComplete()
    }
}
