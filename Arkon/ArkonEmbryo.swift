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

    func buildSprites() {
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
    }

    func getBirthingCell() -> IngridCellDescriptor {
        parentArkon?.detachBirthingCellForNewborn() ?? sensorPad.detachLandingPad()
    }

    func placeNewbornOnGrid(_ newborn: Stepper) {
        thoraxSprite!.position = birthingCell.coreCell!.scenePosition

        Ingrid.shared.placeArkonOnGrid(newborn, atIndex: birthingCell.absoluteIndex)
    }
}
