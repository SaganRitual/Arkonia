import SpriteKit

class ArkonEmbryo {
    var name: ArkonName?
    var fishDay = Fishday(birthday: 0, cNeurons: 0, fishNumber: 0)
    var metabolism: Metabolism?
    var net: Net?
    var netDisplay: NetDisplay?
    var newborn: Stepper?
    var noseSprite: SKSpriteNode?
    let parentArkon: Stepper?
    var sensorPad: SensorPad?
    var thoraxSprite: SKSpriteNode?
    var toothSprite: SKSpriteNode?

    init(_ parentArkon: Stepper?) {
        self.parentArkon = parentArkon

        if parentArkon != nil { self.sensorPad = nil; return }
    }

    func buildSprites(_ onComplete: @escaping () -> Void) {
        hardAssert(Display.displayCycle == .updateStarted) { "hardAssert at \(#file):\(#line)" }

        toothSprite = SpriteFactory.shared.teethPool.makeSprite(name)
        noseSprite = SpriteFactory.shared.nosesPool.makeSprite(name)
        thoraxSprite = SpriteFactory.shared.arkonsPool.makeSprite(name)

        toothSprite!.alpha = 1
        toothSprite!.colorBlendFactor = 1
        toothSprite!.color = .red
        toothSprite!.zPosition = 4

        noseSprite!.addChild(toothSprite!)
        noseSprite!.alpha = 1
        noseSprite!.colorBlendFactor = 1
        noseSprite!.color = .blue
        noseSprite!.setScale(Arkonia.noseScaleFactor)
        noseSprite!.zPosition = 3

        // We don't set the arkon's main sprite position here; we set it later,
        // after we have a sensor pad and stuff set up
        thoraxSprite!.addChild(noseSprite!)
        thoraxSprite!.setScale(Arkonia.arkonScaleFactor * 1.0 / Arkonia.zoomFactor)
        thoraxSprite!.colorBlendFactor = 0.5
        thoraxSprite!.alpha = 1
        thoraxSprite!.zPosition = 2

        let noseColor: SKColor = (parentArkon == nil) ? .systemBlue : .yellow
        Debug.debugColor(thoraxSprite!, .blue, noseSprite!, noseColor)

        MainDispatchQueue.async(execute: onComplete)
    }

    func buildGuts(_ onComplete: @escaping (Net) -> Void) {
        let nn = parentArkon?.net

        Net.makeNet(nn?.netStructure, nn?.pBiases, nn?.pWeights) { newNet in
            self.sensorPad = .makeSensorPad(newNet.netStructure.sensorPadCCells)
            self.metabolism = Metabolism(cNeurons: newNet.netStructure.cNeurons)
            onComplete(newNet)
        }
    }

    func getBirthingCell() -> IngridCellDescriptor {
        let cell: IngridCellDescriptor

        if let p = parentArkon { cell = p.detachBirthingCellForNewborn() }
        else                   { cell = Ingrid.randomCell() }

        return cell
    }

    func placeNewbornOnGrid(_ newborn: Stepper) {
        let bc = getBirthingCell()

        thoraxSprite!.position = bc.coreCell!.scenePosition

        Ingrid.shared.placeArkonOnGrid(newborn, atIndex: bc.absoluteIndex)
    }

    func registerBirth() {
        name = ArkonName.makeName()
        fishDay = Census.shared.registerBirth(name!, parentArkon, net!)
    }
}

extension ArkonEmbryo {
    func launch() { MainDispatchQueue.async(execute: launchNewborn_B) }

    private func launchNewborn_B() {
        let newborn = Stepper(self)

        placeNewbornOnGrid(newborn)

        SceneDispatch.shared.schedule { self.launchNewborn_C(newborn) }
    }

    private func launchNewborn_C(_ newborn: Stepper) {
        SpriteFactory.shared.arkonsPool.attachSprite(newborn.thorax)

        let rotate = SKAction.rotate(byAngle: -2 * CGFloat.tau, duration: 0.5)
        newborn.thorax.run(rotate)

        // Newborn goes onto its own dispatch here
        sensorPad!.disengageGrid(newborn.dispatch!.engageGrid)
    }
}
