import SpriteKit

class Stepper {
    var birthday: TimeInterval = 0
    var cFoodHits = 0
    var cJumps = 0
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
    var thorax: SKSpriteNode!
    var tooth: SKSpriteNode!

    var babyBumpIsShowing = false
    var canSpawn = false
    var jumpSpeed = 0.0
    var jumpSpec: JumpSpec?

    weak var parentNet: Net?

    var currentTime: Int = 0
    var currentEntropyPerJoule: Double = 0

    init(_ embryo: Spawn, needsNewDispatch: Bool = false) {
        self.metabolism = embryo.metabolism
        self.name = embryo.embryoName!
        self.net = embryo.net
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.newbornNose
        self.thorax = embryo.newbornThorax!
        self.tooth = embryo.newbornTooth

        let c = self.net.netStructure.cCellsWithinSenseRange
        self.sensorPad = .allocate(capacity: c)
        self.sensorPad.initialize(repeating: IngridCellDescriptor(), count: c)

        if needsNewDispatch { self.dispatch = Dispatch(self) }
    }

    deinit {
        Debug.log(level: 197) { "Stepper \(self.name) deinit" }
    }

    func detachBirthingCellForNewborn() -> IngridCellDescriptor {
        guard let localIndex = (1..<net.netStructure.cCellsWithinSenseRange).first(where: {
            sensorPad[$0].cell != nil
        }) else { fatalError("No usable cells for newborn?") }

        let birthingCell = sensorPad[localIndex].cell!
        let virtualScenePosition = sensorPad[localIndex].virtualScenePosition

        Debug.log(level: 195) { "detachRandomCell absoluteIx \(birthingCell.absoluteIndex) localIx \(localIndex)" }

        // Invalidate my reference to my offspring's cell; he now owns the lock
        sensorPad[localIndex] = IngridCellDescriptor()

        return IngridCellDescriptor(birthingCell, virtualScenePosition)
    }
}
