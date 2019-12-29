import SpriteKit

protocol SpawnProtocol: class, DispatchableProtocol {
    var callAgain: Bool { get }
    var dispatch: Dispatch? { get set }
    var engagerKey: HotKey? { get set }
    var fishDay: Fishday { get set }
    var metabolism: Metabolism? { get set }
    var net: Net? { get }
    var netDisplay: NetDisplay? { get }
    var nose: SKSpriteNode? { get set }
    var meTheParent: Stepper? { get set }
    var thorax: SKSpriteNode? { get set }
}

enum Names {
    static var nameix = 0
    static var setix = 0

    static var names = [
        "Alice-", "Bob-", "Charles-",
        "David-", "Ellen-", "Felicity-",
        "Grace-", "Helen-", "India-",
        "James-", "Karen-", "Lizbeth-",
        "Mary-", "Nathan-", "Olivia-",
        "Paul-", "Quincy-", "Rob-",
        "Samantha-", "Tatiana-", "Ulna-",
        "Vivian-", "William-", "Xavier-",
        "Yvonne-", "Zoe-"
    ]

    static func getName() -> String {
        defer {
            nameix = (nameix + 1) % names.count
            if nameix == 0 { setix += 1 }
        }

        let newName = names[nameix % names.count] + String(format: "%03d-Arkon", setix)
        return newName
    }
}

final class Spawn: DispatchableProtocol, SpawnProtocol {
    var dispatch: Dispatch? { willSet { fatalError() } }

    weak var scratch: Scratchpad?

    var callAgain = false
    var engagerKey: HotKey?
    let embryoName = Names.getName()
    var fishDay = Fishday(fishNumber: 0, birthday: 0)
    var metabolism: Metabolism?
    var net: Net?
    var netDisplay: NetDisplay?
    weak var newborn: Stepper?
    var nose: SKSpriteNode?
    weak var meTheParent: Stepper?
    var thorax: SKSpriteNode?
    var tempStrongReference: Spawn?

    static let dispatchQueue = DispatchQueue(
        label: "ak.spawn.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .default)
    )

    init(_ scratch: Scratchpad) {
        Log.L.write("init1 \(scratch.name)", level: 71)
        self.scratch = scratch
        self.meTheParent = scratch.stepper
        self.tempStrongReference = self
    }

    func launch() {
        let nameCopy = embryoName
        Log.L.write("launch1 \(nameCopy)", level: 71)
        Census.shared.registerBirth(myName: embryoName, myParent: self.meTheParent) {
            self.fishDay = $0

            Grid.shared.serialQueue.async {
                Log.L.write("launch2 \(nameCopy)", level: 71)
                self.launch_()
                Log.L.write("launch3 \(nameCopy)", level: 71)
            }
            Log.L.write("launch4 \(nameCopy)", level: 71)
        }
        Log.L.write("launch5 \(nameCopy)", level: 71)
    }

    func launch_() {
        getStartingPosition(self.embryoName) {
            self.engagerKey = $0
            Grid.shared.serialQueue.async { self.launch2_() }
        }
    }

    func launch2_() {
        buildSprites()
    }
}

extension Spawn {
    enum Constants {
        static let brightColor = 0x00_FF_00    // Full green
        static let standardColor = 0x00_FF_00  // Slightly dim green
    }
}

typealias OnComplete0p = () -> Void
typealias OnComplete1p = (HotKey?) -> Void

extension Spawn {
    private func getStartingPosition(_ embryoName: String, _ onComplete: @escaping OnComplete1p) {
        guard let parent = self.meTheParent else {
            GridCell.lockRandomEmptyCell(
                ownerName: "aboriginal-\(fishDay.fishNumber)", onComplete
            )
            return
        }

        let key = GridCell.lockBirthPosition(parent: parent, name: embryoName)
        onComplete(key)
    }
}

extension Spawn {
    func buildGuts() {
        metabolism = Metabolism()

        net = Net(
            parentBiases: meTheParent?.parentBiases, parentWeights: meTheParent?.parentWeights,
            layers: meTheParent?.parentLayers, parentActivator: meTheParent?.parentActivator
        )

        guard let sprite = self.thorax else { fatalError() }
        buildNetDisplay(sprite)

        self.launchNewborn()
    }

}

extension Spawn {

    func buildNetDisplay(_ sprite: SKSpriteNode) {
        guard let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode)
            else { return }

        guard let scene = np.parent as? SKScene else { return }

        netDisplay = NetDisplay(scene: scene, background: np, layers: net!.layers)
        netDisplay!.display()
    }
}

extension Spawn {

    func abandonNewborn() {
        guard let st = meTheParent, let dp = st.dispatch, let sprite = st.sprite
            else { return }

        let rotate = SKAction.rotate(byAngle: 4 * 2 * CGFloat.pi, duration: 2.0)
        sprite.run(rotate)

        let spawnCost = st.getSpawnCost()
        st.metabolism.withdrawFromSpawn(spawnCost)

        dp.metabolize()
    }

    func buildSprites() {
        let action = SKAction.run { [unowned self] in
            self.buildSprites_()
            self.thorax!.addChild(self.nose!)
            self.buildGuts()
        }

        GriddleScene.shared.run(action)
    }

    private func buildSprites_() {
        assert(Display.displayCycle == .actions)

        Log.L.write("buildSprites_", level: 71)
        self.nose = SpriteFactory.shared.noseHangar.makeSprite()
        self.thorax = SpriteFactory.shared.arkonsHangar.makeSprite()

        guard let thorax = self.thorax else { fatalError() }
        guard let nose = self.nose else { fatalError() }
        guard let engagerKey = self.engagerKey else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 1
        nose.setScale(0.75)
        nose.name = embryoName

        thorax.setScale(Arkonia.spriteScale)
        thorax.colorBlendFactor = 1
        thorax.position = engagerKey.scenePosition
        thorax.alpha = 1
        thorax.name = embryoName

        let noseColor: SKColor = (meTheParent == nil) ? .magenta : .yellow
        Debug.debugColor(thorax, .green, nose, noseColor)
    }

    func launchNewborn() {
        guard let thorax = self.thorax else { fatalError() }

        let newborn = Stepper(self, needsNewDispatch: true)
        newborn.parentStepper = self.meTheParent
        newborn.dispatch.scratch.stepper = newborn
        newborn.sprite?.color = .yellow
        newborn.nose?.color = .white

        guard let ek = engagerKey else { fatalError() }

        ek.contents = .arkon
        ek.sprite = thorax
        ek.sprite?.name = newborn.name
        ek.ownerName = newborn.name

        Stepper.attachStepper(newborn, to: thorax)

        abandonNewborn()

        guard let ndp = newborn.dispatch else { fatalError() }

        ndp.scratch.engagerKey = ek

        // The newborn now has a strong ref to the dispatch, so we can let
        // it go now
        precondition(ndp.scratch.stepper != nil)
        self.tempStrongReference = nil
        precondition(ndp.scratch.stepper != nil)
        Log.L.write("ndp.disengage1 \(self.embryoName)/\(ndp.name)", level: 71)

        guard let ap = GriddleScene.arkonsPortal else { fatalError() }
        ap.run(SKAction.run {
            ap.addChild(thorax)
            let rotate = SKAction.rotate(byAngle: -4 * 2 * CGFloat.pi, duration: 2.0)
            thorax.run(rotate)
        }) {
            ndp.disengage()
            Log.L.write("ndp.disengage2 \(self.embryoName)/\(ndp.name)", level: 71)
        }
    }
}
