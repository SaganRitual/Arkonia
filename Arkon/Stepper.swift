import SpriteKit

class Stepper {
    var birthday: TimeInterval = 0
    var cOffspring = 0
    var dispatch: Dispatch!
    var ingridCellAbsoluteIndex = 0
    var isTurnabouted: Bool = false
    var metabolism: Metabolism!
    let name: ArkonName
    var net: Net!
    var netDisplay: NetDisplay?
    var nose: SKSpriteNode!
    weak var parentStepper: Stepper?
    var parentWeights: [Double]?
    var previousShiftOffset = AKPoint.zero
    var sensorPad: UnsafeMutablePointer<IngridCellDescriptor>
    weak var sprite: SKSpriteNode!
    var tooth: SKSpriteNode!

    var babyBumpIsShowing = false
    var canSpawn = false
    var jumpSpeed = 0.0
    var jumpSpec: JumpSpec?

    weak var parentNet: Net?
    weak var stepper: Stepper!

    var currentTime: Int = 0
    var currentEntropyPerJoule: Double = 0

    init(_ embryo: Spawn, needsNewDispatch: Bool = false) {
        self.metabolism = embryo.metabolism
        self.name = embryo.embryoName
        self.net = embryo.net
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.nose
        self.tooth = embryo.tooth
        self.sprite = embryo.thorax

        let c = self.net.netStructure.cCellsWithinSenseRange
        self.sensorPad = .allocate(capacity: c)
        self.sensorPad.initialize(repeating: IngridCellDescriptor(), count: c)

        if needsNewDispatch { self.dispatch = Dispatch(self) }
    }

    func apoptosize(_ onComplete: @escaping () -> Void) {
        let c = net.netStructure.cCellsWithinSenseRange

        Ingrid.shared.disengageSensorPad(
            sensorPad, padCCells: c, keepTheseCells: [], onComplete
        )
    }

    func detachRandomCellForNewborn() -> IngridCellDescriptor {
        let bp =  UnsafeMutableBufferPointer(
            start: sensorPad, count: net.netStructure.cCellsWithinSenseRange
        )

        let hotCell = bp.compactMap({ $0.cell }).randomElement()!
        let localIndex = bp.firstIndex(where: { $0.absoluteIndex == hotCell.absoluteIndex })!

        let virtualScenePosition = bp[localIndex].virtualScenePosition

        Debug.log(level: 190) { "detachRandomCell absoluteIx \(hotCell.absoluteIndex) localIx \(localIndex)" }

        // Invalidate my reference to my offspring's cell; he now owns the lock
        bp[localIndex] = IngridCellDescriptor()

        return IngridCellDescriptor(hotCell, virtualScenePosition)
    }
}

extension Stepper {
    static func attachStepper(_ stepper: Stepper, to sprite: SKSpriteNode) {
        // Some of the drones get their userData set up for the net display,
        // the rest of them we set up here
        if sprite.userData == nil { sprite.userData = [:] }

        // We save the stepper in the userdata of the sprite, but only as
        // a centralized strong reference to the stepper. We don't use it,
        // because retrieving it from the dictionary is way too slow
        sprite.userData!["stepper"] = stepper
    }

    static func releaseStepper(
        _ stepper: Stepper, from sprite: SKSpriteNode
    ) {
        // See notes in attachStepper
        sprite.userData!["stepper"] = nil
        sprite.name = nil
    }
}
