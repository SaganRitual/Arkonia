import SpriteKit

class ArkonEmbryo {
    var birthingCell: GridCellConnector?
    var fishDay = Fishday(birthday: 0, cNeurons: 0, fishNumber: 0)
    var metabolism: Metabolism?
    var name: ArkonName?
    var net: Net?
    var netDisplay: NetDisplay?
    var newborn: Stepper?
    var noseSprite: SKSpriteNode?
    let parentArkon: Stepper?
    var sensorPad: SensorPad?
    var thoraxSprite: SKSpriteNode?
    var toothSprite: SKSpriteNode?

    init(_ parentArkon: Stepper?) {
        Debug.log(level: 204) { "ArkonEmbryo" }
        self.parentArkon = parentArkon

        if parentArkon != nil { self.sensorPad = nil; return }
    }

    deinit {
        print("here")
    }
}

extension ArkonEmbryo {
    func buildSprites() {
        hardAssert(Display.displayCycle == .updateStarted) { "hardAssert at \(#file):\(#line)" }

        toothSprite = SpriteFactory.shared.teethPool.makeSprite()
        noseSprite = SpriteFactory.shared.nosesPool.makeSprite()
        thoraxSprite = SpriteFactory.shared.arkonsPool.makeSprite()

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

    func buildGuts(_ onComplete: @escaping () -> Void) {
        let nn = parentArkon?.net

        Net.makeNet(nn?.netStructure, nn?.pBiases, nn?.pWeights) { newNet in
            let ns = newNet.netStructure
            self.sensorPad = .makeSensorPad(ns.sensorPadCCells)
            self.metabolism = Metabolism(cNeurons: ns.cNeurons)
            self.net = newNet
            onComplete()
        }
    }

    func detachFromParent(_ birthingCell: GridCellConnector) {
        self.birthingCell = birthingCell

        if birthingCell.coreCell == nil {
            // We have a random cell from on high; we need to lock it
            // before we can inhabit it. We will also come here if the parent
            // arkon couldn't find a suitable landing place for the newborn
            sensorPad!.engageBirthCell(center: birthingCell.absoluteIndex, launchNewborn)
            Grid.shared.sprites.showLock(birthingCell.absoluteIndex, .reservedForMiracleBirth)
        } else {
            // The parent arkon has chosen a cell for us from among her locked
            // sensor pad cells. We don't need to do anything else, just start
            // eating
            launchNewborn()
            Grid.shared.sprites.showLock(birthingCell.absoluteIndex, .reservedForOffspring)
        }
    }

    func placeNewbornOnGrid(_ newborn: Stepper) {
        let bc = Grid.shared.cellAt(newborn.gridCellAbsoluteIndex)

        thoraxSprite!.position = bc.scenePosition

        Grid.shared.placeArkonOnGrid(newborn, atIndex: bc.absoluteIndex)
    }

    func registerBirth() {
        name = ArkonName.makeName()
        fishDay = Census.shared.registerBirth(name!, parentArkon, net!)
    }
}

extension ArkonEmbryo {
    func launchNewborn() {
        Debug.log(level: 205) { "launchNewborn \(name!)" }
        MainDispatchQueue.async(execute: launchNewborn_B)
    }

    private func launchNewborn_B() {
        Debug.log(level: 205) { "launchNewborn_B \(name!)" }
        self.newborn = Stepper(self)

        placeNewbornOnGrid(newborn!)

        SceneDispatch.shared.schedule(self.launchNewborn_C)
    }

    private func launchNewborn_C() {
        Debug.log(level: 205) {
            "launchNewborn_C, real stepper now \(self.newborn!.name)"
            + " at \(self.newborn!.gridCellAbsoluteIndex)"
        }

        SpriteFactory.shared.arkonsPool.attachSprite(newborn!.thorax)

        let rotate = SKAction.rotate(byAngle: -2 * CGFloat.tau, duration: 0.5)
        newborn!.thorax.run(rotate, completion: self.launchNewborn_D)
    }

    private func launchNewborn_D() {
        Debug.log(level: 205) { "launchNewborn_D \(self.newborn!.name)" }
        sensorPad!.firstFullGridEngage(
            center: newborn!.gridCellAbsoluteIndex
        ) {
            Debug.log(level: 205) { "launchNewborn_E \(self.newborn!.name)" }
            self.newborn!.dispatch.tickLife()
        }
    }
}
