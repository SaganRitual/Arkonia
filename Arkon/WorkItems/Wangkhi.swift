import SpriteKit

enum Wangkhi {
    static let brightColor = 0x00_FF_00    // Full green
    static let scaleFactor: CGFloat = 0.5
    static var spriteFactory: SpriteFactory!
    static let standardColor = 0x00_FF_00  // Slightly dim green
}

protocol WangkhiProtocol: class, Dispatchable {
    var birthday: Int { get set }
    var callAgain: Bool { get }
    var dispatch: Dispatch? { get set }
    var fishNumber: Int { get set }
    var gridCell: GridCell? { get set }
    var metabolism: Metabolism? { get set }
    var net: Net? { get }
    var netDisplay: NetDisplay? { get }
    var nose: SKSpriteNode? { get set }
    var parent: Stepper? { get set }
    var sprite: SKSpriteNode? { get set }
}

final class WangkhiEmbryo: WangkhiProtocol {
    let scratch: Scratchpad?
    var newScratch = Scratchpad()

    enum Phase {
        case getStartingPosition, registerBirth, buildGuts, buildSprites
    }

    var birthday = 0
    var callAgain = false
    var dispatch: Dispatch?
    var fishNumber = 0
    var gridCell: GridCell?
    var metabolism: Metabolism?
    var net: Net?
    var netDisplay: NetDisplay?
    var nose: SKSpriteNode?
    var parent: Stepper?
    var phase = Phase.getStartingPosition
    var sprite: SKSpriteNode?
    var tempStrongReference: Dispatch?
    var workItems = [DispatchWorkItem]()

    init(_ scratch: Scratchpad) {
        print("aWangkhiEmbryo init1")
        self.scratch = scratch
        self.parent = scratch.stepper
        self.tempStrongReference = scratch.dispatch
        print("aWangkhiEmbryo init2")

        workItems = [
            DispatchWorkItem(flags: .init(), block: getStartingPosition),
            DispatchWorkItem(flags: .init(), block: registerBirth),
            DispatchWorkItem(flags: .init(), block: buildGuts),
            DispatchWorkItem(flags: .init(), block: buildSprites)
        ]

        for ss in 1..<self.workItems.count {
            let finishedWorkItem = self.workItems[ss - 1]
            let newWorkItem = self.workItems[ss]

            finishedWorkItem.notify(queue: Grid.shared.concurrentQueue, execute: newWorkItem)
        }
    }

    deinit {
        print("fuck")
    }

    func launch() { Grid.shared.concurrentQueue.async(execute: workItems[0]) }
}

extension WangkhiEmbryo {
    private func getStartingPosition() {
        print("getStartingPosition")
        guard let parent = self.parent else {
            self.gridCell = GridCell.getRandomGridlet_()
            return
        }

        var foundGridlet: GridCell!
        var candidateIx = Int.random(in: 1..<ArkoniaCentral.cSenseGridlets)

        while foundGridlet == nil {
            let g = parent.gridCell.getGridPointByIndex(candidateIx)

            if let f = GridCell.atIf(g), f.contents == .nothing {
                foundGridlet = f
                break
            }

            candidateIx += 1
        }

        self.gridCell = foundGridlet
    }

    private func registerBirth() {
        print("registerBirth")
        World.stats.registerBirth_(myParent: nil, meOffspring: self)
    }
}

extension WangkhiEmbryo {
    func buildGuts() {
        print("buildGuts")
        metabolism = Metabolism()

        net = Net(
            parentBiases: parent?.parentBiases, parentWeights: parent?.parentWeights,
            layers: parent?.parentLayers, parentActivator: parent?.parentActivator
        )

        if let np = (sprite?.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode),
            let scene = np.parent as? SKScene {

            netDisplay = NetDisplay(
                scene: scene, background: np, layers: net!.layers
            )

            netDisplay!.display()
        }
    }

}

extension WangkhiEmbryo {

    func buildSprites() {
        print("buildSprites")
        let action = SKAction.run { [unowned self] in
            self.buildSprites_()
        }

        GriddleScene.arkonsPortal.run(action)
    }

    //swiftmint:disable function_body_length
    private func buildSprites_() {
        assert(Display.displayCycle == .actions)

        self.nose = Wangkhi.spriteFactory!.noseHangar.makeSprite()
        self.sprite = Wangkhi.spriteFactory!.arkonsHangar.makeSprite()

        guard let sprite = self.sprite else { fatalError() }
        guard let nose = self.nose else { fatalError() }
        guard let gridCell = self.gridCell else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 1

        sprite.setScale(Wangkhi.scaleFactor)
        sprite.color = ColorGradient.makeColor(hexRGB: 0xFF0000)
        sprite.colorBlendFactor = 1
        sprite.setScale(0.5)
        sprite.position = gridCell.scenePosition
        sprite.alpha = 1

        sprite.addChild(nose)

        gridCell.sprite = sprite
        gridCell.contents = .arkon
        scratch?.gridCell = gridCell

//        print("bbefore",
//              dispatch?.name.prefix(8) ?? "wtf4∫",
//              dispatch?.stepper?.name.prefix(8) ?? "wtf14å",
//              dispatch?.stepper?.parentStepper?.name ?? "no parent4 ",
//              dispatch?.stepper?.parentStepper?.dispatch?.name ?? "no parent4a ",
//              self.dispatch?.name.prefix(8) ?? "wtf4a",
//              self.dispatch?.stepper?.name.prefix(8) ?? "wtf4b; ")

        let newborn: Stepper = Stepper(self, needsNewDispatch: true)
        newborn.parentStepper = self.parent

//        print("bbefore2",
//              dispatch?.name.prefix(8) ?? "wtf5∫",
//              dispatch?.stepper?.name.prefix(8) ?? "wtf15å",
//              dispatch?.stepper?.parentStepper?.name ?? "no parent5 ",
//              dispatch?.stepper?.parentStepper?.dispatch?.name ?? "no parent5a ",
//              self.dispatch?.name.prefix(8) ?? "wtf4a",
//              self.dispatch?.stepper?.name.prefix(8) ?? "wtf5b; ",

//              newborn.name.prefix(8),
//              newborn.parentStepper?.name ?? "no parent7 ",
//              newborn.parentStepper?.dispatch?.name ?? "no parent7a ")

        Stepper.attachStepper(newborn, to: sprite)
//        newborn.dispatch!.tempStrongReference = nil
        self.tempStrongReference = nil

//        print("bbefore3",
//              dispatch?.name.prefix(8) ?? "wtf6∫",
//              dispatch?.stepper?.name.prefix(8) ?? "wtf146",
//              dispatch?.stepper?.parentStepper?.name ?? "no parent6 ",
//              dispatch?.stepper?.parentStepper?.dispatch?.name ?? "no parent6a ",
//              self.dispatch?.name.prefix(8) ?? "wtf6a",
//              self.dispatch?.stepper?.name.prefix(8) ?? "wtf6b; ",
//
//              newborn.name.prefix(8),
//              newborn.parentStepper?.name ?? "no parent8 ",
//              newborn.parentStepper?.dispatch?.name ?? "no parent8a ")

        GriddleScene.arkonsPortal!.addChild(sprite)

        print("birth0")
        if let dp = dispatch, let st = scratch?.stepper {
            print("parent0")

            let spawnCost = st.getSpawnCost()
            st.metabolism.withdrawFromSpawn(spawnCost)

            dp.go()
            print("parent1")
        }

        print("birth1")

        scratch?.gridCell = newborn.gridCell
        scratch?.stepper = newborn
        newborn.dispatch!.go()

        print("child")
    }
    //swiftmint:enable function_body_length
}
