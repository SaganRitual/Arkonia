//swiftlint:disable function_body_length
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

        return names[nameix % names.count] + String(format: "%03d-Arkon", setix)
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
    var wiLaunch: DispatchWorkItem?
    var wiLaunch2: DispatchWorkItem?

    static let dispatchQueue = DispatchQueue(
        label: "ak.spawn.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .utility)
    )

    init(_ scratch: Scratchpad) {
        Log.L.write("Larva", level: 15)
        self.scratch = scratch
        self.meTheParent = scratch.stepper
        self.tempStrongReference = self

        // Weak refs here, because apparently the work items capture self
        // even if you reference them with DispatchWorkItem(block: launch_)
        self.wiLaunch = DispatchWorkItem { [weak self] in self?.launch_() }
        self.wiLaunch2 = DispatchWorkItem { [weak self] in self?.launch2_() }
    }

    deinit {
        Log.L.write("~Larva \(six(embryoName))", level: 51)
    }

    func launch() {
        Census.shared.registerBirth(myName: embryoName, myParent: self.meTheParent) {
            self.fishDay = $0

            guard let w = self.wiLaunch else { fatalError() }
            Grid.shared.serialQueue.async(execute: w)
        }
    }

    func launch_() {
        getStartingPosition(self.embryoName)

        guard let w2 = self.wiLaunch2 else { fatalError() }
        Grid.shared.serialQueue.async(execute: w2)
    }

    func launch2_() { buildSprites() }
}

extension Spawn {
    enum Constants {
        static let brightColor = 0x00_FF_00    // Full green
        static let standardColor = 0x00_FF_00  // Slightly dim green
    }
}

typealias OnComplete0p = () -> Void

extension Spawn {
    private func getStartingPosition(_ embryoName: String) {
        if self.meTheParent?.name != nil {
            precondition(self.meTheParent?.name != embryoName)
            precondition(self.meTheParent?.sprite?.getStepper(require: false)?.name != nil)
            precondition(self.meTheParent?.sprite?.getStepper(require: false)?.name == self.meTheParent?.name)
            precondition(self.meTheParent?.name == self.meTheParent?.dispatch?.name)
            precondition(self.meTheParent?.name == self.meTheParent?.dispatch?.scratch.name)
        }

        guard let parent = self.meTheParent else {
            engagerKey = GridCell.lockRandomEmptyCell(ownerName: "aboriginal-\(fishDay.fishNumber)")
            Log.L.write("Larva engagerKey random empty cell at \(engagerKey?.gridPosition ?? AKPoint(x: -4242, y: -4242))", level: 52)
            return
        }

        engagerKey = GridCell.lockBirthPosition(parent: parent, name: embryoName)
        debug2 = engagerKey!.ownerName
        Log.L.write("Larva from \(six(parent.name)) engagerKey lock birth position at \(engagerKey?.gridPosition ?? AKPoint(x: -4242, y: -4242))", level: 52)
    }
}

extension Spawn {
    func buildGuts() {

        metabolism = Metabolism()

        net = Net(
            parentBiases: meTheParent?.parentBiases, parentWeights: meTheParent?.parentWeights,
            layers: meTheParent?.parentLayers, parentActivator: meTheParent?.parentActivator
        )

        guard let sprite = self.thorax else { preconditionFailure() }

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
        np.run(SKAction.run { self.netDisplay!.display() })
    }
}

extension Spawn {

    func abandonNewborn() {
        guard let st = meTheParent, let dp = st.dispatch, let sprite = st.sprite
            else {
                Log.L.write("Aboriginal? \(six(self.embryoName)), parent \(six(meTheParent?.name))", level: 66)
                return
        }

        precondition((sprite.getStepper(require: false)?.name ?? "") == st.name)
        precondition((sprite.getStepper(require: false)?.name ?? "") == sprite.name)
        precondition(sprite.name == meTheParent?.name)
        let rotate = SKAction.rotate(byAngle: 4 * 2 * CGFloat.pi, duration: 2.0)
        sprite.run(rotate)
        let spawnCost = st.getSpawnCost()
        st.metabolism.withdrawFromSpawn(spawnCost)
        let ch = dp.scratch
        precondition(
                (ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition
        ))

        precondition((sprite.getStepper(require: false)?.name ?? "") == st.name)
        precondition((sprite.getStepper(require: false)?.name ?? "") == sprite.name)
        precondition(sprite.name != embryoName)
        precondition(meTheParent?.dispatch.scratch.name == meTheParent?.name)
        precondition(meTheParent?.dispatch.scratch.name == sprite.name)
        dp.metabolize()
    }

    func buildSprites() {
        let action = SKAction.run { [unowned self] in
            self.buildSprites_()
            self.buildGuts()
        }

        GriddleScene.shared.run(action)
    }

    private func buildSprites_() {
        assert(Display.displayCycle == .actions)

        self.nose = SpriteFactory.shared.noseHangar.makeSprite()
        self.thorax = SpriteFactory.shared.arkonsHangar.makeSprite()

        guard let thorax = self.thorax else { fatalError() }
        guard let nose = self.nose else { fatalError() }
        Log.L.write("Reset engagerKey #4", level: 41)
        guard let engagerKey = self.engagerKey else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 1
        nose.setScale(0.75)
        nose.name = embryoName

        sprite.setScale(Arkonia.spriteScale)
        Log.L.write("ArkoniaCentral.masterScale = \(Arkonia.masterScale)", level: 37)
        sprite.colorBlendFactor = 1
        sprite.position = engagerKey.scenePosition
        sprite.alpha = 1

        let noseColor: SKColor = (parent == nil) ? .magenta : .yellow
        Debug.debugColor(sprite, .green, nose, noseColor)

        thorax.addChild(nose)
    }

    func launchNewborn() {
        guard let thorax = self.thorax else { preconditionFailure() }

        let newborn = Stepper(self, needsNewDispatch: true)
        newborn.parentStepper = self.meTheParent
        newborn.dispatch.scratch.stepper = newborn
        newborn.sprite?.color = .yellow
        newborn.nose?.color = .white

        precondition(newborn.name == thorax.name)
        precondition(newborn.name == embryoName)
        precondition(newborn.name != self.meTheParent?.name ?? "")
        precondition(newborn.name != self.meTheParent?.sprite?.name ?? "")

        guard let ek = engagerKey else { fatalError() }
        guard let ch = newborn.dispatch?.scratch else { fatalError() }

        precondition(ch.name == newborn.name)
        precondition(ch.name != self.meTheParent?.sprite?.name ?? "")

        writeDebug(
            "Spawn engagerKey contents = \(engagerKey!.contents), " +
            "sprite name = \(six(engagerKey!.sprite?.name))",
            scratch: ch, level: 52
        )

        precondition(ek.ownerName == debug1 || ek.ownerName == debug2)

        ek.contents = .arkon
        ek.sprite = thorax
        ek.sprite?.name = newborn.name
        ek.ownerName = newborn.name

        Stepper.attachStepper(newborn, to: thorax)

        writeDebug(
            "Attach stepper \(six(newborn.name)) " +
            "sprite name is \(six(thorax.name))",
            scratch: ch, level: 51
        )

        if meTheParent != nil {
            precondition(meTheParent?.dispatch?.name != nil)
            precondition(meTheParent?.dispatch?.name.isEmpty == false)
            precondition(meTheParent?.dispatch?.name == meTheParent?.name)
            precondition(meTheParent?.dispatch?.scratch.name == meTheParent?.name)
            precondition(meTheParent?.name == meTheParent?.sprite?.name)
            precondition(meTheParent?.name == meTheParent?.sprite?.getStepper(require: false)?.name)
        }
        abandonNewborn()
        if meTheParent != nil {
            precondition(meTheParent?.dispatch?.name != nil)
            precondition(meTheParent?.dispatch?.name.isEmpty == false)
            precondition(meTheParent?.dispatch?.name == meTheParent?.name)
            precondition(meTheParent?.dispatch?.scratch.name == meTheParent?.name)
            precondition(meTheParent?.name == meTheParent?.sprite?.name)
            precondition(meTheParent?.name == meTheParent?.sprite?.getStepper(require: false)?.name)
        }

        precondition(newborn.dispatch?.name != nil)
        precondition(newborn.dispatch?.name.isEmpty == false)
        precondition(newborn.dispatch?.name == newborn.name)
        precondition(newborn.dispatch?.scratch.name == newborn.name)
        precondition(newborn.name == newborn.sprite?.name)
        precondition(newborn.name == newborn.sprite?.getStepper(require: false)?.name)

        precondition(meTheParent?.name != newborn.dispatch?.name)

        GriddleScene.arkonsPortal!.addChild(thorax)

        let rotate = SKAction.rotate(byAngle: -4 * 2 * CGFloat.pi, duration: 2.0)
        thorax.run(rotate)

        guard let ndp = newborn.dispatch else { fatalError() }

        ndp.scratch.engagerKey = ek

        defer {
            if meTheParent != nil {
                precondition(meTheParent?.dispatch?.name != nil)
                precondition(meTheParent?.dispatch?.name.isEmpty == false)
                precondition(meTheParent?.dispatch?.name == meTheParent?.name)
                precondition(meTheParent?.dispatch?.scratch.name == meTheParent?.name)
                precondition(meTheParent?.name != newborn.dispatch?.name)
            }

            precondition(newborn.dispatch?.name != nil)
            precondition(newborn.dispatch?.name.isEmpty == false)
            precondition(newborn.dispatch?.name == newborn.name)
            precondition(newborn.dispatch?.scratch.name == newborn.name)
        }

        precondition((thorax.getStepper(require: false)?.name ?? "") == newborn.name)
        precondition((thorax.getStepper(require: false)?.name ?? "") == thorax.name)

        Log.L.write("parent name = \(meTheParent?.name ?? "aboriginal"), newborn name = \(newborn.name))", level: 65)

        // The newborn now has a strong ref to the dispatch, so we can let
        // it go now
        self.tempStrongReference = nil
        ndp.disengage()
    }
}

func writeDebug(_ toWrite: String, scratch: Scratchpad, level: Int? = nil) {
//    scratch.debugReport.append("\n\(toWrite)")
}
